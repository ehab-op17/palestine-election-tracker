import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization.dart';
import '../models/election_data.dart';
import '../theme.dart';

class NewsScreen extends StatelessWidget {
  final ElectionDataset data;

  const NewsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final signals = data.newsSignals;
    final sourceTypes = data.publicSources.map((source) => source.type).toSet();
    final strings = AppStrings.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.newsSignals,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            strings.newsDisclaimer,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.hub_outlined, color: Color(0xFFE8DCC0)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data.publicSources.length} sources, ${sourceTypes.length} source roles',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${signals.length} news signals are available to the model. They widen or narrow uncertainty; they do not replace polling.',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (signals.isEmpty)
            const _EmptyState()
          else
            ...signals.map((signal) => _SignalCard(signal: signal)),
          const Divider(height: 32),
          Text(strings.coverageMix,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Palestinian outlets are included for local context; official and research sources anchor facts and polling.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _SourceLegend(),
          const SizedBox(height: 10),
          ...data.publicSources.map((source) => _SourceRow(source: source)),
        ],
      ),
    );
  }
}

class _SourceLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppStrings.of(context).t(
          'Source roles: polling informs vote-share inputs; official sources anchor dates and procedures; local news supplies risk signals; historical results provide baseline context.',
          'أدوار المصادر: الاستطلاعات توفر مدخلات نسب التصويت، والمصادر الرسمية تثبت المواعيد والإجراءات، والأخبار المحلية توفر إشارات المخاطر، والنتائج التاريخية تقدم سياقاً أساسياً.',
        ),
        style:
            const TextStyle(fontSize: 11, color: AppColors.ink, height: 1.35),
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  final NewsSignal signal;

  const _SignalCard({required this.signal});

  @override
  Widget build(BuildContext context) {
    final color = switch (signal.category) {
      'coalition' => AppColors.hamas,
      'official' => AppColors.fatah,
      'access' => AppColors.alert,
      'turnout' => const Color(0xFF516B8B),
      _ => Colors.black54,
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(signal.source,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black45)),
              ),
              Text(signal.publishedAt,
                  style: const TextStyle(fontSize: 10, color: Colors.black38)),
            ],
          ),
          const SizedBox(height: 5),
          _Pill(
              label: signal.reviewStatus == 'reviewed'
                  ? AppStrings.of(context).reviewed
                  : signal.reviewStatus == 'auto_reviewed'
                      ? AppStrings.of(context).autoReviewed
                      : AppStrings.of(context).unreviewed),
          const SizedBox(height: 6),
          Text(signal.title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, height: 1.25)),
          if (signal.summary.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(signal.summary,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54, height: 1.35)),
          ],
          if (signal.affectedEntities.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${AppStrings.of(context).affectedEntities}: ${signal.affectedEntities.join(', ')}',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _Pill(label: signal.category),
              const SizedBox(width: 8),
              _Pill(
                  label:
                      '${AppStrings.of(context).impact} ${signal.impactScore.toStringAsFixed(1)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final PublicSource source;

  const _SourceRow({required this.source});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: source.url.isEmpty
              ? null
              : () => launchUrl(Uri.parse(source.url),
                  mode: LaunchMode.externalApplication),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(source.name,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(source.type,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.hamas)),
                      const SizedBox(height: 4),
                      Text(source.useFor,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              height: 1.3)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new, size: 16, color: Colors.black45),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.parchment, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: const TextStyle(fontSize: 10, color: Colors.black54)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.paper, borderRadius: BorderRadius.circular(6)),
      child: const Text(
        'No high-confidence election-relevant news signals are in the current dataset.',
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }
}
