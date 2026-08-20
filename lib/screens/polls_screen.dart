import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../localization.dart';
import '../models/election_data.dart';
import '../theme.dart';

class PollsScreen extends StatelessWidget {
  final ElectionDataset data;
  const PollsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final poll = data.latestPoll;
    final result2006 = data.result2006;
    final strings = AppStrings.of(context);

    final groups = [
      _ChartGroup('2006\nResult', result2006.fatahPct, result2006.hamasPct,
          result2006.otherPct),
      _ChartGroup('${poll.source}\nNational', poll.fatahPct, poll.hamasPct,
          poll.otherPct),
      _ChartGroup('${poll.source}\nGaza', poll.gazaFatahPct, poll.gazaHamasPct,
          poll.gazaThirdPartiesPct + poll.gazaUndecidedPct),
      if (poll.westBankFatahPct > 0)
        _ChartGroup(
            '${poll.source}\nWest Bank',
            poll.westBankFatahPct,
            poll.westBankHamasPct,
            poll.westBankThirdPartiesPct + poll.westBankUndecidedPct),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.pollingTitle,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            strings.pollingDisclaimer,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                maxY: 55,
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 32)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= groups.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(groups[i].label,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center),
                        );
                      },
                      reservedSize: 46,
                    ),
                  ),
                ),
                barGroups: List.generate(groups.length, (i) {
                  final g = groups[i];
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                        toY: g.fatah, color: AppColors.fatah, width: 12),
                    BarChartRodData(
                        toY: g.hamas, color: AppColors.hamas, width: 12),
                    BarChartRodData(
                        toY: g.other, color: AppColors.undecided, width: 12),
                  ]);
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _Legend(),
          const Divider(height: 32),
          Text(strings.contenderTreatment,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            strings.contenderDisclaimer,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ...data.contenders.map((contender) => _ContenderRow(contender: contender)),
          const Divider(height: 32),
          Text(strings.latestPollInputs,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Metric(
                  label: strings.likelyTurnout,
                  value: '${poll.likelyTurnoutPct.toStringAsFixed(0)}%'),
              _Metric(
                  label: strings.t('Fatah', 'فتح'),
                  value: '${poll.fatahPct.toStringAsFixed(0)}%'),
              _Metric(
                  label: strings.t('Hamas', 'حماس'),
                  value: '${poll.hamasPct.toStringAsFixed(0)}%'),
              _Metric(
                  label: strings.t('Third parties', 'أطراف أخرى'),
                  value: '${poll.thirdPartiesPct.toStringAsFixed(0)}%'),
              _Metric(
                  label: strings.undecided,
                  value: '${poll.undecidedPct.toStringAsFixed(0)}%'),
              _Metric(
                  label: strings.t('MoE', 'هامش الخطأ'),
                  value: '+/-${poll.marginOfErrorPct.toStringAsFixed(1)}%'),
            ],
          ),
          const Divider(height: 32),
          Text(strings.confidenceTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            strings.relatedAttitude,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ...data.confidenceTrend.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ConfidenceRow(
                  period: row.period, hamas: row.hamasPct, fatah: row.fatahPct),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Poll: ${poll.source}, ${poll.dateRange}, n=${poll.sampleSize}, MoE +/-${poll.marginOfErrorPct.toStringAsFixed(1)}%',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black45),
          ),
          if (poll.sourceUrl.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(poll.sourceUrl,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.hamas)),
          ],
        ],
      ),
    );
  }
}

class _ChartGroup {
  final String label;
  final double fatah;
  final double hamas;
  final double other;
  _ChartGroup(this.label, this.fatah, this.hamas, this.other);
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    Widget dot(Color color, String label) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ]);
    return Wrap(spacing: 14, runSpacing: 8, children: [
      dot(AppColors.fatah, strings.t('Fatah', 'فتح')),
      dot(AppColors.hamas, strings.t('Hamas', 'حماس')),
      dot(AppColors.undecided, strings.otherUndecided),
    ]);
  }
}

class _ContenderRow extends StatelessWidget {
  final ContenderProfile contender;

  const _ContenderRow({required this.contender});

  @override
  Widget build(BuildContext context) {
    final hasStandaloneEstimate = contender.pollTreatment
      .toLowerCase()
      .contains('standalone');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: hasStandaloneEstimate
          ? AppColors.paper
            : AppColors.fatah.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
        border: Border(left: BorderSide(color: hasStandaloneEstimate ? AppColors.hamas : AppColors.fatah, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contender.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(contender.status, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(contender.pollTreatment, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Colors.black54, height: 1.3)),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.paper, borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _ConfidenceRow extends StatelessWidget {
  final String period;
  final double hamas;
  final double? fatah;
  const _ConfidenceRow({required this.period, required this.hamas, this.fatah});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
          width: 72,
          child: Text(period,
              style: const TextStyle(fontSize: 12, color: Colors.black54))),
      Expanded(
        child: SizedBox(
          height: 18,
          child: Row(children: [
            Expanded(
                flex: hamas.round().clamp(1, 100),
                child: Container(color: AppColors.hamas)),
            if (fatah != null)
              Expanded(
                  flex: fatah!.round().clamp(1, 100),
                  child: Container(color: AppColors.fatah)),
            Expanded(
                flex: (100 - hamas - (fatah ?? 0)).round().clamp(1, 100),
                child: const SizedBox()),
          ]),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        fatah != null ? 'Hamas $hamas / Fatah $fatah' : 'Hamas $hamas',
        style: const TextStyle(fontSize: 11, color: Colors.black54),
      ),
    ]);
  }
}
