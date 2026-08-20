import 'package:flutter/material.dart';
import '../localization.dart';
import '../models/election_data.dart';
import '../theme.dart';
import '../widgets/vote_split_bar.dart';

class BaselineScreen extends StatelessWidget {
  final ElectionDataset data;
  const BaselineScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final r06 = data.result2006;
    final local = data.localElections2026;
    final strings = AppStrings.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.baselineTitle,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          VoteSplitBar(
            leftPct: r06.hamasPct,
            rightPct: r06.fatahPct,
            otherPct: r06.otherPct,
            leftLabel: strings.t('Hamas', 'حماس'),
            rightLabel: strings.t('Fatah', 'فتح'),
            leftColor: AppColors.hamas,
            rightColor: AppColors.fatah,
            otherColor: AppColors.undecided,
          ),
          const SizedBox(height: 12),
          Text(strings.t(
            "Hamas won 74 of 132 seats to Fatah's 45 on 71% turnout — a result the polling industry itself failed to call precisely.",
            'فازت حماس بـ74 مقعداً مقابل 45 لفتح مع مشاركة بلغت 71٪. هذه نتيجة لم تستطع صناعة الاستطلاعات توقعها بدقة.',
          ),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const Divider(height: 40),
          Text(strings.localTitle,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _StatCard(
                    value: '${local.nationalTurnoutPct.toStringAsFixed(0)}%',
                    label: strings.nationalTurnout)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    value:
                        '${local.westBankTurnoutPct.toStringAsFixed(0)}% / ${local.gazaTurnoutPct.toStringAsFixed(0)}%',
                    label: strings.regionTurnout)),
          ]),
          const SizedBox(height: 12),
          Text(local.note,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.alert.withValues(alpha: 0.06),
              border: const Border(
                  left: BorderSide(color: AppColors.alert, width: 3)),
            ),
            child: Text(strings.t(
              'Reading these together: use both as context, not as inputs to a single number.',
              'قراءة هذه البيانات معاً: استخدمها كسياق، لا كمدخل مباشر لرقم واحد.',
            ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.parchment, borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}
