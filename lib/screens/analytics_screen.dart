import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/export_report_options.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/analytics_service.dart';
import '../widgets/export_report_sheet.dart';
import '../widgets/platform.dart';
import '../widgets/window_controls.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsDateRange _range = AnalyticsDateRange.thirty;

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filter = DateRangeFilter.fromPreset(_range);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
            ),
          ),
          child: AppBar(
            toolbarHeight: 48,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Analytics',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
        data: (journals) {
          return ocdAsync.when(
            data: (ocds) {
              final filteredJournals = AnalyticsService.filterJournals(
                journals,
                filter,
              );
              final filteredOcds = AnalyticsService.filterOcds(ocds, filter);
              final totalObsessions = AnalyticsService.obsessionCount(
                filteredOcds,
              );
              final totalCompulsions = AnalyticsService.compulsionCount(
                filteredOcds,
              );
              final avgDistress = AnalyticsService.averageDistress(
                filteredOcds,
              );

              final sortedOcds = List<OcdEntry>.from(filteredOcds)
                ..sort((a, b) => a.datetime.compareTo(b.datetime));
              final last10 = sortedOcds.length > 10
                  ? sortedOcds.sublist(sortedOcds.length - 10)
                  : sortedOcds;

              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 24,
                    ),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Overview',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          _DesktopRangeSelector(
                            range: _range,
                            onChanged: (range) =>
                                setState(() => _range = range),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Journal Entries',
                              value: filteredJournals.length.toString(),
                              icon: LineIcons.book,
                              theme: theme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'OCD Events',
                              value: filteredOcds.length.toString(),
                              icon: LineIcons.bullseye,
                              theme: theme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Avg Distress',
                              value: avgDistress.toStringAsFixed(1),
                              icon: LineIcons.areaChart,
                              theme: theme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (filteredOcds.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _ChartCard(
                                title: 'Distress Trend',
                                subtitle: 'Recent 10 events',
                                height: 200,
                                theme: theme,
                                child: _DistressTrendChart(
                                  entries: last10,
                                  theme: theme,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: _ChartCard(
                                title: 'Distribution',
                                subtitle: 'Obs vs Comp',
                                height: 200,
                                theme: theme,
                                child: _DistributionChart(
                                  obsessions: totalObsessions,
                                  compulsions: totalCompulsions,
                                  theme: theme,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        'Breakdown',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Obsessions',
                              value: totalObsessions.toString(),
                              icon: LineIcons.brain,
                              color: Colors.blueAccent,
                              padding: 16,
                              theme: theme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Compulsions',
                              value: totalCompulsions.toString(),
                              icon: LineIcons.fingerprint,
                              color: Colors.orangeAccent,
                              padding: 16,
                              theme: theme,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DesktopRangeSelector extends StatelessWidget {
  final AnalyticsDateRange range;
  final ValueChanged<AnalyticsDateRange> onChanged;

  const _DesktopRangeSelector({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in const [
            AnalyticsDateRange.seven,
            AnalyticsDateRange.thirty,
            AnalyticsDateRange.ninety,
            AnalyticsDateRange.year,
          ])
            _DesktopRangeChip(
              label: switch (option) {
                AnalyticsDateRange.seven => '7D',
                AnalyticsDateRange.thirty => '30D',
                AnalyticsDateRange.ninety => '90D',
                AnalyticsDateRange.year => 'Year',
                _ => '',
              },
              selected: range == option,
              onTap: () => onChanged(option),
              theme: theme,
            ),
        ],
      ),
    );
  }
}

class _DesktopRangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _DesktopRangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double height;
  final ThemeData theme;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.theme,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }
}

class _DistressTrendChart extends StatelessWidget {
  final List<OcdEntry> entries;
  final ThemeData theme;

  const _DistressTrendChart({required this.entries, required this.theme});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.dividerColor.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) return const SizedBox();
                // Show at most ~5 labels: first, last, and evenly spaced in between.
                final step = (entries.length / 5).ceil().clamp(
                  1,
                  entries.length,
                );
                final isEdge = i == 0 || i == entries.length - 1;
                if (!isEdge && i % step != 0) return const SizedBox();
                final date = entries[i].datetime;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: entries.length > 1 ? entries.length.toDouble() - 1 : 1.0,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: entries
                .asMap()
                .entries
                .map(
                  (e) => FlSpot(
                    e.key.toDouble(),
                    e.value.distressLevel.toDouble(),
                  ),
                )
                .toList(),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionChart extends StatelessWidget {
  final int obsessions;
  final int compulsions;
  final ThemeData theme;

  const _DistributionChart({
    required this.obsessions,
    required this.compulsions,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (obsessions == 0 && compulsions == 0)
      return const Center(child: Text('No data'));

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: [
          PieChartSectionData(
            color: Colors.blueAccent.withOpacity(0.8),
            value: obsessions.toDouble(),
            title: 'Obs',
            radius: 40,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.orangeAccent.withOpacity(0.8),
            value: compulsions.toDouble(),
            title: 'Comp',
            radius: 40,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final double padding;
  final ThemeData theme;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.theme,
    this.color,
    this.padding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color ?? theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: padding == 24.0 ? 20 : 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: padding == 24.0 ? 28 : 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
