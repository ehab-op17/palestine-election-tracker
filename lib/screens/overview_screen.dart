import 'package:flutter/material.dart';

import '../localization.dart';
import '../models/election_data.dart';
import '../theme.dart';

class OverviewScreen extends StatelessWidget {
  final ElectionDataset data;
  final String sourceLabel;
  final ValueChanged<int> onNavigate;

  const OverviewScreen({
    super.key,
    required this.data,
    required this.sourceLabel,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final poll = data.latestPoll;
    final strings = AppStrings.of(context);
    final daysOut = data.electionDate.difference(DateTime.now()).inDays.clamp(0, 100000);
    final leader = poll.fatahPct >= poll.hamasPct ? 'Fatah' : 'Hamas';
    final lead = (poll.fatahPct - poll.hamasPct).abs();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(eyebrow: strings.overviewEyebrow, title: strings.overviewTitle, subtitle: strings.overviewSubtitle),
          const SizedBox(height: 16),
          _HeroPanel(
            daysOut: daysOut,
            electionDate: data.electionDate,
            sourceLabel: sourceLabel,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 620 ? 4 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: columns == 4 ? 1.45 : 1.35,
                children: [
                  _KpiTile(
                    label: strings.currentLeader,
                    value: leader,
                    detail: '${lead.toStringAsFixed(0)} ${strings.t('pt lead', 'نقطة تقدم')}',
                    color: leader == 'Fatah' ? AppColors.fatah : AppColors.hamas,
                  ),
                  _KpiTile(
                    label: strings.likelyTurnout,
                    value: '${poll.likelyTurnoutPct.toStringAsFixed(0)}%',
                    detail: strings.latestPollInput,
                    color: AppColors.ink,
                  ),
                  _KpiTile(
                    label: strings.undecided,
                    value: '${poll.undecidedPct.toStringAsFixed(0)}%',
                    detail: strings.largestUnknown,
                    color: AppColors.alert,
                  ),
                  _KpiTile(
                    label: strings.openConditions,
                    value: '${data.unresolvedConditions.length}',
                    detail: strings.needMonitoring,
                    color: const Color(0xFF516B8B),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionHeading(eyebrow: strings.decisionPath, title: strings.goDeeper, subtitle: strings.goDeeperSubtitle),
          const SizedBox(height: 12),
          _ActionRow(
            icon: Icons.bar_chart_rounded,
            title: strings.pollingEvidence,
            detail: '${poll.source}  |  ${poll.dateRange}',
            onTap: () => onNavigate(1),
          ),
          _ActionRow(
            icon: Icons.groups_rounded,
            title: strings.listsFormation,
            detail: '${data.prospectiveLists.length} expected or reported blocs tracked',
            onTap: () => onNavigate(2),
          ),
          _ActionRow(
            icon: Icons.tune_rounded,
            title: strings.scenarioQuestion,
            detail: strings.t('Test Gaza, Jerusalem and coalition assumptions', 'اختبر افتراضات غزة والقدس والائتلاف'),
            onTap: () => onNavigate(4),
          ),
          _ActionRow(
            icon: Icons.newspaper_rounded,
            title: strings.localReporting,
            detail: '${data.publicSources.length} ${strings.t('public sources in the coverage mix', 'مصدر عام في مزيج التغطية')}',
            onTap: () => onNavigate(5),
          ),
          const SizedBox(height: 24),
          _Watchlist(data: data),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final int daysOut;
  final DateTime electionDate;
  final String sourceLabel;

  const _HeroPanel({
    required this.daysOut,
    required this.electionDate,
    required this.sourceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available, color: Color(0xFFE8DCC0), size: 18),
              const SizedBox(width: 8),
              Text(
                '${AppStrings.of(context).scheduled.toUpperCase()} ${_formatDate(electionDate)}',
                style: const TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.1),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(AppStrings.of(context).t('MONITORING', 'قيد المتابعة'), style: const TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$daysOut', style: const TextStyle(color: Color(0xFFE8DCC0), fontSize: 42, fontWeight: FontWeight.w700, height: 0.95)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(AppStrings.of(context).daysUntil, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(sourceLabel, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color color;

  const _KpiTile({required this.label, required this.value, required this.detail, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.black45, fontSize: 9, letterSpacing: 0.7)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(detail, style: const TextStyle(color: Colors.black54, fontSize: 10)),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _SectionHeading({required this.eyebrow, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: const TextStyle(color: AppColors.hamas, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.title, required this.detail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.hamas, size: 21),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(detail, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Watchlist extends StatelessWidget {
  final ElectionDataset data;

  const _Watchlist({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.alert.withValues(alpha: 0.07),
        border: const Border(left: BorderSide(color: AppColors.alert, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.of(context).watchlist, style: const TextStyle(color: AppColors.alert, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
          const SizedBox(height: 7),
          ...data.unresolvedConditions.take(3).map((condition) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(condition, style: const TextStyle(fontSize: 12, height: 1.3)),
              )),
        ],
      ),
    );
  }
}
