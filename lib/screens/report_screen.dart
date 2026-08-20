import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../localization.dart';
import '../models/election_data.dart';
import '../services/report_service.dart';
import '../theme.dart';

class ReportScreen extends StatefulWidget {
  final ElectionDataset data;
  const ReportScreen({super.key, required this.data});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _report = 'full';
  String? _city;
  bool _printing = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cities = widget.data.prospectiveLists
        .expand((list) => list.candidates)
        .map((candidate) => candidate.origin)
        .where((origin) => origin.isNotEmpty && !origin.toLowerCase().contains('not yet'))
        .toSet()
        .toList()
      ..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.reportCenter, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(strings.reportSubtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          _ReportChoice(title: strings.fullBrief, icon: Icons.summarize, selected: _report == 'full', onTap: () => setState(() => _report = 'full')),
          _ReportChoice(title: strings.partyReport, icon: Icons.groups, selected: _report == 'parties', onTap: () => setState(() => _report = 'parties')),
          _ReportChoice(title: strings.candidateReport, icon: Icons.person_search, selected: _report == 'candidates', onTap: () => setState(() => _report = 'candidates')),
          _ReportChoice(title: strings.cityReport, icon: Icons.location_city, selected: _report == 'city', onTap: () => setState(() => _report = 'city')),
          _ReportChoice(title: strings.sourceReport, icon: Icons.source, selected: _report == 'sources', onTap: () => setState(() => _report = 'sources')),
          if (_report == 'city') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _city,
              decoration: InputDecoration(labelText: strings.chooseCity),
              items: cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
              onChanged: (value) => setState(() => _city = value),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(8)),
            child: Text(strings.leadershipNote, style: const TextStyle(fontSize: 11, color: AppColors.ink, height: 1.35)),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _printing || (_report == 'city' && _city == null) ? null : _print,
            icon: _printing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.print),
            label: Text(strings.printReport),
          ),
          if (_report == 'city' && cities.isEmpty) ...[
            const SizedBox(height: 12),
            Text(strings.noCityData, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Future<void> _print() async {
    setState(() => _printing = true);
    final strings = AppStrings.of(context);
    final titles = {
      'full': strings.fullBrief,
      'parties': strings.partyReport,
      'candidates': strings.candidateReport,
      'city': '${strings.cityReport}: ${_city ?? ''}',
      'sources': strings.sourceReport,
    };
    try {
      final bytes = await ReportService.buildReport(
        data: widget.data,
        title: titles[_report]!,
        reportKind: _report,
        city: _report == 'city' ? _city : null,
        arabic: strings.isArabic,
      );
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ReportPreviewScreen(
          title: titles[_report]!,
          bytes: bytes,
        ),
      ));
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }
}

class ReportPreviewScreen extends StatelessWidget {
  final String title;
  final Uint8List bytes;

  const ReportPreviewScreen({super.key, required this.title, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (_) async => bytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: 'election_report.pdf',
      ),
    );
  }
}

class _ReportChoice extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ReportChoice({required this.title, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: selected ? AppColors.ink : AppColors.paper,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  Icon(icon, color: selected ? Colors.white : AppColors.hamas),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600))),
                  Icon(selected ? Icons.check_circle : Icons.chevron_right, color: selected ? const Color(0xFFE8DCC0) : Colors.black38),
                ],
              ),
            ),
          ),
        ),
      );
}
