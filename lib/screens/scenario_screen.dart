import 'package:flutter/material.dart';

import '../localization.dart';
import '../models/election_data.dart';
import '../services/prediction_service.dart';
import '../theme.dart';
import '../widgets/vote_split_bar.dart';

class ScenarioScreen extends StatefulWidget {
  final ElectionDataset data;
  const ScenarioScreen({super.key, required this.data});

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  ScenarioToggles toggles = const ScenarioToggles();
  final _prediction = PredictionService();

  @override
  Widget build(BuildContext context) {
    final result = _prediction.compute(widget.data, toggles);
    final strings = AppStrings.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.whatIf, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${strings.t('Starting from the latest source data', 'بالاعتماد على أحدث بيانات المصدر')} (${widget.data.latestPoll.source}, ${widget.data.latestPoll.dateRange}). '
            '${strings.t('The output is scenario arithmetic with an uncertainty range, not a statistical forecast.', 'النتيجة حساب سيناريو مع نطاق عدم يقين وليست توقعاً إحصائياً.')} '
            '${widget.data.coalitionReporting.summary}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 18),
          _EvidenceRiskPanel(result: result),
          const SizedBox(height: 20),
          _ToggleTile(
            title: strings.gazaVotes,
            subtitle: strings.t(
                'Uses Gaza and West Bank poll splits when available',
                'يستخدم تقسيم استطلاع غزة والضفة عند توفره'),
            value: toggles.gazaVotes,
            onChanged: (v) =>
                setState(() => toggles = toggles.copyWith(gazaVotes: v)),
          ),
          _ToggleTile(
            title: strings.jerusalemVotes,
            subtitle: strings.t(
                'Israel permission remains a key legal and political condition',
                'تبقى موافقة إسرائيل شرطاً قانونياً وسياسياً أساسياً'),
            value: toggles.jerusalemVotes,
            onChanged: (v) =>
                setState(() => toggles = toggles.copyWith(jerusalemVotes: v)),
          ),
          _ToggleTile(
            title: strings.coalitionForms,
            subtitle:
                '${widget.data.coalitionReporting.status}. Participants can change as talks develop.',
            value: toggles.coalitionForms,
            onChanged: (v) =>
                setState(() => toggles = toggles.copyWith(coalitionForms: v)),
          ),
          const SizedBox(height: 24),
          VoteSplitBar(
            leftPct: result.coalitionPct,
            rightPct: result.fatahPct,
            otherPct: result.otherPct,
            leftLabel: toggles.coalitionForms
                ? strings.coalition
                : strings.t('Hamas', 'حماس'),
            rightLabel: strings.t('Fatah', 'فتح'),
            leftColor: AppColors.hamas,
            rightColor: AppColors.fatah,
            otherColor: AppColors.undecided,
          ),
          const SizedBox(height: 8),
          Text(
            '${toggles.coalitionForms ? strings.coalition : strings.t('Hamas', 'حماس')} ${result.coalitionPct.toStringAsFixed(1)}% / ${strings.t('Fatah', 'فتح')} ${result.fatahPct.toStringAsFixed(1)}% / ${strings.otherUndecided} ${result.otherPct.toStringAsFixed(1)}% (${strings.t('uncertainty +/-', 'عدم اليقين +/-')}${result.uncertaintyPct.toStringAsFixed(1)} ${strings.t('pts', 'نقطة')})',
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
          if (result.factors.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(strings.modelFactors,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...result.factors.map(
              (factor) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('- $factor',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.parchment, borderRadius: BorderRadius.circular(6)),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        activeThumbColor: AppColors.hamas,
      ),
    );
  }
}

class _EvidenceRiskPanel extends StatelessWidget {
  final ScenarioResult result;

  const _EvidenceRiskPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final risks = [
      (strings.coalitionProbability, result.coalitionProbabilityRiskPct),
      (strings.electionDelay, result.electionDelayRiskPct),
      (strings.gazaFeasibility, result.gazaFeasibilityRiskPct),
      (strings.jerusalemFeasibility, result.jerusalemFeasibilityRiskPct),
      (strings.turnoutUncertainty, result.turnoutUncertaintyPct),
    ];
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.undecided),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.evidenceRisk,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '${strings.reviewedEvidence}: ${result.reviewedNewsCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          ...risks.map((risk) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(risk.$1,
                            style: const TextStyle(fontSize: 11))),
                    Text('${risk.$2.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              )),
          if (result.coalitionChanges.isNotEmpty) ...[
            const Divider(height: 18),
            Text(strings.coalitionEvidence,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ...result.coalitionChanges.map((change) => Text('- $change',
                style: const TextStyle(fontSize: 11, color: Colors.black54))),
          ],
          if (result.entityUpdates.isNotEmpty) ...[
            const Divider(height: 18),
            Text(strings.entityUpdates,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ...result.entityUpdates.map((update) => Text('- $update',
                style: const TextStyle(fontSize: 11, color: Colors.black54))),
          ],
        ],
      ),
    );
  }
}
