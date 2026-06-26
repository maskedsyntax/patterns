import 'dart:async';

import 'package:animations/animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../../models/export_report_options.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/analytics_service.dart';
import '../../services/review_prompt.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/export_report_sheet.dart';
import '../../widgets/platform.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsDateRange _range = AnalyticsDateRange.thirty;
  AnalyticsDateRange _previousRange = AnalyticsDateRange.thirty;
  Timer? _lingerTimer;

  @override
  void initState() {
    super.initState();
    _lingerTimer = Timer(const Duration(seconds: 20), () {
      if (!mounted) return;
      ReviewPromptService.maybeRequestReview(
        context,
        trigger: ReviewTrigger.analyticsLinger,
      );
    });
  }

  @override
  void dispose() {
    _lingerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);
    final filter = DateRangeFilter.fromPreset(_range);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
          children: [
            FadeSlideIn(
              child: Row(
                children: [
                  Expanded(child: Text('Insights', style: _screenTitle(theme))),
                  if (isPdfExportSupported)
                    IconButton(
                      tooltip: 'Export report',
                      onPressed: () => ExportReportSheet.show(
                        context,
                        initialOptions: ExportReportOptions(range: _range),
                      ),
                      icon: const Icon(LineIcons.fileExport),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              delay: const Duration(milliseconds: 60),
              child: _RangeSelector(
                range: _range,
                onChanged: (range) {
                  if (range == _range) return;
                  setState(() {
                    _previousRange = _range;
                    _range = range;
                  });
                },
              ),
            ),
            const SizedBox(height: 22),
            journalAsync.when(
              data: (journals) => ocdAsync.when(
                data: (ocds) {
                  final filteredJournals = AnalyticsService.filterJournals(
                    journals,
                    filter,
                  );
                  final filteredOcds = AnalyticsService.filterOcds(
                    ocds,
                    filter,
                  );
                  final avgDistress = AnalyticsService.averageDistress(
                    filteredOcds,
                  );
                  final obsessions = AnalyticsService.obsessionCount(
                    filteredOcds,
                  );
                  final compulsions = AnalyticsService.compulsionCount(
                    filteredOcds,
                  );

                  final goingForward = _range.index >= _previousRange.index;
                  return PageTransitionSwitcher(
                    duration: AppMotion.medium,
                    reverse: !goingForward,
                    transitionBuilder: (child, primary, secondary) {
                      if (motionDisabled(context)) return child;
                      return SharedAxisTransition(
                        animation: primary,
                        secondaryAnimation: secondary,
                        transitionType: SharedAxisTransitionType.horizontal,
                        fillColor: Colors.transparent,
                        child: child,
                      );
                    },
                    child: Column(
                      key: ValueKey(_range),
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                          children: [
                            _SummaryCard(
                              title: 'Journal entries',
                              numericValue: filteredJournals.length.toDouble(),
                              icon: LineIcons.bookOpen,
                            ),
                            _SummaryCard(
                              title: 'OCD events',
                              numericValue: filteredOcds.length.toDouble(),
                              icon: LineIcons.bullseye,
                            ),
                            _SummaryCard(
                              title: 'Average distress',
                              numericValue: avgDistress.toDouble(),
                              fractionDigits: 1,
                              icon: LineIcons.areaChart,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _InsightCard(
                          title: 'Distress trend',
                          child: SizedBox(
                            height: 178,
                            child: _DistressTrend(entries: filteredOcds),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InsightCard(
                          title: 'Journaling consistency',
                          child: _ConsistencyStrip(
                            entries: filteredJournals,
                            days: DateRangeFilter.presetDaysFor(_range),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InsightCard(
                          title: 'Obsession vs compulsion',
                          child: _RatioBar(
                            obsessions: obsessions,
                            compulsions: compulsions,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final AnalyticsDateRange range;
  final ValueChanged<AnalyticsDateRange> onChanged;

  const _RangeSelector({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: _softDecoration(Theme.of(context), radius: 22),
      child: Row(
        children: [
          _RangeChip(
            label: '7D',
            selected: range == AnalyticsDateRange.seven,
            onTap: () => onChanged(AnalyticsDateRange.seven),
          ),
          _RangeChip(
            label: '30D',
            selected: range == AnalyticsDateRange.thirty,
            onTap: () => onChanged(AnalyticsDateRange.thirty),
          ),
          _RangeChip(
            label: '90D',
            selected: range == AnalyticsDateRange.ninety,
            onTap: () => onChanged(AnalyticsDateRange.ninety),
          ),
          _RangeChip(
            label: 'Year',
            selected: range == AnalyticsDateRange.year,
            onTap: () => onChanged(AnalyticsDateRange.year),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
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
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String? value;
  final double? numericValue;
  final int fractionDigits;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.icon,
    this.value,
    this.numericValue,
    this.fractionDigits = 0,
  }) : assert(value != null || numericValue != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w900,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softDecoration(theme, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const Spacer(),
          if (numericValue != null)
            AnimatedCounter(
              value: numericValue!,
              fractionDigits: fractionDigits,
              style: valueStyle,
            )
          else
            Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InsightCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _softDecoration(theme, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DistressTrend extends StatelessWidget {
  final List<OcdEntry> entries;

  const _DistressTrend({required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<OcdEntry>.from(entries)
      ..sort((a, b) => a.datetime.compareTo(b.datetime));
    final recent = sorted.length > 12
        ? sorted.sublist(sorted.length - 12)
        : sorted;

    if (recent.isEmpty) {
      return Center(
        child: Text(
          'No events in this range',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.dividerColor.withValues(alpha: 0.65),
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < recent.length; i++)
                FlSpot(i.toDouble(), recent[i].distressLevel.toDouble()),
            ],
            isCurved: true,
            color: AppTheme.warmYellow,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.warmYellow.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsistencyStrip extends StatelessWidget {
  final List<JournalEntry> entries;
  final int days;

  const _ConsistencyStrip({required this.entries, required this.days});

  @override
  Widget build(BuildContext context) {
    final dates = entries.map((entry) => entry.date).toSet();
    final visibleDays = days.clamp(7, 30);

    return Row(
      children: [
        for (var i = visibleDays - 1; i >= 0; i--)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 0 ? 0 : 4),
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color:
                      dates.contains(
                        DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateTime.now().subtract(Duration(days: i))),
                      )
                      ? AppTheme.warmYellow
                      : AppTheme.charcoalInput,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RatioBar extends StatelessWidget {
  final int obsessions;
  final int compulsions;

  const _RatioBar({required this.obsessions, required this.compulsions});

  @override
  Widget build(BuildContext context) {
    final total = obsessions + compulsions;
    final obsPercent = total == 0 ? 0.5 : obsessions / total;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Row(
            children: [
              Expanded(
                flex: (obsPercent * 100).round().clamp(1, 99),
                child: Container(height: 14, color: AppTheme.warmYellow),
              ),
              Expanded(
                flex: ((1 - obsPercent) * 100).round().clamp(1, 99),
                child: Container(height: 14, color: AppTheme.softGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '$obsessions obsessions',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const Spacer(),
            Text(
              '$compulsions compulsions',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

TextStyle _screenTitle(ThemeData theme) {
  return TextStyle(
    fontFamily: AppTheme.sansFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
    color: theme.colorScheme.onSurface,
  );
}

BoxDecoration _softDecoration(ThemeData theme, {required double radius}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
  );
}
