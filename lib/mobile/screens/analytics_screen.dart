import 'dart:async';
import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../../models/export_report_options.dart';
import '../../providers/providers.dart';
import '../../services/analytics_service.dart';
import '../../services/review_prompt.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/export_report_sheet.dart';
import '../../widgets/platform.dart';
import 'recovery_metrics_screen.dart';

enum _InsightTab { overview, thoughts, urges, erp }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsDateRange _range = AnalyticsDateRange.thirty;
  AnalyticsDateRange _previousRange = AnalyticsDateRange.thirty;
  _InsightTab _tab = _InsightTab.overview;
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
    final delays = ref.watch(delaySessionProvider).asData?.value ?? const [];
    final erp = ref.watch(erpExerciseSessionProvider).asData?.value ?? const [];
    final steps = ref.watch(exposureStepProvider).asData?.value ?? const [];
    final responses =
        ref.watch(responsePreventionProvider).asData?.value ?? const [];
    final surfs = ref.watch(urgeSurfProvider).asData?.value ?? const [];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C0C0B), AppTheme.deepCharcoal],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 116),
            children: [
              FadeSlideIn(
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Insights', style: _screenTitle(theme)),
                    ),
                    if (isPdfExportSupported)
                      _IconGlassButton(
                        tooltip: 'Export report',
                        icon: LineIcons.fileExport,
                        onTap: () => ExportReportSheet.show(
                          context,
                          initialOptions: ExportReportOptions(range: _range),
                        ),
                      ),
                    const SizedBox(width: 10),
                    _RangeMenu(
                      range: _range,
                      onChanged: (range) {
                        if (range == _range) return;
                        setState(() {
                          _previousRange = _range;
                          _range = range;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 50),
                child: _InsightSegmentedControl(
                  tab: _tab,
                  onChanged: (tab) => setState(() => _tab = tab),
                ),
              ),
              const SizedBox(height: 14),
              journalAsync.when(
                data: (journals) => ocdAsync.when(
                  data: (ocds) {
                    final dashboard = AnalyticsService.buildRecoveryDashboard(
                      journals: journals,
                      ocds: ocds,
                      delaySessions: delays,
                      erpSessions: erp,
                      exposureSteps: steps,
                      responsePreventionLogs: responses,
                      urgeSurfSessions: surfs,
                      range: _range,
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
                      child: _DashboardTabBody(
                        key: ValueKey('${_range.name}-${_tab.name}'),
                        tab: _tab,
                        summary: dashboard,
                      ),
                    );
                  },
                  loading: () => const _InsightsLoading(),
                  error: (error, _) => _InsightsError(message: '$error'),
                ),
                loading: () => const _InsightsLoading(),
                error: (error, _) => _InsightsError(message: '$error'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTabBody extends StatelessWidget {
  final _InsightTab tab;
  final RecoveryDashboardSummary summary;

  const _DashboardTabBody({
    super.key,
    required this.tab,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case _InsightTab.overview:
        return _OverviewDashboard(summary: summary);
      case _InsightTab.thoughts:
        return _ThoughtsDashboard(summary: summary);
      case _InsightTab.urges:
        return _UrgesDashboard(summary: summary);
      case _InsightTab.erp:
        return _ErpDashboard(summary: summary);
    }
  }
}

class _OverviewDashboard extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _OverviewDashboard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RecoveryScoreCard(summary: summary),
        const SizedBox(height: 12),
        _MoodCard(summary: summary),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _UrgeIntensityCard(summary: summary)),
            const SizedBox(width: 12),
            Expanded(child: _ErpPracticeCard(summary: summary)),
          ],
        ),
        const SizedBox(height: 12),
        _ConsistencyCard(summary: summary),
        const SizedBox(height: 12),
        _TopThemesCard(summary: summary),
        const SizedBox(height: 24),
        const RecoveryMetricsSection(),
      ],
    );
  }
}

class _ThoughtsDashboard extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _ThoughtsDashboard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Thought logs',
                value: '${summary.thoughts}',
                icon: LineIcons.brain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                label: 'Themes found',
                value: '${summary.topThemes.length}',
                icon: LineIcons.tags,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TopThemesCard(summary: summary),
        const SizedBox(height: 12),
        _MoodCard(summary: summary),
      ],
    );
  }
}

