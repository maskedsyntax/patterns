import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../models/export_report_options.dart';
import '../providers/providers.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/export_report_sheet.dart';
import '../widgets/platform.dart';
import '../widgets/window_controls.dart';

enum _InsightTab { overview, thoughts, urges, erp }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsDateRange _range = AnalyticsDateRange.thirty;
  _InsightTab _tab = _InsightTab.overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);
    final delays = ref.watch(delaySessionProvider).asData?.value ?? const [];
    final erp = ref.watch(erpExerciseSessionProvider).asData?.value ?? const [];
    final steps = ref.watch(exposureStepProvider).asData?.value ?? const [];
    final responses =
        ref.watch(responsePreventionProvider).asData?.value ?? const [];
    final surfs = ref.watch(urgeSurfProvider).asData?.value ?? const [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
            ),
          ),
          child: AppBar(
            toolbarHeight: 60,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Insights',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            actions: [
              if (isPdfExportSupported)
                IconButton(
                  tooltip: 'Export report',
                  onPressed: () => ExportReportSheet.show(
                    context,
                    initialOptions: ExportReportOptions(range: _range),
                  ),
                  icon: const Icon(LineIcons.fileExport, size: 18),
                ),
              const WindowControls(),
            ],
          ),
        ),
      ),
      body: journalAsync.when(
        data: (journals) => ocdAsync.when(
          data: (ocds) {
            final summary = AnalyticsService.buildRecoveryDashboard(
              journals: journals,
              ocds: ocds,
              delaySessions: delays,
              erpSessions: erp,
              exposureSteps: steps,
              responsePreventionLogs: responses,
              urgeSurfSessions: surfs,
              range: _range,
            );
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 24,
                  ),
                  children: [
                    // Title and Range Selector row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Insights',
                                style: TextStyle(
                                  fontFamily: AppTheme.displayFamily,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Understand your patterns. Celebrate your growth.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _RangeSelector(
                          range: _range,
                          onChanged: (range) => setState(() => _range = range),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _TabBar(
                      tab: _tab,
                      onChanged: (tab) => setState(() => _tab = tab),
                    ),
                    const SizedBox(height: 24),
                    switch (_tab) {
                      _InsightTab.overview => _OverviewTab(summary: summary),
                      _InsightTab.thoughts => _ThoughtsTab(summary: summary),
                      _InsightTab.urges => _UrgesTab(summary: summary),
                      _InsightTab.erp => _ErpTab(summary: summary),
                    },
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final _InsightTab tab;
  final ValueChanged<_InsightTab> onChanged;

  const _TabBar({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (final t in _InsightTab.values) ...[
          if (t != _InsightTab.values.first) const SizedBox(width: 8),
          ChoiceChip(
            label: Text(switch (t) {
              _InsightTab.overview => 'Overview',
              _InsightTab.thoughts => 'Thoughts',
              _InsightTab.urges => 'Urges',
              _InsightTab.erp => 'ERP',
            }),
            selected: tab == t,
            onSelected: (_) => onChanged(t),
            selectedColor: AppTheme.warmYellow,
            backgroundColor: Colors.transparent,
            elevation: 0,
            pressElevation: 0,
            side: BorderSide(
              color: tab == t ? AppTheme.warmYellow : theme.dividerColor,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: tab == t
                  ? Colors.black
                  : theme.colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
        ],
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final AnalyticsDateRange range;
  final ValueChanged<AnalyticsDateRange> onChanged;

  const _RangeSelector({required this.range, required this.onChanged});

  static const _options = <(AnalyticsDateRange, String)>[
    (AnalyticsDateRange.seven, '7d'),
    (AnalyticsDateRange.thirty, '30d'),
    (AnalyticsDateRange.ninety, '90d'),
    (AnalyticsDateRange.year, '1y'),
    (AnalyticsDateRange.allTime, 'All'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (value, label) in _options) ...[
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: InkWell(
              onTap: () => onChanged(value),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: range == value
                      ? Colors.transparent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: range == value
                        ? AppTheme.warmYellow
                        : theme.dividerColor,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: range == value
                        ? AppTheme.warmYellow
                        : theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Icon(
            LineIcons.calendar,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            size: 16,
          ),
        ),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _OverviewTab({required this.summary});

  List<double> _plotData(List<DashboardPoint> trend) {
    if (trend.isEmpty) return [0.0, 0.0];
    if (trend.length == 1) return [trend[0].value, trend[0].value];
    return trend.map((p) => p.value).toList();
  }

  Color _deltaColor(InsightDelta delta) {
    switch (delta.tone) {
      case InsightTone.positive:
        return Colors.green;
      case InsightTone.negative:
        return Colors.red;
      case InsightTone.neutral:
        return Colors.grey;
    }
  }

  String _deltaText(InsightDelta delta, {String suffix = ''}) {
    if (delta.value == 0) return 'Unchanged';
    final sign = delta.value > 0 ? '↑' : '↓';
    return '$sign ${delta.value.abs().toStringAsFixed(suffix.isNotEmpty ? 1 : 0)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic calculations for mood from SQLite trend data
    final hasMood = summary.moodTrend.isNotEmpty;
    final mood = hasMood
        ? summary.moodTrend.map((p) => p.value).reduce((a, b) => a + b) /
            summary.moodTrend.length
        : 0.0;

    double moodDeltaVal = 0.0;
    if (summary.moodTrend.length >= 2) {
      moodDeltaVal = summary.moodTrend.last.value - summary.moodTrend.first.value;
    }

    final moodDeltaText = moodDeltaVal == 0
        ? 'Unchanged'
        : '${moodDeltaVal > 0 ? '↑' : '↓'} ${moodDeltaVal.abs().toStringAsFixed(1)}';
    final moodDeltaColor = moodDeltaVal == 0
        ? Colors.grey
        : (moodDeltaVal > 0 ? Colors.green : Colors.red);

    // Get consistency heatmap dots
    final heatmap = summary.consistencyHeatmap;
    final dotsList = heatmap.isEmpty
        ? List.generate(20, (i) => i < 15) // Fallback indicators
        : (heatmap.length > 20 ? heatmap.sublist(heatmap.length - 20) : heatmap);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid of 4 stats cards
        Row(
          children: [
            Expanded(
              child: _OverviewStatCard(
                title: 'Recovery score',
                value: '${summary.recoveryScore}',
                suffix: '/100 pts',
                trend: _deltaText(summary.scoreDelta),
                trendLabel: 'from last range',
                sparklineData: _plotData(summary.scoreTrend),
                color: AppTheme.warmYellow,
                trendColor: _deltaColor(summary.scoreDelta),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _OverviewStatCard(
                title: 'Avg urge',
                value: summary.averageUrge > 0
                    ? summary.averageUrge.toStringAsFixed(1)
                    : '0.0',
                suffix: '/10',
                trend: _deltaText(summary.urgeDelta),
                trendLabel: 'from last range',
                sparklineData: _plotData(summary.urgeTrend),
                color: AppTheme.warmYellow,
                trendColor: _deltaColor(summary.urgeDelta),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _OverviewStatCard(
                title: 'ERP practice',
                value: '${summary.erpPracticeCount}',
                trend: _deltaText(summary.erpDelta),
                trendLabel: 'from last range',
                sparklineData: _plotData(summary.erpTrend),
                color: AppTheme.warmYellow,
                trendColor: _deltaColor(summary.erpDelta),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _OverviewStatCard(
                title: 'Consistency',
                value: '${summary.consistencyPercent}',
                suffix: '%',
                trend: summary.consistencyPercent > 0 ? 'Active practice' : 'No practice',
                trendLabel: 'this cycle',
                sparklineData: _plotData(summary.erpTrend),
                color: AppTheme.warmYellow,
                trendColor: summary.consistencyPercent > 0 ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Row of 2 panels: Mood and Top Themes
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Mood (avg)
            Expanded(
              flex: 3,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: theme.cardTheme.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood (avg)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            hasMood ? mood.toStringAsFixed(1) : 'N/A',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (hasMood)
                            Text(
                              '/10',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          const SizedBox(width: 16),
                          if (hasMood && moodDeltaVal != 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: moodDeltaColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    moodDeltaVal > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                    color: moodDeltaColor,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    moodDeltaVal.abs().toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: moodDeltaColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasMood ? '$moodDeltaText last range' : 'Journal daily to track mood',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _Sparkline(data: _plotData(summary.moodTrend), color: AppTheme.warmYellow),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Right: Top Themes
            Expanded(
              flex: 2,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: theme.cardTheme.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top themes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (summary.topThemes.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Text(
                              'Themes appear as you journal\nand track exposures.',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else ...[
                        for (final themeSummary in summary.topThemes.take(4)) ...[
                          _ThemeProgressBar(
                            label: themeSummary.label,
                            count: themeSummary.count,
                            maxCount: summary.topThemes.isEmpty
                                ? 0
                                : summary.topThemes.map((t) => t.count).reduce((a, b) => a > b ? a : b),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bottom card: Active days
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active days',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary.activeDays} days with activity in this range',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < dotsList.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotsList[i]
                                ? AppTheme.warmYellow
                                : Colors.transparent,
                            border: Border.all(
                              color: dotsList[i]
                                  ? AppTheme.warmYellow
                                  : theme.colorScheme.onSurface.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThoughtsTab extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _ThoughtsTab({required this.summary});

  List<double> _plotData(List<DashboardPoint> trend) {
    if (trend.isEmpty) return [0.0, 0.0];
    if (trend.length == 1) return [trend[0].value, trend[0].value];
    return trend.map((p) => p.value).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thoughtsData = _plotData(summary.moodTrend); // Fallback to mood mapping if thoughts trend is local
    final themesData = [summary.topThemes.length.toDouble(), summary.topThemes.length.toDouble()];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _OverviewStatCard(
                title: 'Thought logs',
                value: '${summary.thoughts}',
                trend: summary.thoughts > 0 ? 'Active logs' : 'No logs',
                trendLabel: 'in this range',
                sparklineData: thoughtsData,
                color: AppTheme.warmYellow,
                trendColor: summary.thoughts > 0 ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _OverviewStatCard(
                title: 'Themes found',
                value: '${summary.topThemes.length}',
                trend: summary.topThemes.isNotEmpty ? 'Analysis active' : 'No themes yet',
                trendLabel: 'detected automatically',
                sparklineData: themesData,
                color: AppTheme.warmYellow,
                trendColor: summary.topThemes.isNotEmpty ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: theme.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Themes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                summary.topThemes.isEmpty
                    ? Text(
                        'No themes yet',
                        style: TextStyle(color: AppTheme.textSecondary),
                      )
                    : Column(
                        children: [
                          for (final themeSummary in summary.topThemes) ...[
                            _ThemeProgressBar(
                              label: themeSummary.label,
                              count: themeSummary.count,
                              maxCount: summary.topThemes.map((t) => t.count).reduce((a, b) => a > b ? a : b),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UrgesTab extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _UrgesTab({required this.summary});

  List<double> _plotData(List<DashboardPoint> trend) {
    if (trend.isEmpty) return [0.0, 0.0];
    if (trend.length == 1) return [trend[0].value, trend[0].value];
    return trend.map((p) => p.value).toList();
  }

  Color _deltaColor(InsightDelta delta) {
    switch (delta.tone) {
      case InsightTone.positive:
        return Colors.green;
      case InsightTone.negative:
        return Colors.red;
      case InsightTone.neutral:
        return Colors.grey;
    }
  }

  String _deltaText(InsightDelta delta, {String suffix = ''}) {
    if (delta.value == 0) return 'Unchanged';
    final sign = delta.value > 0 ? '↑' : '↓';
    return '$sign ${delta.value.abs().toStringAsFixed(suffix.isNotEmpty ? 1 : 0)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OverviewStatCard(
            title: 'Compulsions',
            value: '${summary.compulsions}',
            trend: summary.compulsions > 0 ? 'Logs present' : 'No logs',
            trendLabel: 'in this range',
            sparklineData: _plotData(summary.urgeTrend),
            color: AppTheme.warmYellow,
            trendColor: summary.compulsions > 0 ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _OverviewStatCard(
            title: 'Avg intensity',
            value: summary.averageUrge.toStringAsFixed(1),
            suffix: '/10',
            trend: _deltaText(summary.urgeDelta),
            trendLabel: 'from last range',
            sparklineData: _plotData(summary.urgeTrend),
            color: AppTheme.warmYellow,
            trendColor: _deltaColor(summary.urgeDelta),
          ),
        ),
      ],
    );
  }
}

class _ErpTab extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _ErpTab({required this.summary});

  List<double> _plotData(List<DashboardPoint> trend) {
    if (trend.isEmpty) return [0.0, 0.0];
    if (trend.length == 1) return [trend[0].value, trend[0].value];
    return trend.map((p) => p.value).toList();
  }

  Color _deltaColor(InsightDelta delta) {
    switch (delta.tone) {
      case InsightTone.positive:
        return Colors.green;
      case InsightTone.negative:
        return Colors.red;
      case InsightTone.neutral:
        return Colors.grey;
    }
  }

  String _deltaText(InsightDelta delta, {String suffix = ''}) {
    if (delta.value == 0) return 'Unchanged';
    final sign = delta.value > 0 ? '↑' : '↓';
    return '$sign ${delta.value.abs().toStringAsFixed(suffix.isNotEmpty ? 1 : 0)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OverviewStatCard(
            title: 'Practice sessions',
            value: '${summary.erpPracticeCount}',
            trend: _deltaText(summary.erpDelta),
            trendLabel: 'from last range',
            sparklineData: _plotData(summary.erpTrend),
            color: AppTheme.warmYellow,
            trendColor: _deltaColor(summary.erpDelta),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _OverviewStatCard(
            title: 'Consistency',
            value: '${summary.consistencyPercent}',
            suffix: '%',
            trend: summary.consistencyPercent > 0 ? 'Active practice' : 'No practice',
            trendLabel: 'this cycle',
            sparklineData: _plotData(summary.erpTrend),
            color: AppTheme.warmYellow,
            trendColor: summary.consistencyPercent > 0 ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _OverviewStatCard(
            title: 'Recovery score',
            value: '${summary.recoveryScore}',
            suffix: '/100 pts',
            trend: _deltaText(summary.scoreDelta),
            trendLabel: 'from last range',
            sparklineData: _plotData(summary.scoreTrend),
            color: AppTheme.warmYellow,
            trendColor: _deltaColor(summary.scoreDelta),
          ),
        ),
      ],
    );
  }
}

/// A premium card showing a large number stat, relative trend indicator,
/// and a beautifully drawn CustomPaint sparkline chart.
class _OverviewStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final String trend;
  final String trendLabel;
  final List<double> sparklineData;
  final Color color;
  final Color trendColor;

  const _OverviewStatCard({
    required this.title,
    required this.value,
    this.suffix,
    required this.trend,
    required this.trendLabel,
    required this.sparklineData,
    required this.color,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    suffix!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trendLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Sparkline(data: sparklineData, color: color),
          ],
        ),
      ),
    );
  }
}

/// Horizontal progress bar representing themes counts
class _ThemeProgressBar extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;

  const _ThemeProgressBar({
    required this.label,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double percent = maxCount > 0 ? count / maxCount : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.06),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.warmYellow),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// A beautifully rendering sparkline component with cubic curves
class _Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;

  const _Sparkline({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);
    
    double minVal = data.reduce((a, b) => a < b ? a : b);
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == minVal) {
      maxVal += 1.0;
    }
    final double range = maxVal - minVal;

    for (var i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height - ((data[i] - minVal) / range) * (size.height - 4) - 2;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final double prevX = (i - 1) * stepX;
        final double prevY = size.height - ((data[i - 1] - minVal) / range) * (size.height - 4) - 2;
        final double cx1 = prevX + stepX / 2;
        final double cy1 = prevY;
        final double cx2 = prevX + stepX / 2;
        final double cy2 = y;
        path.cubicTo(cx1, cy1, cx2, cy2, x, y);
      }
    }

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.18),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
