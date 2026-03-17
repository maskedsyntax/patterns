import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: DragToMoveArea(
          child: AppBar(
            title: const Text('Analytics'),
          ),
        ),
      ),
      body: journalAsync.when(
        data: (journals) {
          return ocdAsync.when(
            data: (ocds) {
              int totalObsessions = ocds.where((e) => e.type == OcdType.obsession).length;
              int totalCompulsions = ocds.where((e) => e.type == OcdType.compulsion).length;
              double avgDistress = ocds.isEmpty ? 0 : ocds.map((e) => e.distressLevel).reduce((a, b) => a + b) / ocds.length;

              // Process data for trend chart (last 10 events)
              final sortedOcds = List<OcdEntry>.from(ocds)..sort((a, b) => a.datetime.compareTo(b.datetime));
              final last10 = sortedOcds.length > 10 ? sortedOcds.sublist(sortedOcds.length - 10) : sortedOcds;

              // Process data for heatmap
              Map<DateTime, int> journalHeatMapData = {};
              for (var entry in journals) {
                try {
                  final date = DateTime.parse(entry.date);
                  journalHeatMapData[DateTime(date.year, date.month, date.day)] = 1;
                } catch (_) {}
              }
              
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                children: [
                  Text('Overview', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: _StatCard(title: 'Journal Entries', value: journals.length.toString(), icon: LineIcons.book)),
                      const SizedBox(width: 20),
                      Expanded(child: _StatCard(title: 'OCD Events', value: ocds.length.toString(), icon: LineIcons.bullseye)),
                      const SizedBox(width: 20),
                      Expanded(child: _StatCard(title: 'Avg Distress', value: avgDistress.toStringAsFixed(1), icon: LineIcons.areaChart)),
                    ],
                  ),
                  const SizedBox(height: 48),

                  _ChartCard(
                    title: 'Journaling Consistency',
                    subtitle: 'Activity over the past year',
                    height: 280,
                    child: HeatMap(
                      datasets: journalHeatMapData,
                      colorMode: ColorMode.color,
                      defaultColor: theme.dividerColor.withOpacity(0.1),
                      textColor: theme.colorScheme.onSurface.withOpacity(0.6),
                      showColorTip: false,
                      showText: false,
                      scrollable: true,
                      size: 20,
                      startDate: DateTime.now().subtract(const Duration(days: 365)),
                      endDate: DateTime.now(),
                      colorsets: {
                        1: theme.colorScheme.primary.withOpacity(0.8),
                      },
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  if (ocds.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _ChartCard(
                            title: 'Distress Trend',
                            subtitle: 'Recent 10 events',
                            child: _DistressTrendChart(entries: last10, theme: theme),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: _ChartCard(
                            title: 'Distribution',
                            subtitle: 'Obsessions vs Compulsions',
                            child: _DistributionChart(
                              obsessions: totalObsessions,
                              compulsions: totalCompulsions,
                              theme: theme,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],

                  Text('Breakdown', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Obsessions', 
                          value: totalObsessions.toString(), 
                          icon: LineIcons.brain,
                          color: Colors.blueAccent,
                        )
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _StatCard(
                          title: 'Compulsions', 
                          value: totalCompulsions.toString(), 
                          icon: LineIcons.fingerprint,
                          color: Colors.orangeAccent,
                        )
                      ),
                    ],
                  ),
                ],
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

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double height;

  const _ChartCard({
    required this.title, 
    required this.subtitle, 
    required this.child,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
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
            color: theme.dividerColor.withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= entries.length) return const SizedBox();
                final date = entries[value.toInt()].datetime;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 10),
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
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 10),
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
            spots: entries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.distressLevel.toDouble())).toList(),
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

  const _DistributionChart({required this.obsessions, required this.compulsions, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (obsessions == 0 && compulsions == 0) return const Center(child: Text('No data'));
    
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.blueAccent,
            value: obsessions.toDouble(),
            title: 'Obs',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.orangeAccent,
            value: compulsions.toDouble(),
            title: 'Comp',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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

  const _StatCard({required this.title, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color ?? theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            value, 
            style: GoogleFonts.inter(
              fontSize: 36, 
              fontWeight: FontWeight.w800, 
              color: theme.colorScheme.onSurface,
              letterSpacing: -1,
            )
          ),
          const SizedBox(height: 4),
          Text(
            title.toUpperCase(), 
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            )
          ),
        ],
      ),
    );
  }
}