class _UrgesDashboard extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _UrgesDashboard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Compulsions',
                value: '${summary.compulsions}',
                icon: LineIcons.bullseye,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                label: 'Avg intensity',
                value: summary.averageUrge.toStringAsFixed(1),
                suffix: '/10',
                icon: LineIcons.lineChart,
                delta: summary.urgeDelta,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _UrgeIntensityCard(summary: summary, wide: true),
        const SizedBox(height: 12),
        _ConsistencyCard(summary: summary),
      ],
    );
  }
}

class _ErpDashboard extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _ErpDashboard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ErpPracticeCard(summary: summary, wide: true),
        const SizedBox(height: 12),
        _ConsistencyCard(summary: summary),
        const SizedBox(height: 24),
        const RecoveryMetricsSection(),
      ],
    );
  }
}

class _RecoveryScoreCard extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _RecoveryScoreCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardTitle('Recovery score', info: true),
                const SizedBox(height: 12),
                Text(
                  '${summary.recoveryScore}%',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontFamily: AppTheme.sansFamily,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                _DeltaLabel(
                  delta: summary.scoreDelta,
                  suffix: '% vs previous ${summary.rangeDays} days',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: _MiniLineChart(
                    points: summary.scoreTrend,
                    minY: 0,
                    maxY: 100,
                    color: AppTheme.warmYellow,
                    showDots: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _ScoreRing(score: summary.recoveryScore),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _MoodCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _CardTitle('Mood over time', info: true)),
              _LegendDot(color: AppTheme.softGreen, label: 'Good'),
              const SizedBox(width: 10),
              _LegendDot(color: AppTheme.warmYellow, label: 'Okay'),
              const SizedBox(width: 10),
              _LegendDot(color: AppTheme.mutedRed, label: 'Low'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 132,
            child: _MiniLineChart(
              points: summary.moodTrend,
              minY: 0,
              maxY: 10,
              color: AppTheme.softGreen,
              moodColors: true,
              bottomLabels: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgeIntensityCard extends StatelessWidget {
  final RecoveryDashboardSummary summary;
  final bool wide;

  const _UrgeIntensityCard({required this.summary, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      minHeight: wide ? null : 176,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle('Average urge intensity', info: true),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                summary.averageUrge.toStringAsFixed(1),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3, bottom: 4),
                child: Text('/10', style: _mutedStyle),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _DeltaLabel(
            delta: summary.urgeDelta,
            suffix: 'vs previous ${summary.rangeDays} days',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: wide ? 132 : 64,
            child: _MiniLineChart(
              points: summary.urgeTrend,
              minY: 0,
              maxY: 10,
              color: AppTheme.warmYellow,
              bottomLabels: wide,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErpPracticeCard extends StatelessWidget {
  final RecoveryDashboardSummary summary;
  final bool wide;

  const _ErpPracticeCard({required this.summary, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      minHeight: wide ? null : 176,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle('ERP practice', info: true),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${summary.erpPracticeCount}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 4),
                child: Text('sessions', style: _mutedStyle),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _DeltaLabel(
            delta: summary.erpDelta,
            suffix: 'vs previous ${summary.rangeDays} days',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: wide ? 150 : 64,
            child: _MiniBarChart(points: summary.erpTrend, bottomLabels: wide),
          ),
        ],
      ),
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _ConsistencyCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 126,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardTitle('Consistency', info: true),
                const SizedBox(height: 12),
                Text(
                  '${summary.consistencyPercent}%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${summary.activeDays} of ${summary.rangeDays} days',
                  style: _mutedStyle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DotHeatmap(
              values: summary.consistencyHeatmap,
              active: AppTheme.warmYellow,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopThemesCard extends StatelessWidget {
  final RecoveryDashboardSummary summary;

  const _TopThemesCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final themes = summary.topThemes;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _CardTitle('Top themes', info: true)),
              Text('View all', style: TextStyle(color: AppTheme.warmYellow)),
            ],
          ),
          const SizedBox(height: 14),
          if (themes.isEmpty)
            Text('Themes will appear as you log patterns.', style: _mutedStyle)
          else
            for (var i = 0; i < themes.length; i++) ...[
              _ThemeRow(
                theme: themes[i],
                color: _themeColors[i % _themeColors.length],
              ),
              if (i != themes.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final ThemeInsight theme;
  final Color color;

  const _ThemeRow({required this.theme, required this.color});

  @override
  Widget build(BuildContext context) {
    final percent = (theme.percent * 100).round();
    return Row(
      children: [
        Icon(_themeIcon(theme.label), color: color, size: 19),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            theme.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: theme.percent.clamp(0, 1),
              minHeight: 6,
              backgroundColor: const Color(0xFF292927),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            '$percent%',
            textAlign: TextAlign.right,
            style: _mutedStyle,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(
          LineIcons.angleRight,
          color: AppTheme.textSecondary,
          size: 16,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final IconData icon;
  final InsightDelta? delta;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    this.suffix,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.warmYellow, size: 22),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 3, bottom: 4),
                  child: Text(suffix!, style: _mutedStyle),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: _mutedStyle),
          if (delta != null) ...[
            const SizedBox(height: 8),
            _DeltaLabel(delta: delta!, suffix: 'vs previous range'),
          ],
        ],
      ),
    );
  }
}

class _RangeMenu extends StatelessWidget {
  final AnalyticsDateRange range;
  final ValueChanged<AnalyticsDateRange> onChanged;

  const _RangeMenu({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AnalyticsDateRange>(
      tooltip: 'Change range',
      onSelected: onChanged,
      color: const Color(0xFF1B1B19),
      itemBuilder: (_) => const [
        PopupMenuItem(value: AnalyticsDateRange.seven, child: Text('7 days')),
        PopupMenuItem(value: AnalyticsDateRange.thirty, child: Text('30 days')),
        PopupMenuItem(value: AnalyticsDateRange.ninety, child: Text('90 days')),
        PopupMenuItem(value: AnalyticsDateRange.year, child: Text('Year')),
      ],
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _premiumDecoration(radius: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _rangeLabel(range),
              style: const TextStyle(
                color: AppTheme.warmYellow,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              LineIcons.angleDown,
              size: 14,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightSegmentedControl extends StatelessWidget {
  final _InsightTab tab;
  final ValueChanged<_InsightTab> onChanged;

  const _InsightSegmentedControl({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: _premiumDecoration(radius: 18),
      child: Row(
        children: [
          _SegmentButton(
            label: 'Overview',
            selected: tab == _InsightTab.overview,
            onTap: () => onChanged(_InsightTab.overview),
          ),
          _SegmentButton(
            label: 'Thoughts',
            selected: tab == _InsightTab.thoughts,
            onTap: () => onChanged(_InsightTab.thoughts),
          ),
          _SegmentButton(
            label: 'Urges',
            selected: tab == _InsightTab.urges,
            onTap: () => onChanged(_InsightTab.urges),
          ),
          _SegmentButton(
            label: 'ERP',
            selected: tab == _InsightTab.erp,
            onTap: () => onChanged(_InsightTab.erp),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF27251C) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.warmYellow.withValues(alpha: 0.10),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: selected ? AppTheme.warmYellow : AppTheme.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double? minHeight;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      width: double.infinity,
      padding: padding,
      decoration: _premiumDecoration(),
      child: child,
    );
  }
}

class _IconGlassButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _IconGlassButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: _premiumDecoration(radius: 14),
          child: Icon(icon, size: 18, color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;
  final bool info;

  const _CardTitle(this.text, {this.info = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
        if (info) ...[
          const SizedBox(width: 4),
          const Icon(
            LineIcons.infoCircle,
            size: 13,
            color: AppTheme.textSecondary,
          ),
        ],
      ],
    );
  }
}

class _DeltaLabel extends StatelessWidget {
  final InsightDelta delta;
  final String suffix;

  const _DeltaLabel({required this.delta, required this.suffix});

  @override
  Widget build(BuildContext context) {
    final color = switch (delta.tone) {
      InsightTone.positive => AppTheme.softGreen,
      InsightTone.negative => AppTheme.mutedRed,
      InsightTone.neutral => AppTheme.textSecondary,
    };
    final arrow = switch (delta.tone) {
      InsightTone.positive => '↑',
      InsightTone.negative => '↓',
      InsightTone.neutral => '→',
    };
    return Text(
      '$arrow ${delta.value.abs().toStringAsFixed(delta.value.abs() < 10 ? 1 : 0)} $suffix',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: _mutedStyle.copyWith(fontSize: 10.5)),
      ],
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;

  const _ScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: CustomPaint(
        painter: _ScoreRingPainter(score: score),
        child: Center(
          child: Icon(
            LineIcons.lineChart,
            color: AppTheme.textSecondary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final int score;

  _ScoreRingPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 7;
    final track = Paint()
      ..color = const Color(0xFF2B2A27)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..shader = const SweepGradient(
        colors: [AppTheme.warmYellow, Color(0xFFFFE28A), AppTheme.warmYellow],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      (score.clamp(0, 100) / 100) * math.pi * 2,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

class _MiniLineChart extends StatelessWidget {
  final List<DashboardPoint> points;
  final double minY;
  final double maxY;
  final Color color;
  final bool showDots;
  final bool bottomLabels;
  final bool moodColors;

  const _MiniLineChart({
    required this.points,
    required this.minY,
    required this.maxY,
    required this.color,
    this.showDots = true,
    this.bottomLabels = false,
    this.moodColors = false,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(child: Text('No data yet', style: _mutedStyle));
    }
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFF33322F),
            strokeWidth: 0.8,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: bottomLabels,
              reservedSize: 20,
              interval: math.max(1, (points.length - 1).toDouble()),
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat.MMMd().format(points[i].date),
                    style: _mutedStyle.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2.6,
            color: color,
            gradient: moodColors
                ? const LinearGradient(
                    colors: [
                      AppTheme.mutedRed,
                      AppTheme.warmYellow,
                      AppTheme.softGreen,
                    ],
                  )
                : null,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final List<DashboardPoint> points;
  final bool bottomLabels;

  const _MiniBarChart({required this.points, this.bottomLabels = false});

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<double>(1, (max, p) => math.max(max, p.value));
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxValue + 1,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFF33322F),
            strokeWidth: 0.8,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: bottomLabels,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat.MMMd().format(points[i].date),
                    style: _mutedStyle.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].value,
                  width: 7,
                  borderRadius: BorderRadius.circular(6),
                  color: AppTheme.warmYellow,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxValue + 1,
                    color: const Color(0xFF292927),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DotHeatmap extends StatelessWidget {
  final List<bool> values;
  final Color active;

  const _DotHeatmap({required this.values, required this.active});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 10;
        final rows = (values.length / columns).ceil();
        final gap = constraints.maxWidth < 190 ? 5.0 : 7.0;
        final size = ((constraints.maxWidth - gap * (columns - 1)) / columns)
            .clamp(7.0, 12.0);
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < rows * columns; i++)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < values.length && values[i]
                      ? active
                      : const Color(0xFF31302D),
                  boxShadow: i < values.length && values[i]
                      ? [
                          BoxShadow(
                            color: active.withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InsightsLoading extends StatelessWidget {
  const _InsightsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _InsightsError extends StatelessWidget {
  final String message;

  const _InsightsError({required this.message});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Text('Could not load insights: $message', style: _mutedStyle),
    );
  }
}

BoxDecoration _premiumDecoration({double radius = 20}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1C1C1A), Color(0xFF151514)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFF34322D)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.28),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: AppTheme.warmYellow.withValues(alpha: 0.035),
        blurRadius: 28,
      ),
    ],
  );
}

TextStyle _screenTitle(ThemeData theme) {
  return TextStyle(
    fontFamily: AppTheme.sansFamily,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -0.2,
    color: theme.colorScheme.onSurface,
  );
}

String _rangeLabel(AnalyticsDateRange range) {
  return switch (range) {
    AnalyticsDateRange.seven => '7 days',
    AnalyticsDateRange.thirty => '30 days',
    AnalyticsDateRange.ninety => '90 days',
    AnalyticsDateRange.year => 'Year',
    AnalyticsDateRange.allTime => 'All',
    AnalyticsDateRange.custom => 'Custom',
  };
}

IconData _themeIcon(String label) {
  return switch (label) {
    'Contamination' => LineIcons.flask,
    'Harm' => LineIcons.exclamationTriangle,
    'Checking' => LineIcons.checkCircle,
    'Reassurance' => LineIcons.comments,
    'Health' => LineIcons.heartbeat,
    'Relationship' => LineIcons.heart,
    'Symmetry' => LineIcons.objectGroup,
    'Moral' => LineIcons.balanceScale,
    'Rumination' => LineIcons.syncIcon,
    'Uncertainty' => LineIcons.questionCircle,
    _ => LineIcons.tag,
  };
}

const _themeColors = [
  AppTheme.mutedRed,
  Color(0xFFFF9F43),
  Color(0xFF5CA7FF),
  AppTheme.softGreen,
];

const _mutedStyle = TextStyle(
  color: AppTheme.textSecondary,
  fontSize: 12,
  height: 1.25,
);
