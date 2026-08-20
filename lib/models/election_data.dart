class HistoricalResult2006 {
  final double fatahPct;
  final double hamasPct;
  final double otherPct;
  final double turnoutPct;
  final String source;

  HistoricalResult2006({
    required this.fatahPct,
    required this.hamasPct,
    required this.otherPct,
    required this.turnoutPct,
    required this.source,
  });

  factory HistoricalResult2006.fromJson(Map<String, dynamic> j) =>
      HistoricalResult2006(
        fatahPct: (j['fatah_pct'] as num).toDouble(),
        hamasPct: (j['hamas_pct'] as num).toDouble(),
        otherPct: (j['other_pct'] as num).toDouble(),
        turnoutPct: (j['turnout_pct'] as num).toDouble(),
        source: j['source'] as String,
      );
}

class LocalElections2026 {
  final String date;
  final double nationalTurnoutPct;
  final double westBankTurnoutPct;
  final double gazaTurnoutPct;
  final String note;

  LocalElections2026({
    required this.date,
    required this.nationalTurnoutPct,
    required this.westBankTurnoutPct,
    required this.gazaTurnoutPct,
    required this.note,
  });

  factory LocalElections2026.fromJson(Map<String, dynamic> j) =>
      LocalElections2026(
        date: j['date'] as String,
        nationalTurnoutPct: (j['national_turnout_pct'] as num).toDouble(),
        westBankTurnoutPct: (j['west_bank_turnout_pct'] as num).toDouble(),
        gazaTurnoutPct: (j['gaza_deir_al_balah_turnout_pct'] as num).toDouble(),
        note: j['note'] as String,
      );
}

class LatestPoll {
  final String source;
  final String sourceUrl;
  final String dateRange;
  final int sampleSize;
  final double marginOfErrorPct;
  final double likelyTurnoutPct;
  final double fatahPct;
  final double hamasPct;
  final double thirdPartiesPct;
  final double undecidedPct;
  final double gazaFatahPct;
  final double gazaHamasPct;
  final double gazaThirdPartiesPct;
  final double gazaUndecidedPct;
  final double westBankFatahPct;
  final double westBankHamasPct;
  final double westBankThirdPartiesPct;
  final double westBankUndecidedPct;

  LatestPoll({
    required this.source,
    required this.sourceUrl,
    required this.dateRange,
    required this.sampleSize,
    required this.marginOfErrorPct,
    required this.likelyTurnoutPct,
    required this.fatahPct,
    required this.hamasPct,
    required this.thirdPartiesPct,
    required this.undecidedPct,
    required this.gazaFatahPct,
    required this.gazaHamasPct,
    required this.gazaThirdPartiesPct,
    required this.gazaUndecidedPct,
    required this.westBankFatahPct,
    required this.westBankHamasPct,
    required this.westBankThirdPartiesPct,
    required this.westBankUndecidedPct,
  });

  factory LatestPoll.fromJson(Map<String, dynamic> j) {
    final gaza = j['gaza_subsample'] as Map<String, dynamic>;
    final westBank =
        (j['west_bank_subsample'] as Map?)?.cast<String, dynamic>() ?? const {};
    final otherLegacy = (j['other_undecided_pct'] as num?)?.toDouble();
    final third = (j['third_parties_pct'] as num?)?.toDouble() ?? 0;
    final undecided = (j['undecided_pct'] as num?)?.toDouble() ??
        ((otherLegacy ?? 0) - third).clamp(0, 100).toDouble();
    return LatestPoll(
      source: j['source'] as String,
      sourceUrl: (j['source_url'] as String?) ?? '',
      dateRange: j['date_range'] as String,
      sampleSize: j['sample_size'] as int,
      marginOfErrorPct: (j['margin_of_error_pct'] as num).toDouble(),
      likelyTurnoutPct: (j['likely_turnout_pct'] as num?)?.toDouble() ?? 0,
      fatahPct: (j['fatah_pct'] as num).toDouble(),
      hamasPct: (j['hamas_pct'] as num).toDouble(),
      thirdPartiesPct: third,
      undecidedPct: undecided,
      gazaFatahPct: (gaza['fatah_pct'] as num).toDouble(),
      gazaHamasPct: (gaza['hamas_pct'] as num).toDouble(),
      gazaThirdPartiesPct: (gaza['third_parties_pct'] as num?)?.toDouble() ?? 0,
      gazaUndecidedPct: (gaza['undecided_pct'] as num?)?.toDouble() ??
          (((gaza['other_undecided_pct'] as num?)?.toDouble() ?? 0) -
                  ((gaza['third_parties_pct'] as num?)?.toDouble() ?? 0))
              .clamp(0, 100)
              .toDouble(),
      westBankFatahPct: (westBank['fatah_pct'] as num?)?.toDouble() ?? 0,
      westBankHamasPct: (westBank['hamas_pct'] as num?)?.toDouble() ?? 0,
      westBankThirdPartiesPct:
          (westBank['third_parties_pct'] as num?)?.toDouble() ?? 0,
      westBankUndecidedPct:
          (westBank['undecided_pct'] as num?)?.toDouble() ?? 0,
    );
  }

