import '../models/election_data.dart';

/// IMPORTANT: this is illustrative scenario arithmetic, not a fitted
/// statistical or machine-learning model. Palestinian legislative polling
/// is too sparse, and this election has too many unresolved structural
/// questions (Gaza access, Jerusalem access, final coalition shape), for
/// any model to output a genuinely precise vote prediction. Recompute
/// live so the numbers move with the latest fetched poll, but never
/// present this as more certain than it is.
class PredictionService {
  ScenarioResult compute(ElectionDataset data, ScenarioToggles toggles) {
    double fatah = data.latestPoll.fatahPct;
    double coalition = data.latestPoll.hamasPct;
    double thirdParties = data.latestPoll.thirdPartiesPct;
    double undecided = data.latestPoll.undecidedPct;
    final factors = <String>[];

    if (!toggles.gazaVotes &&
        data.latestPoll.westBankFatahPct > 0 &&
        data.latestPoll.westBankHamasPct > 0) {
      fatah = data.latestPoll.westBankFatahPct;
      coalition = data.latestPoll.westBankHamasPct;
      thirdParties = data.latestPoll.westBankThirdPartiesPct;
      undecided = data.latestPoll.westBankUndecidedPct;
      factors.add('Gaza excluded: using West Bank subsample.');
    } else if (!toggles.gazaVotes) {
      fatah += 3;
      coalition -= 4;
      undecided += 1;
      factors.add('Gaza excluded: approximated from national poll.');
    }

    if (toggles.coalitionForms) {
      // Assumption, not polled data: a joint list can consolidate some
      // third-party support and a smaller slice of undecided voters.
      final consolidated =
          ((thirdParties * 0.45) + (undecided * 0.12)).clamp(0, 12).toDouble();
      coalition += consolidated;
      thirdParties =
          (thirdParties - consolidated * 0.75).clamp(0, 100).toDouble();
      undecided = (undecided - consolidated * 0.25).clamp(0, 100).toDouble();
      factors.add(
          'Coalition list: transfers part of third-party/undecided support.');
    }

    if (!toggles.jerusalemVotes) {
      // Jerusalem is a small fraction of the electorate — minor
      // turnout/legitimacy effect only.
      undecided += 1;
      fatah -= 0.5;
      coalition -= 0.5;
      factors.add('Jerusalem restricted: small legitimacy/turnout penalty.');
    }

    fatah = fatah < 0 ? 0 : fatah;
    coalition = coalition < 0 ? 0 : coalition;
    final other = (thirdParties + undecided).clamp(0, 100).toDouble();

    final total = fatah + coalition + other;
    final unresolvedPenalty = data.unresolvedConditions.length * 0.7;
    final undecidedPenalty = undecided * 0.12;
    final newsRisk = _newsRisk(data.newsSignals);
    if (data.newsSignals.isNotEmpty) {
      factors.add(
        'News signals add ${newsRisk.toStringAsFixed(1)} pts of uncertainty; they do not rewrite poll shares.',
      );
    }
    final unmeasuredContenders = data.contenders
        .where((contender) => !contender.pollTreatment
            .toLowerCase()
            .contains('standalone'))
        .map((contender) => contender.name)
        .toList();
    if (unmeasuredContenders.isNotEmpty) {
      factors.add(
        'Unmeasured contenders (${unmeasuredContenders.join(', ')}): retained inside aggregate uncertainty until a source reports them separately.',
      );
    }
    return ScenarioResult(
      fatahPct: (fatah / total) * 100,
      coalitionPct: (coalition / total) * 100,
      otherPct: (other / total) * 100,
      uncertaintyPct: (data.latestPoll.marginOfErrorPct +
              unresolvedPenalty +
              undecidedPenalty +
              newsRisk)
          .clamp(3, 12)
          .toDouble(),
      factors: factors,
    );
  }

  double _newsRisk(List<NewsSignal> signals) {
    return signals.fold<double>(0, (risk, signal) {
      final categoryWeight = switch (signal.category) {
        'access' => 1.2,
        'coalition' => 0.9,
        'official' => 0.7,
        'turnout' => 0.7,
        _ => 0.4,
      };
      final normalizedImpact = (signal.impactScore / 10).clamp(0, 1);
      return risk + (normalizedImpact * categoryWeight);
    }).clamp(0, 3).toDouble();
  }
}
