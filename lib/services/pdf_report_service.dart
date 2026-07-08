import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/export_report_options.dart';
import '../models/models.dart';
import '../widgets/rich_journal.dart';
import 'analytics_service.dart';

class PdfReportService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  static Future<pw.ThemeData> _theme() async {
    _regularFont ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-Regular.ttf'),
    );
    _boldFont ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-Bold.ttf'),
    );

    return pw.ThemeData.withFont(base: _regularFont!, bold: _boldFont!);
  }

  static Future<Uint8List> generate({
    required ExportReportOptions options,
    required List<JournalEntry> journals,
    required List<OcdEntry> ocds,
  }) async {
    final filter = options.filter;
    final filteredJournals = AnalyticsService.filterJournals(journals, filter)
      ..sort((a, b) => a.date.compareTo(b.date));
    final filteredOcds = AnalyticsService.filterOcds(ocds, filter)
      ..sort((a, b) => a.datetime.compareTo(b.datetime));
    final summary = AnalyticsService.buildSummary(
      journals: filteredJournals,
      ocds: filteredOcds,
      filter: filter,
      range: options.range,
    );

    final bounds = filter.displayBounds(
      customStart: options.customStart,
      customEnd: options.customEnd,
    );
    final dateFmt = DateFormat('MMM d, yyyy');
    final timeFmt = DateFormat('MMM d, yyyy h:mm a');
    final generatedAt = DateFormat('MMM d, yyyy h:mm a').format(DateTime.now());
    final theme = await _theme();

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(48),
        theme: theme,
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text(
              'Patterns',
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey600,
                letterSpacing: 1.2,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Personal Report',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '${options.rangeLabel}\n'
              '${dateFmt.format(bounds.$1)} – ${dateFmt.format(bounds.$2)}\n'
              'Generated $generatedAt',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 20),
          ];

          if (options.sections.analytics) {
            widgets.addAll(_analyticsSection(summary));
          }
          if (options.sections.journal) {
            widgets.addAll(_journalSection(filteredJournals, dateFmt));
          }
          if (options.sections.ocd) {
            widgets.addAll(_ocdSection(filteredOcds, timeFmt));
          }

          widgets.addAll([
            pw.SizedBox(height: 32),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 12),
            pw.Text(
              'This report contains personal notes created in Patterns for self-reflection. '
              'It is not medical advice and does not replace care from a qualified clinician.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ]);

          return widgets;
        },
      ),
    );

    return doc.save();
  }

  static List<pw.Widget> _analyticsSection(AnalyticsSummary summary) {
    return [
      _sectionTitle('Analytics Summary'),
      pw.SizedBox(height: 10),
      _statRow('Journal entries', '${summary.journalCount}'),
      _statRow('OCD events', '${summary.ocdCount}'),
      _statRow('Average distress', summary.averageDistress.toStringAsFixed(1)),
      _statRow('Obsessions', '${summary.obsessions}'),
      _statRow('Compulsions', '${summary.compulsions}'),
      pw.SizedBox(height: 8),
      pw.Text(
        summary.journalingConsistencyNote,
        style: const pw.TextStyle(fontSize: 11),
      ),
      pw.SizedBox(height: 24),
    ];
  }

  static List<pw.Widget> _journalSection(
    List<JournalEntry> entries,
    DateFormat dateFmt,
  ) {
    final widgets = <pw.Widget>[
      _sectionTitle('Journal Entries'),
      pw.SizedBox(height: 10),
    ];

    if (entries.isEmpty) {
      widgets.add(
        pw.Text(
          'No journal entries in this range.',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
        ),
      );
    } else {
      for (final entry in entries) {
        final date = DateTime.parse(entry.date);
        widgets.addAll([
          pw.Text(
            dateFmt.format(date),
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          _markdownText(entry.content, fontSize: 11),
          pw.SizedBox(height: 16),
        ]);
      }
    }

    widgets.add(pw.SizedBox(height: 8));
    return widgets;
  }

  static List<pw.Widget> _ocdSection(
    List<OcdEntry> entries,
    DateFormat timeFmt,
  ) {
    final widgets = <pw.Widget>[
      _sectionTitle('OCD Events'),
      pw.SizedBox(height: 10),
    ];

    if (entries.isEmpty) {
      widgets.add(
        pw.Text(
          'No OCD events in this range.',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
        ),
      );
    } else {
      for (final entry in entries) {
        final typeLabel = entry.type == OcdType.obsession
            ? 'Obsession'
            : 'Compulsion';
        widgets.addAll([
          pw.Text(
            '${timeFmt.format(entry.datetime)} · $typeLabel · Distress ${entry.distressLevel}/10',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            entry.type == OcdType.obsession ? 'Thought' : 'Urge',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Text(entry.content, style: const pw.TextStyle(fontSize: 11)),
          if (entry.response.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Response: ${entry.response}',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
          if (entry.actionTaken != null && entry.actionTaken!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Action taken: ${entry.actionTaken}',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
          pw.SizedBox(height: 16),
        ]);
      }
    }

    return widgets;
  }

  /// Renders a journal entry's rich text as styled PDF text. Bold uses the
  /// theme's bold font; italic falls back to regular (no italic font is
  /// bundled) but the text content is always rendered cleanly.
  static pw.Widget _markdownText(String content, {required double fontSize}) {
    final runs = richRunsFromStored(content);
    return pw.RichText(
      text: pw.TextSpan(
        style: pw.TextStyle(fontSize: fontSize),
        children: [
          for (final run in runs)
            pw.TextSpan(
              text: run.text,
              style: pw.TextStyle(
                fontWeight: run.bold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
                fontStyle: run.italic
                    ? pw.FontStyle.italic
                    : pw.FontStyle.normal,
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    );
  }

  static pw.Widget _statRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