  double get otherPct => thirdPartiesPct + undecidedPct;
}

class ContenderProfile {
  final String name;
  final String status;
  final String pollTreatment;
  final String notes;
  final List<String> sources;

  ContenderProfile({
    required this.name,
    required this.status,
    required this.pollTreatment,
    required this.notes,
    required this.sources,
  });

  factory ContenderProfile.fromJson(Map<String, dynamic> j) => ContenderProfile(
        name: j['name'] as String,
        status: (j['status'] as String?) ?? 'tracked',
        pollTreatment:
            (j['poll_treatment'] as String?) ?? 'not separately polled',
        notes: (j['notes'] as String?) ?? '',
        sources: ((j['sources'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}

class CoalitionReporting {
  final String asOf;
  final String summary;
  final List<String> sources;
  final String status;
  final List<String> participants;

  CoalitionReporting({
    required this.asOf,
    required this.summary,
    required this.sources,
    required this.status,
    required this.participants,
  });

  factory CoalitionReporting.fromJson(Map<String, dynamic> j) =>
      CoalitionReporting(
        asOf: j['as_of'] as String,
        summary: j['summary'] as String,
        sources: (j['sources'] as List).map((e) => e.toString()).toList(),
        status: (j['status'] as String?) ?? 'reported, not finalized',
        participants: ((j['participants'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}

class ProspectiveList {
  final String name;
  final String status;
  final String alignment;
  final String leader;
  final List<String> relatedParties;
  final String notes;
  final List<String> sources;
  final List<CandidateProfile> candidates;

  ProspectiveList({
    required this.name,
    required this.status,
    required this.alignment,
    required this.leader,
    required this.relatedParties,
    required this.notes,
    required this.sources,
    required this.candidates,
  });

  factory ProspectiveList.fromJson(Map<String, dynamic> j) => ProspectiveList(
        name: j['name'] as String,
        status: j['status'] as String,
        alignment: j['alignment'] as String,
        leader: (j['leader'] as String?) ?? 'TBD',
        relatedParties: ((j['related_parties'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        notes: (j['notes'] as String?) ?? '',
        sources: ((j['sources'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        candidates: ((j['candidates'] as List?) ?? const [])
            .map((e) => CandidateProfile.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CandidateProfile {
  final String name;
  final String status;
  final String origin;
  final String localityType;
  final String geographicSignal;
  final String role;
  final String profession;
  final String publicProfile;
  final String electoralBase;
  final double? voteEstimatePct;
  final String estimateBasis;
  final List<String> sources;

  CandidateProfile({
    required this.name,
    required this.status,
    required this.origin,
    required this.localityType,
    required this.geographicSignal,
    required this.role,
    required this.profession,
    required this.publicProfile,
    required this.electoralBase,
    required this.voteEstimatePct,
    required this.estimateBasis,
    required this.sources,
  });

  factory CandidateProfile.fromJson(Map<String, dynamic> j) => CandidateProfile(
        name: j['name'] as String,
        status: (j['status'] as String?) ?? 'reported, not official',
        origin: (j['origin'] as String?) ?? 'Not yet verified',
        localityType: (j['locality_type'] as String?) ?? 'unknown',
        geographicSignal: (j['geographic_signal'] as String?) ??
            'No verified geographic signal yet',
        role: (j['role'] as String?) ?? 'Not yet documented',
        profession: (j['profession'] as String?) ?? 'Not yet documented',
        publicProfile: (j['public_profile'] as String?) ?? 'Not yet assessed',
        electoralBase: (j['electoral_base'] as String?) ?? 'Not yet assessed',
        voteEstimatePct: (j['vote_estimate_pct'] as num?)?.toDouble(),
        estimateBasis: (j['estimate_basis'] as String?) ??
            'No defensible candidate-level estimate yet',
        sources: ((j['sources'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}

class NewsSignal {
  final String source;
  final String sourceType;
  final String title;
  final String url;
  final String publishedAt;
  final String category;
  final double impactScore;
  final String summary;
  final String reviewStatus;
  final double confidencePct;
  final List<String> affectedEntities;
  final String coalitionAction;
  final Map<String, double> riskEffects;
  final List<String> entityUpdates;

  NewsSignal({
    required this.source,
    required this.sourceType,
    required this.title,
    required this.url,
    required this.publishedAt,
    required this.category,
    required this.impactScore,
    required this.summary,
    required this.reviewStatus,
    required this.confidencePct,
    required this.affectedEntities,
    required this.coalitionAction,
    required this.riskEffects,
    required this.entityUpdates,
  });

  factory NewsSignal.fromJson(Map<String, dynamic> j) => NewsSignal(
        source: j['source'] as String,
        sourceType: (j['source_type'] as String?) ?? 'news',
        title: j['title'] as String,
        url: (j['url'] as String?) ?? '',
        publishedAt: (j['published_at'] as String?) ?? '',
        category: (j['category'] as String?) ?? 'general',
        impactScore: (j['impact_score'] as num?)?.toDouble() ?? 0,
        summary: (j['summary'] as String?) ?? '',
        reviewStatus: (j['review_status'] as String?) ?? 'unreviewed',
        confidencePct: (j['confidence_pct'] as num?)?.toDouble() ?? 0,
        affectedEntities: ((j['affected_entities'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        coalitionAction: (j['coalition_action'] as String?) ?? 'none',
        riskEffects: ((j['risk_effects'] as Map?) ?? const {}).map(
            (key, value) =>
                MapEntry(key.toString(), (value as num?)?.toDouble() ?? 0)),
        entityUpdates: ((j['entity_updates'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}

class PublicSource {
  final String name;
  final String type;
  final String url;
  final String useFor;
  final String feedUrl;
  final String newsCategory;

  PublicSource({
    required this.name,
    required this.type,
    required this.url,
    required this.useFor,
    required this.feedUrl,
    required this.newsCategory,
  });

  factory PublicSource.fromJson(Map<String, dynamic> j) => PublicSource(
        name: j['name'] as String,
        type: (j['type'] as String?) ?? 'news',
        url: (j['url'] as String?) ?? '',
        useFor: (j['use_for'] as String?) ?? '',
        feedUrl: (j['feed_url'] as String?) ?? '',
        newsCategory: (j['news_category'] as String?) ?? 'general',
      );
}

class ConfidenceTrend {
  final String period;
  final double hamasPct;
  final double? fatahPct;

  ConfidenceTrend(
      {required this.period, required this.hamasPct, required this.fatahPct});

  factory ConfidenceTrend.fromJson(Map<String, dynamic> j) => ConfidenceTrend(
        period: j['period'] as String,
        hamasPct: (j['hamas_pct'] as num).toDouble(),
        fatahPct: (j['fatah_pct'] as num?)?.toDouble(),
      );
}

class ElectionDataset {
  final DateTime generatedAt;
  final DateTime electionDate;
  final List<String> unresolvedConditions;
  final HistoricalResult2006 result2006;
  final LocalElections2026 localElections2026;
  final LatestPoll latestPoll;
  final List<ContenderProfile> contenders;
  final List<ConfidenceTrend> confidenceTrend;
  final List<ProspectiveList> prospectiveLists;
  final List<NewsSignal> newsSignals;
  final List<PublicSource> publicSources;
  final CoalitionReporting coalitionReporting;

  ElectionDataset({
    required this.generatedAt,
    required this.electionDate,
    required this.unresolvedConditions,
    required this.result2006,
    required this.localElections2026,
    required this.latestPoll,
    required this.contenders,
    required this.confidenceTrend,
    required this.prospectiveLists,
    required this.newsSignals,
    required this.publicSources,
    required this.coalitionReporting,
  });

  factory ElectionDataset.fromJson(Map<String, dynamic> j) {
    final meta = j['meta'] as Map<String, dynamic>;
    return ElectionDataset(
      generatedAt: DateTime.parse(meta['generated_at'] as String),
      electionDate: DateTime.parse(meta['election_date'] as String),
      unresolvedConditions: (j['unresolved_conditions'] as List)
          .map((e) => e.toString())
          .toList(),
      result2006: HistoricalResult2006.fromJson(j['historical_result_2006']),
      localElections2026:
          LocalElections2026.fromJson(j['local_elections_2026']),
      latestPoll: LatestPoll.fromJson(j['latest_national_poll']),
      contenders: ((j['tracked_contenders'] as List?) ?? const [])
          .map((e) => ContenderProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidenceTrend:
          ((j['confidence_to_represent_trend'] as List?) ?? const [])
              .map((e) => ConfidenceTrend.fromJson(e as Map<String, dynamic>))
              .toList(),
      prospectiveLists: ((j['prospective_lists'] as List?) ?? const [])
          .map((e) => ProspectiveList.fromJson(e as Map<String, dynamic>))
          .toList(),
      newsSignals: ((j['news_signals'] as List?) ?? const [])
          .map((e) => NewsSignal.fromJson(e as Map<String, dynamic>))
          .toList(),
      publicSources: ((j['public_sources'] as List?) ?? const [])
          .map((e) => PublicSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      coalitionReporting: CoalitionReporting.fromJson(j['coalition_reporting']),
    );
  }
}

/// Toggles for the scenario model — mirrors the open political questions,
/// not statistical parameters. See PredictionService for the (explicitly
/// illustrative, not statistically fitted) math.
class ScenarioToggles {
  final bool gazaVotes;
  final bool jerusalemVotes;
  final bool coalitionForms;

  const ScenarioToggles({
    this.gazaVotes = true,
    this.jerusalemVotes = false,
    this.coalitionForms = true,
  });

  ScenarioToggles copyWith(
          {bool? gazaVotes, bool? jerusalemVotes, bool? coalitionForms}) =>
      ScenarioToggles(
        gazaVotes: gazaVotes ?? this.gazaVotes,
        jerusalemVotes: jerusalemVotes ?? this.jerusalemVotes,
        coalitionForms: coalitionForms ?? this.coalitionForms,
      );
}

class ScenarioResult {
  final double fatahPct;
  final double coalitionPct;
  final double otherPct;
  final double uncertaintyPct;
  final List<String> factors;
  final double coalitionProbabilityRiskPct;
  final double electionDelayRiskPct;
  final double gazaFeasibilityRiskPct;
  final double jerusalemFeasibilityRiskPct;
  final double turnoutUncertaintyPct;
  final int reviewedNewsCount;
  final List<String> coalitionChanges;
  final List<String> entityUpdates;

  ScenarioResult({
    required this.fatahPct,
    required this.coalitionPct,
    required this.otherPct,
    required this.uncertaintyPct,
    required this.factors,
    required this.coalitionProbabilityRiskPct,
    required this.electionDelayRiskPct,
    required this.gazaFeasibilityRiskPct,
    required this.jerusalemFeasibilityRiskPct,
    required this.turnoutUncertaintyPct,
    required this.reviewedNewsCount,
    required this.coalitionChanges,
    required this.entityUpdates,
  });
}
