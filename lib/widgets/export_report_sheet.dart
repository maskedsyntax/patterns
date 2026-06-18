import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../models/export_report_options.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/analytics_service.dart';
import '../services/pdf_report_service.dart';
import '../services/report_export_saver.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/platform.dart';

class ExportReportSheet extends ConsumerStatefulWidget {
  final ExportReportOptions initialOptions;

  const ExportReportSheet({
    super.key,
    this.initialOptions = const ExportReportOptions(),
  });

  static Future<void> show(
    BuildContext context, {
    ExportReportOptions initialOptions = const ExportReportOptions(),
  }) {
    final child = ExportReportSheet(initialOptions: initialOptions);
    if (kIsDesktop) {
      return showDialog<void>(
        context: context,
        useRootNavigator: true,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      );
    }
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => child,
    );
  }

  @override
  ConsumerState<ExportReportSheet> createState() => _ExportReportSheetState();
}

class _ExportReportSheetState extends ConsumerState<ExportReportSheet> {
  late AnalyticsDateRange _range;
  late DateTime _customStart;
  late DateTime _customEnd;
  late ExportSections _sections;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialOptions;
    _range = initial.range;
    _customStart = initial.customStart ?? DateTime.now().subtract(const Duration(days: 30));
    _customEnd = initial.customEnd ?? DateTime.now();
    _sections = initial.sections;
  }

  ExportReportOptions get _options => ExportReportOptions(
        range: _range,
        customStart: _customStart,
        customEnd: _customEnd,
        sections: _sections,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);

    final content = journalAsync.when(
      data: (journals) => ocdAsync.when(
        data: (ocds) => _buildContent(theme, journals, ocds),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildContent(theme, const [], const []),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildContent(theme, const [], const []),
    );

    if (kIsDesktop) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: content,
      );
    }

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerColor),
        ),
        child: SingleChildScrollView(child: content),
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    List<JournalEntry> journals,
    List<OcdEntry> ocds,
  ) {
    final filter = _options.filter;
    final filteredJournals = AnalyticsService.filterJournals(journals, filter);
    final filteredOcds = AnalyticsService.filterOcds(ocds, filter);
    final totalEntries = filteredJournals.length + filteredOcds.length;
    final canExport = _options.hasExportableContent(
      journalCount: filteredJournals.length,
      ocdCount: filteredOcds.length,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Export report',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              onPressed: _saving
                  ? null
                  : () => Navigator.of(context, rootNavigator: kIsDesktop).pop(),
              icon: const Icon(LineIcons.times),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Save a combined PDF of your journal, OCD log, and insights. '
          'You choose where to save it and whether to share it.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 20),
        Text(
          'Time window',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _RangeSelector(
          range: _range,
          onChanged: (range) => setState(() => _range = range),
        ),
        if (_range == AnalyticsDateRange.custom) ...[
          const SizedBox(height: 12),
          _CustomDateRow(
            label: 'Start',
            date: _customStart,
            onPick: (date) => setState(() {
              _customStart = date;
              if (_customEnd.isBefore(_customStart)) {
                _customEnd = _customStart;
              }
            }),
          ),
          const SizedBox(height: 8),
          _CustomDateRow(
            label: 'End',
            date: _customEnd,
            onPick: (date) => setState(() {
              _customEnd = date.isAfter(DateTime.now())
                  ? DateTime.now()
                  : date;
              if (_customEnd.isBefore(_customStart)) {
                _customStart = _customEnd;
              }
            }),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Include sections',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        _SectionToggle(
          label: 'Analytics summary',
          value: _sections.analytics,
          onChanged: (value) => setState(
            () => _sections = _sections.copyWith(analytics: value),
          ),
        ),
        _SectionToggle(
          label: 'Journal entries',
          value: _sections.journal,
          onChanged: (value) => setState(
            () => _sections = _sections.copyWith(journal: value),
          ),
        ),
        _SectionToggle(
          label: 'OCD events',
          value: _sections.ocd,
          onChanged: (value) => setState(
            () => _sections = _sections.copyWith(ocd: value),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$totalEntries entries in this range '
          '(${filteredJournals.length} journal, ${filteredOcds.length} OCD)',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        if (totalEntries > 500) ...[
          const SizedBox(height: 8),
          Text(
            'This report is large and may take a moment to generate.',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'This creates an unencrypted PDF. Save it somewhere private.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.45, fontSize: 13),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving || !canExport ? null : () => _saveReport(journals, ocds),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save PDF'),
          ),
        ),
        if (!canExport) ...[
          const SizedBox(height: 10),
          Text(
            !_sections.hasAny
                ? 'Select at least one section to export.'
                : 'No entries match this range and section selection.',
            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Future<void> _saveReport(
    List<JournalEntry> journals,
    List<OcdEntry> ocds,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: kIsDesktop);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      final bytes = await PdfReportService.generate(
        options: _options,
        journals: journals,
        ocds: ocds,
      );
      final saved = await ReportExportSaver.save(
        bytes,
        _options.suggestedFilename(),
      );

      // Reset the busy state before popping. If pop succeeds the widget
      // unmounts and this no-ops; if pop fails for any reason the spinner
      // still clears so the sheet never gets stuck mid-save.
      if (mounted) setState(() => _saving = false);

      if (saved) {
        navigator.pop();
        showAppSnackBar(
          context,
          'Report saved',
          type: ToastType.success,
          messenger: messenger,
        );
      }
    } catch (error, stack) {
      debugPrint('PDF export failed: $error\n$stack');
      if (mounted) setState(() => _saving = false);
      showAppSnackBar(
        context,
        'Could not create report',
        type: ToastType.error,
        messenger: messenger,
      );
    }
  }
}

class _RangeSelector extends StatelessWidget {
  final AnalyticsDateRange range;
  final ValueChanged<AnalyticsDateRange> onChanged;

  const _RangeSelector({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in AnalyticsDateRange.values)
          _RangeChip(
            label: _labelFor(option),
            selected: range == option,
            onTap: () => onChanged(option),
            theme: theme,
          ),
      ],
    );
  }

  static String _labelFor(AnalyticsDateRange range) {
    switch (range) {
      case AnalyticsDateRange.seven:
        return '7D';
      case AnalyticsDateRange.thirty:
        return '30D';
      case AnalyticsDateRange.ninety:
        return '90D';
      case AnalyticsDateRange.year:
        return 'Year';
      case AnalyticsDateRange.allTime:
        return 'All';
      case AnalyticsDateRange.custom:
        return 'Custom';
    }
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? theme.colorScheme.onPrimary
                : AppTheme.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CustomDateRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _CustomDateRow({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('MMM d, yyyy');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              fmt.format(date),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(LineIcons.calendar, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SectionToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SectionToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
