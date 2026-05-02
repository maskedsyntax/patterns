import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

enum _Range { seven, thirty, ninety, year }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _Range _range = _Range.thirty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
          children: [
            Text('Insights', style: _screenTitle(theme)),
            const SizedBox(height: 18),
            _RangeSelector(
              range: _range,
              onChanged: (range) => setState(() => _range = range),
            ),
            const SizedBox(height: 22),
            journalAsync.when(
              data: (journals) => ocdAsync.when(
                data: (ocds) {
                  final filteredJournals = _filterJournals(journals);
                  final filteredOcds = _filterOcds(ocds);
                  final avgDistress = filteredOcds.isEmpty
                      ? 0
                      : filteredOcds
                                .map((entry) => entry.distressLevel)
                                .reduce((a, b) => a + b) /
                            filteredOcds.length;
                  final obsessions = filteredOcds
                      .where((entry) => entry.type == OcdType.obsession)
                      .length;
                  final compulsions = filteredOcds
                      .where((entry) => entry.type == OcdType.compulsion)
                      .length;

                  return Column(
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
                            value: '${filteredJournals.length}',
                            icon: LineIcons.bookOpen,
                          ),
                          _SummaryCard(
                            title: 'OCD events',
                            value: '${filteredOcds.length}',
                            icon: LineIcons.bullseye,
                          ),
                          _SummaryCard(
                            title: 'Average distress',
                            value: avgDistress.toStringAsFixed(1),
                            icon: LineIcons.areaChart,
                          ),
                          _SummaryCard(
                            title: 'Most common trigger',
                            value: _commonTrigger(filteredOcds),
                            icon: LineIcons.compass,
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
                          days: _rangeDays,
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
                      const SizedBox(height: 14),
                      _InsightCard(
                        title: 'Trigger patterns',
                        child: Text(
                          _triggerPatternCopy(filteredOcds),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
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

  int get _rangeDays {
    switch (_range) {
      case _Range.seven:
        return 7;
      case _Range.thirty:
        return 30;
      case _Range.ninety:
        return 90;
      case _Range.year:
        return 365;
    }
  }

  DateTime get _cutoff => DateTime.now().subtract(Duration(days: _rangeDays));

  List<JournalEntry> _filterJournals(List<JournalEntry> entries) {
    return entries
        .where((entry) => DateTime.parse(entry.date).isAfter(_cutoff))
        .toList();
  }

  List<OcdEntry> _filterOcds(List<OcdEntry> entries) {
    return entries.where((entry) => entry.datetime.isAfter(_cutoff)).toList();
  }
}

class _RangeSelector extends StatelessWidget {
  final _Range range;
  final ValueChanged<_Range> onChanged;

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
            selected: range == _Range.seven,
            onTap: () => onChanged(_Range.seven),
          ),
          _RangeChip(
            label: '30D',
            selected: range == _Range.thirty,
            onTap: () => onChanged(_Range.thirty),
          ),
          _RangeChip(
            label: '90D',
            selected: range == _Range.ninety,
            onTap: () => onChanged(_Range.ninety),
          ),
          _RangeChip(
            label: 'Year',
            selected: range == _Range.year,
            onTap: () => onChanged(_Range.year),
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
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softDecoration(theme, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
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

String _commonTrigger(List<OcdEntry> entries) {
  if (entries.isEmpty) return 'None yet';
  final words = <String, int>{};
  for (final entry in entries) {
    for (final word in entry.content.toLowerCase().split(RegExp(r'\W+'))) {
      if (word.length < 4) continue;
      words[word] = (words[word] ?? 0) + 1;
    }
  }
  if (words.isEmpty) return 'Not clear';
  final sorted = words.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.first.key;
}

String _triggerPatternCopy(List<OcdEntry> entries) {
  if (entries.isEmpty) {
    return 'Patterns will appear here after a few tracked events.';
  }
  final trigger = _commonTrigger(entries);
  if (trigger == 'Not clear') {
    return 'There is not a strong repeated trigger yet.';
  }
  return 'A repeated theme around "$trigger" appears in this range.';
}

TextStyle _screenTitle(ThemeData theme) {
  return theme.textTheme.headlineSmall!.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );
}

BoxDecoration _softDecoration(ThemeData theme, {required double radius}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
  );
}
