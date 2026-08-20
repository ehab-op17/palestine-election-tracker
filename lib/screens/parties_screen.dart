import 'package:flutter/material.dart';

import '../localization.dart';
import '../models/election_data.dart';
import '../theme.dart';

class PartiesScreen extends StatefulWidget {
  final ElectionDataset data;

  const PartiesScreen({super.key, required this.data});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final strings = AppStrings.of(context);
    final lists = data.prospectiveLists.where((list) {
      if (_filter == 'all') return true;
      return list.status.toLowerCase().contains(_filter);
    }).toList();
    final statuses = data.prospectiveLists
        .map((list) => list.status.toLowerCase())
        .toList();
    final officialCount = statuses.where((status) => status.contains('official')).length;
    final reportedCount = statuses.where((status) => status.contains('reported')).length;
    final expectedCount = statuses.where((status) => status.contains('expected')).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.partiesTitle,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            strings.partiesSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _CoalitionNotice(reporting: data.coalitionReporting),
          const SizedBox(height: 14),
          const _CandidateMethodology(),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(label: '${strings.t('All', 'الكل')} ${data.prospectiveLists.length}', value: 'all', selected: _filter, onSelected: _setFilter),
              _FilterChip(label: '${strings.t('Official', 'رسمي')} $officialCount', value: 'official', selected: _filter, onSelected: _setFilter),
              _FilterChip(label: '${strings.t('Reported', 'مُبلغ عنه')} $reportedCount', value: 'reported', selected: _filter, onSelected: _setFilter),
              _FilterChip(label: '${strings.t('Expected', 'متوقع')} $expectedCount', value: 'expected', selected: _filter, onSelected: _setFilter),
            ],
          ),
          const SizedBox(height: 14),
          if (lists.isEmpty)
            const _EmptyLists()
          else
          ...lists.map((list) => _ListCard(list: list)),
        ],
      ),
    );
  }

  void _setFilter(String filter) => setState(() => _filter = filter);
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterChip({required this.label, required this.value, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: value == selected,
      onSelected: (_) => onSelected(value),
      labelStyle: TextStyle(fontSize: 11, color: value == selected ? Colors.white : Colors.black54),
      selectedColor: AppColors.ink,
      backgroundColor: AppColors.paper,
      side: BorderSide.none,
    );
  }
}

class _CoalitionNotice extends StatelessWidget {
  final CoalitionReporting reporting;

  const _CoalitionNotice({required this.reporting});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.alert.withValues(alpha: 0.08),
        border: const Border(left: BorderSide(color: AppColors.alert, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.change_history, color: AppColors.alert, size: 17),
              const SizedBox(width: 7),
              Expanded(child: Text(reporting.status.toUpperCase(), style: const TextStyle(color: AppColors.alert, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8))),
              Text('${AppStrings.of(context).t('Checked', 'تم التحقق')} ${reporting.asOf}', style: const TextStyle(fontSize: 10, color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 6),
          Text(reporting.summary, style: const TextStyle(fontSize: 12, height: 1.35)),
          if (reporting.participants.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text('${AppStrings.of(context).t('Participants under discussion', 'الأطراف قيد النقاش')}: ${reporting.participants.join(', ')}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ],
      ),
    );
  }
}

class _EmptyLists extends StatelessWidget {
  const _EmptyLists();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('No lists match this status yet. The dataset can add new lists without an app update.', style: TextStyle(fontSize: 12, color: Colors.black54)),
      );
}

class _ListCard extends StatelessWidget {
  final ProspectiveList list;

  const _ListCard({required this.list});

  @override
  Widget build(BuildContext context) {
    final status = list.status.toLowerCase();
    final isOfficial = status.contains('official');
    final isReported = status.contains('reported');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.paper, borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(list.name,
                      style: Theme.of(context).textTheme.titleMedium)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: isOfficial
                      ? AppColors.hamas.withValues(alpha: 0.12)
                      : isReported
                          ? AppColors.fatah.withValues(alpha: 0.12)
                        : AppColors.alert.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  list.status,
                  style: TextStyle(
                      fontSize: 10,
                      color: isOfficial ? AppColors.hamas : AppColors.alert),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Row(label: AppStrings.of(context).alignment, value: list.alignment),
          _Row(label: AppStrings.of(context).leadershipReference, value: list.leader),
          _Row(label: AppStrings.of(context).relatedParties, value: list.relatedParties.join(', ')),
          if (list.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(list.notes,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54, height: 1.35)),
          ],
          if (list.candidates.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(AppStrings.of(context).peopleToVerify, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...list.candidates.map((candidate) => _CandidateCard(candidate: candidate)),
          ],
          if (list.sources.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Sources: ${list.sources.join(', ')}',
                style: const TextStyle(fontSize: 10, color: Colors.black38)),
          ],
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final CandidateProfile candidate;

  const _CandidateCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final hasEstimate = candidate.voteEstimatePct != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.undecided),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(candidate.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
              _CandidateBadge(label: hasEstimate ? '${candidate.voteEstimatePct!.toStringAsFixed(1)}%' : AppStrings.of(context).noEstimate, color: hasEstimate ? AppColors.hamas : AppColors.alert),
            ],
          ),
          const SizedBox(height: 5),
          Text(candidate.status, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          const SizedBox(height: 8),
          _CandidateField(label: AppStrings.of(context).origin, value: '${candidate.origin} (${candidate.localityType})'),
          _CandidateField(label: AppStrings.of(context).geographySignal, value: candidate.geographicSignal),
          _CandidateField(label: AppStrings.of(context).roleWork, value: '${candidate.role}; ${candidate.profession}'),
          _CandidateField(label: AppStrings.of(context).profile, value: candidate.publicProfile),
          _CandidateField(label: AppStrings.of(context).electoralBase, value: candidate.electoralBase),
          _CandidateField(label: AppStrings.of(context).estimateBasis, value: candidate.estimateBasis),
          if (candidate.sources.isNotEmpty)
            Text('Sources: ${candidate.sources.join(', ')}', style: const TextStyle(fontSize: 10, color: Colors.black38)),
        ],
      ),
    );
  }
}

class _CandidateMethodology extends StatelessWidget {
  const _CandidateMethodology();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          AppStrings.of(context).candidateMethodology,
          style: const TextStyle(fontSize: 11, color: AppColors.ink, height: 1.35),
        ),
      );
}

class _CandidateField extends StatelessWidget {
  final String label;
  final String value;

  const _CandidateField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text.rich(TextSpan(children: [
          TextSpan(text: '$label: ', style: const TextStyle(fontSize: 10, color: Colors.black45)),
          TextSpan(text: value, style: const TextStyle(fontSize: 11, height: 1.25)),
        ])),
      );
}

class _CandidateBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _CandidateBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
        child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 96,
              child: Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.black45))),
          Expanded(
              child: Text(value.isEmpty ? 'TBD' : value,
                  style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
