import 'package:intl/intl.dart';

import '../services/analytics_service.dart';

class ExportSections {
  final bool journal;
  final bool ocd;
  final bool analytics;

  const ExportSections({
    this.journal = true,
    this.ocd = true,
    this.analytics = true,
  });

  ExportSections copyWith({bool? journal, bool? ocd, bool? analytics}) {
    return ExportSections(
      journal: journal ?? this.journal,
      ocd: ocd ?? this.ocd,
      analytics: analytics ?? this.analytics,
    );
  }

  bool get hasAny => journal || ocd || analytics;
}

class ExportReportOptions {
  final AnalyticsDateRange range;
  final DateTime? customStart;
  final DateTime? customEnd;
  final ExportSections sections;

  const ExportReportOptions({
    this.range = AnalyticsDateRange.thirty,
    this.customStart,
    this.customEnd,
    this.sections = const ExportSections(),
  });

  ExportReportOptions copyWith({
    AnalyticsDateRange? range,
    DateTime? customStart,
    DateTime? customEnd,
    ExportSections? sections,
  }) {
    return ExportReportOptions(
      range: range ?? this.range,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      sections: sections ?? this.sections,
    );
  }

  DateRangeFilter get filter => DateRangeFilter.resolve(
        range,
        customStart: customStart,
        customEnd: customEnd,
      );

  String get rangeLabel {
    switch (range) {
      case AnalyticsDateRange.seven:
        return 'Last 7 days';
      case AnalyticsDateRange.thirty:
        return 'Last 30 days';
      case AnalyticsDateRange.ninety:
        return 'Last 90 days';
      case AnalyticsDateRange.year:
        return 'Last year';
      case AnalyticsDateRange.allTime:
        return 'All time';
      case AnalyticsDateRange.custom:
        final start = customStart ?? DateTime.now();
        final end = customEnd ?? DateTime.now();
        final fmt = DateFormat('MMM d, yyyy');
        return '${fmt.format(start)} – ${fmt.format(end)}';
    }
  }

  String suggestedFilename() {
    final bounds = filter.displayBounds(
      customStart: customStart,
      customEnd: customEnd,
    );
    final fmt = DateFormat('yyyy-MM-dd');
    final start = fmt.format(bounds.$1);
    final end = fmt.format(bounds.$2);
    return 'patterns_report_${start}_to_$end.pdf';
  }

  int countMatchingEntries({
    required int journalCount,
    required int ocdCount,
  }) {
    var total = 0;
    if (sections.journal) total += journalCount;
    if (sections.ocd) total += ocdCount;
    if (sections.analytics && (journalCount > 0 || ocdCount > 0)) {
      total += 0; // analytics is derived, not a separate count
    }
    return total;
  }

  bool hasExportableContent({
    required int journalCount,
    required int ocdCount,
  }) {
    if (!sections.hasAny) return false;
    if (sections.analytics && (journalCount > 0 || ocdCount > 0)) return true;
    if (sections.journal && journalCount > 0) return true;
    if (sections.ocd && ocdCount > 0) return true;
    return false;
  }
}
