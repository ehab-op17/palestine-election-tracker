import 'dart:typed_data';

import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../models/election_data.dart';

class ReportService {
  static Future<Uint8List> buildReport({
    required ElectionDataset data,
    required String title,
    required String reportKind,
    String? city,
    required bool arabic,
  }) async {
    String text(String value) =>
        arabic ? ArabicReshaper.instance.reshape(value) : value;
    final regularFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Arial.ttf'));
    final boldFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Arial-Bold.ttf'));
    final reportTheme =
        pw.ThemeData.withFont(base: regularFont, bold: boldFont);
    final document = pw.Document();
    final candidates = <MapEntry<String, CandidateProfile>>[];
    for (final list in data.prospectiveLists) {
      for (final candidate in list.candidates) {
        if (city == null || city.isEmpty || candidate.origin == city) {
          candidates.add(MapEntry(list.name, candidate));
        }
      }
    }

    final reportBody = <pw.Widget>[
      pw.Header(level: 0, child: pw.Text(text(title))),
      pw.Text(text(
          '${arabic ? 'تاريخ البيانات' : 'Data date'}: ${data.generatedAt.toIso8601String()} | ${data.latestPoll.source}')),
      pw.SizedBox(height: 16),
      pw.Text(text(arabic
          ? 'هذا التقرير مبني على بيانات منسوبة للمصادر. المعلومات غير الرسمية قد تتغير.'
          : 'This report is built from attributed public data. Non-official information may change.')),
      pw.SizedBox(height: 16),
    ];

    if (reportKind == 'full') {
      reportBody.addAll([
        pw.Text(text(arabic ? 'أحدث استطلاع' : 'Latest poll'),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(text(
            '${data.latestPoll.source}: ${arabic ? 'فتح' : 'Fatah'} ${data.latestPoll.fatahPct}% | ${arabic ? 'حماس' : 'Hamas'} ${data.latestPoll.hamasPct}% | ${arabic ? 'أخرى' : 'Other'} ${data.latestPoll.otherPct}%')),
        pw.Text(text(
            '${arabic ? 'المشاركة المتوقعة' : 'Likely turnout'}: ${data.latestPoll.likelyTurnoutPct}% | ${arabic ? 'هامش الخطأ' : 'MoE'}: +/-${data.latestPoll.marginOfErrorPct}%')),
        pw.SizedBox(height: 12),
      ]);
    }

    if (reportKind == 'full' || reportKind == 'parties') {
      reportBody.add(pw.TableHelper.fromTextArray(
        headers: [
          text(arabic ? 'القائمة' : 'List'),
          text(arabic ? 'الحالة' : 'Status'),
          text(arabic ? 'القيادة / المرجع' : 'Leadership / reference'),
          text(arabic ? 'الأحزاب المرتبطة' : 'Related parties')
        ],
        data: data.prospectiveLists
            .map((list) => [
                  text(list.name),
                  text(list.status),
                  text(list.leader),
                  text(list.relatedParties.join(', '))
                ])
            .toList(),
      ));
      reportBody.add(pw.SizedBox(height: 16));
    }

    if (reportKind == 'full' ||
        reportKind == 'candidates' ||
        reportKind == 'city') {
      reportBody.add(pw.TableHelper.fromTextArray(
        headers: [
          text(arabic ? 'القائمة' : 'List'),
          text(arabic ? 'المرشح' : 'Candidate'),
          text(arabic ? 'المكان' : 'Origin'),
          text(arabic ? 'الحالة' : 'Status'),
          text(arabic ? 'التقدير' : 'Estimate')
        ],
        data: candidates
            .map((entry) => [
                  text(entry.key),
                  text(entry.value.name),
                  text(entry.value.origin),
                  text(entry.value.status),
                  text(entry.value.voteEstimatePct?.toStringAsFixed(1) ??
                      (arabic ? 'غير متوفر' : 'Not available'))
                ])
            .toList(),
      ));
      reportBody.add(pw.SizedBox(height: 20));
    }

    if (reportKind == 'full' || reportKind == 'sources') {
      reportBody.addAll([
        pw.Text(text(arabic ? 'المصادر' : 'Sources'),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ...data.publicSources
            .map((source) => pw.Text(text('${source.name}: ${source.useFor}'))),
      ]);
    }

    document.addPage(
      pw.MultiPage(
        theme: reportTheme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Directionality(
            textDirection: arabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Column(children: reportBody),
          ),
        ],
      ),
    );

    return document.save();
  }
}
