import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/analytics_service.dart';
import '../../services/review_prompt.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/rich_journal.dart';
import '../preferences.dart';

class TodayScreen extends ConsumerStatefulWidget {
  final VoidCallback onJournal;
  final VoidCallback onTrack;
  final VoidCallback onDelay;
  final VoidCallback onErp;
  final VoidCallback onInsights;
  final VoidCallback onSettings;
  final ValueChanged<RecoveryStep> onNextStep;

  const TodayScreen({
    super.key,
    required this.onJournal,
    required this.onTrack,
    required this.onDelay,
    required this.onErp,
    required this.onInsights,
    required this.onSettings,
    required this.onNextStep,
  });

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);
    final delays = ref.watch(delaySessionProvider).asData?.value ?? const [];
    final erp = ref.watch(erpExerciseSessionProvider).asData?.value ?? const [];
    final steps = ref.watch(exposureStepProvider).asData?.value ?? const [];
    final responses =
        ref.watch(responsePreventionProvider).asData?.value ?? const [];
    final surfs = ref.watch(urgeSurfProvider).asData?.value ?? const [];

    final journals = journalAsync.asData?.value ?? const <JournalEntry>[];
    final ocds = ocdAsync.asData?.value ?? const <OcdEntry>[];
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hasCheckedIn = journals.any((entry) => entry.date == todayKey);
    final metrics = AnalyticsService.buildRecoveryMetrics(
      delaySessions: delays,
      erpSessions: erp,
      exposureSteps: steps,
      responsePreventionLogs: responses,
      urgeSurfSessions: surfs,
    );
    final dashboard = AnalyticsService.buildRecoveryDashboard(
      journals: journals,
      ocds: ocds,
      delaySessions: delays,
      erpSessions: erp,
      exposureSteps: steps,
      responsePreventionLogs: responses,
      urgeSurfSessions: surfs,
    );
    final recentDelay = _latestDelay(delays);

    // The single recommended next action, mirroring the ERP journey stages so
    // Today always shows one clear thing to do instead of a wall of tools.
    final isPro = ref.watch(proProvider);
    final ybocs = ref.watch(ybocsAssessmentProvider).asData?.value ?? const [];
    final hierarchySteps =
        ref.watch(exposureStepProvider).asData?.value ?? const [];
    final now = DateTime.now();
    bool isToday(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;
    final practicedToday =
        erp.any((e) => isToday(e.createdAt)) ||
        delays.any((d) => isToday(d.createdAt));
    final nextStep = AnalyticsService.buildNextStep(
      isPro: isPro,
      hasYbocs: ybocs.isNotEmpty,
      hasHierarchy: hierarchySteps.isNotEmpty,
      practicedToday: practicedToday,
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF090A09), AppTheme.deepCharcoal],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
            children: staggered([
              _HomeHeader(
                streak: metrics.practiceStreakDays,
                onSettings: widget.onSettings,
              ),
              const SizedBox(height: 18),
              _HomeScoreCard(summary: dashboard, onTap: widget.onInsights),
              const SizedBox(height: 16),
              _NextStepCard(
                step: nextStep,
                onTap: () => widget.onNextStep(nextStep.step),
              ),
              const SizedBox(height: 20),
              _HomeSectionHeader(
                title: 'Continue your practice',
                actionLabel: 'See all',
                onAction: widget.onErp,
              ),
              const SizedBox(height: 10),
              _ContinuePracticeCard(
                recentDelay: recentDelay,
                onResume: recentDelay == null ? widget.onErp : widget.onDelay,
              ),
              const SizedBox(height: 22),
              const _HomeSectionHeader(title: 'Quick actions'),
              const SizedBox(height: 10),
              _QuickActionGrid(
                onJournal: widget.onJournal,
                onErp: widget.onErp,
                onExposureTools: widget.onErp,
                onInsights: widget.onInsights,
              ),
              const SizedBox(height: 14),
              _DailyCheckInCard(
                checkedIn: hasCheckedIn,
                onTap: widget.onJournal,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  DelaySession? _latestDelay(List<DelaySession> sessions) {
    DelaySession? latest;
    for (final session in sessions) {
      if (latest == null || session.createdAt.isAfter(latest.createdAt)) {
        latest = session;
      }
    }
    return latest;
  }
}

class _HomeHeader extends StatelessWidget {
  final int streak;
  final VoidCallback onSettings;

  const _HomeHeader({required this.streak, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    final greeting = _greetingFor(DateTime.now());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontFamily: AppTheme.sansFamily,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  color: AppTheme.warmYellow,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "You've got this. One choice at a time.",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(11, 10, 13, 10),
          decoration: _homeCardDecoration(radius: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppTheme.warmYellow,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '$streak',
                style: const TextStyle(
                  color: AppTheme.warmYellow,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        PressScale(
          onTap: onSettings,
          child: Semantics(
            button: true,
            label: 'Settings',
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: _homeCardDecoration(radius: 16),
              child: const Icon(
                LineIcons.cog,
                color: AppTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _greetingFor(DateTime now) {
    final part = now.hour < 12
        ? 'morning'
        : now.hour < 17
        ? 'afternoon'
        : 'evening';
    return 'Good $part';
  }
}

class _HomeScoreCard extends StatelessWidget {
  final RecoveryDashboardSummary summary;
  final VoidCallback onTap;

  const _HomeScoreCard({required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final score = summary.recoveryScore;
    final label = _scoreLabel(score, summary.hasAnyData);
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _homeCardDecoration(radius: 22),
        child: Row(
          children: [
            _HomeScoreRing(score: score, label: label),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RECOVERY SCORE',
                    style: TextStyle(
                      color: AppTheme.warmYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    summary.hasAnyData ? 'Steady progress' : 'Start gently',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    summary.hasAnyData
                        ? "You're showing up and building new patterns."
                        : 'Your score will build as you journal, track, and practice.',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _deltaText(summary.scoreDelta.value, summary.hasAnyData),
                    style: const TextStyle(
                      color: AppTheme.warmYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LineIcons.angleRight, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  String _scoreLabel(int score, bool hasData) {
    if (!hasData) return 'New';
    if (score >= 80) return 'Strong';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Building';
    return 'Start';
  }

  String _deltaText(double delta, bool hasData) {
    if (!hasData) return 'Begin with one small check-in';
    final rounded = delta.round();
    if (rounded == 0) return 'No change from last period';
    final direction = rounded > 0 ? 'up' : 'down';
    return '${rounded.abs()} pts $direction from last period';
  }
}

class _HomeScoreRing extends StatelessWidget {
  final int score;
  final String label;

  const _HomeScoreRing({required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 108,
      child: CustomPaint(
        painter: _HomeScoreRingPainter(score),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.warmYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeScoreRingPainter extends CustomPainter {
  final int score;

  const _HomeScoreRingPainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..shader = const SweepGradient(
        colors: [AppTheme.warmYellow, Color(0xFFFFE994), AppTheme.warmYellow],
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
  bool shouldRepaint(covariant _HomeScoreRingPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

class _NextStepCard extends StatelessWidget {
  final RecoveryNextStep step;
  final VoidCallback onTap;

  const _NextStepCard({required this.step, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF23200F), Color(0xFF15140F)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.warmYellow.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YOUR NEXT STEP',
              style: TextStyle(
                color: AppTheme.warmYellow,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              step.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              step.subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.34,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(step.ctaLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _HomeSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppTheme.warmYellow,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _ContinuePracticeCard extends StatelessWidget {
  final DelaySession? recentDelay;
  final VoidCallback onResume;

  const _ContinuePracticeCard({
    required this.recentDelay,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final session = recentDelay;
    final hasSession = session != null;
    final progress = hasSession && session.plannedSeconds > 0
        ? (session.actualSeconds / session.plannedSeconds).clamp(0.0, 1.0)
        : 0.58;
    final elapsed = hasSession ? _formatSeconds(session.actualSeconds) : '2:30';
    final planned = hasSession
        ? _formatSeconds(session.plannedSeconds)
        : '5:00';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _homeCardDecoration(radius: 18),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CustomPaint(
              painter: _MiniProgressPainter(progress),
              child: const Center(
                child: Icon(
                  LineIcons.clock,
                  color: AppTheme.warmYellow,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasSession ? 'Compulsion Delay' : 'Start ERP Practice',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasSession
                      ? 'Resist the urge, ride the wave.'
                      : 'Build tolerance step by step.',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Colors.white.withValues(alpha: 0.13),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.warmYellow,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$elapsed / $planned',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onResume,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(hasSession ? 'Resume' : 'Start'),
          ),
        ],
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}

class _MiniProgressPainter extends CustomPainter {
  final double progress;

  const _MiniProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 5;
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = AppTheme.warmYellow
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress.clamp(0.0, 1.0) * math.pi * 2,
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _QuickActionGrid extends StatelessWidget {
  final VoidCallback onJournal;
  final VoidCallback onErp;
  final VoidCallback onExposureTools;
  final VoidCallback onInsights;

  const _QuickActionGrid({
    required this.onJournal,
    required this.onErp,
    required this.onExposureTools,
    required this.onInsights,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: LineIcons.edit,
                title: 'Journal',
                subtitle: 'Write it out, get it clear.',
                onTap: onJournal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionTile(
                icon: LineIcons.bullseye,
                title: 'Start ERP Practice',
                subtitle: 'Build tolerance step by step.',
                onTap: onErp,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: LineIcons.layerGroup,
                title: 'Exposure Tools',
                subtitle: 'Hierarchy, materials, uncertainty.',
                onTap: onExposureTools,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionTile(
                icon: LineIcons.barChart,
                title: 'Insights',
                subtitle: 'See your patterns and progress.',
                onTap: onInsights,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        height: 98,
        padding: const EdgeInsets.all(14),
        decoration: _homeCardDecoration(radius: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.warmYellow, size: 27),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11.5,
                      height: 1.18,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LineIcons.angleRight,
              color: AppTheme.textSecondary,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyCheckInCard extends StatelessWidget {
  final bool checkedIn;
  final VoidCallback onTap;

  const _DailyCheckInCard({required this.checkedIn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _homeCardDecoration(radius: 18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.softGreen.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.eco_rounded, color: AppTheme.softGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkedIn ? 'Daily check-in complete' : 'Daily check-in',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  checkedIn
                      ? 'You showed up today. Let that count.'
                      : 'Small steps today create lasting change.',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(checkedIn ? 'Open' : 'Check in'),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _homeCardDecoration({double radius = 20}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1D1D1B), Color(0xFF141413)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFF35332F)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.28),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: AppTheme.warmYellow.withValues(alpha: 0.035),
        blurRadius: 30,
      ),
    ],
  );
}

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(journalSearchQueryProvider);
    if (_searchController.text.isNotEmpty) _isSearching = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _enterSearch() {
    setState(() => _isSearching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  void _exitSearch() {
    _searchFocus.unfocus();
    _searchController.clear();
    ref.read(journalSearchQueryProvider.notifier).query = '';
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(filteredJournalProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _isSearching
                    ? _InlineSearchBar(
                        key: const ValueKey('search'),
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: (value) =>
                            ref
                                    .read(journalSearchQueryProvider.notifier)
                                    .query =
                                value,
                        onCancel: _exitSearch,
                      )
                    : Row(
                        key: const ValueKey('header'),
                        children: [
                          Expanded(
                            child: Text('Journal', style: _screenTitle(theme)),
                          ),
                          _RoundIconButton(
                            icon: LineIcons.search,
                            semanticLabel: 'Search journal',
                            onTap: _enterSearch,
                          ),
                          const SizedBox(width: 10),
                          _RoundIconButton(
                            icon: LineIcons.calendar,
                            semanticLabel: 'Choose date',
                            onTap: () => _pickDate(context),
                          ),
                        ],
                      ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _isSearching
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 52,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final date = DateTime.now().subtract(
                            Duration(days: index),
                          );
                          return _DatePill(
                            date: date,
                            isToday: index == 0,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => JournalEntryEditor(date: date),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemCount: 10,
                      ),
                    ),
            ),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  final sorted = List<JournalEntry>.from(entries)
                    ..sort((a, b) => b.date.compareTo(a.date));
                  final query = ref.watch(journalSearchQueryProvider);
                  final todayKey = DateFormat(
                    'yyyy-MM-dd',
                  ).format(DateTime.now());
                  final hasTodayEntry = entries.any(
                    (entry) => entry.date == todayKey,
                  );
                  final children = <Widget>[
                    // The shortcut card is only useful before today's entry
                    // exists - once saved, it sits at the top of the list.
                    if (!_isSearching && !hasTodayEntry) ...[
                      _TodayEntryCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                JournalEntryEditor(date: DateTime.now()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (sorted.isEmpty)
                      _EmptyState(
                        icon: _isSearching && query.isNotEmpty
                            ? LineIcons.search
                            : LineIcons.penNib,
                        title: _isSearching && query.isNotEmpty
                            ? 'No matches'
                            : 'No journal entries yet',
                        body: _isSearching && query.isNotEmpty
                            ? 'Nothing matches "$query".'
                            : 'A few quiet lines are enough to begin.',
                      )
                    else
                      ...sorted.map((entry) => _JournalListCard(entry: entry)),
                  ];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 116),
                    children: staggered(children),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DatePickerSheet(initialDate: DateTime.now()),
    );
    if (picked == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => JournalEntryEditor(date: picked)),
    );
  }
}

class _InlineSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;

  const _InlineSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCancel,
  });

  @override
  State<_InlineSearchBar> createState() => _InlineSearchBarState();
}

class _InlineSearchBarState extends State<_InlineSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: _softDecoration(theme, radius: 18),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(LineIcons.search, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    onChanged: widget.onChanged,
                    textInputAction: TextInputAction.search,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      hintText: 'Search entries',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (widget.controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                    child: Icon(
                      Icons.cancel,
                      size: 18,
                      color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: theme.colorScheme.primary,
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class JournalEntryEditor extends ConsumerStatefulWidget {
  final DateTime date;

  const JournalEntryEditor({super.key, required this.date});

  @override
  ConsumerState<JournalEntryEditor> createState() => _JournalEntryEditorState();
}

class _JournalEntryEditorState extends ConsumerState<JournalEntryEditor> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  bool _loaded = false;
  bool _saving = false;
  bool _saved = true;
  String _savedSnapshot = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onDocumentChanged);
  }

  void _onDocumentChanged() {
    // Compare against the last-saved snapshot so cursor/selection moves don't
    // flip the indicator to "Unsaved" - only real content edits do.
    if (!_loaded) return;
    final saved = storedFromDocument(_controller.document) == _savedSnapshot;
    if (saved != _saved) setState(() => _saved = saved);
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocumentChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalProvider);
    final theme = Theme.of(context);
    final dateKey = DateFormat('yyyy-MM-dd').format(widget.date);
    final hasExistingEntry =
        entriesAsync.asData?.value.any((entry) => entry.date == dateKey) ??
        false;

    entriesAsync.whenData((entries) {
      if (_loaded) return;
      final existing = entries
          .where((entry) => entry.date == dateKey)
          .firstOrNull;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.document = documentFromStored(existing?.content ?? '');
        _controller.moveCursorToEnd();
        _savedSnapshot = storedFromDocument(_controller.document);
        setState(() {
          _loaded = true;
          _saved = true;
        });
      });
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LineIcons.angleLeft),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM d, yyyy').format(widget.date),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1,
                                  child: child,
                                ),
                              ),
                          child: Text(
                            _saving
                                ? 'Saving...'
                                : (_saved ? 'Saved' : 'Unsaved'),
                            key: ValueKey(
                              _saving
                                  ? 'saving'
                                  : (_saved ? 'saved' : 'unsaved'),
                            ),
                            style: _muted(theme, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasExistingEntry)
                    IconButton(
                      tooltip: 'Reset entry',
                      onPressed: _saving ? null : () => _confirmReset(dateKey),
                      icon: const Icon(LineIcons.trash),
                      color: AppTheme.textSecondary,
                    ),
                  TextButton(
                    onPressed: (_saving || _saved) ? null : _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: QuillEditor.basic(
                  controller: _controller,
                  focusNode: _focusNode,
                  config: QuillEditorConfig(
                    autoFocus: true,
                    expands: true,
                    placeholder: 'Start writing...',
                    customStyles: _editorStyles(theme),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              child: Row(
                children: [
                  JournalFormatToolbar(controller: _controller),
                  const Spacer(),
                  Text('Select text to format', style: _muted(theme, 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DefaultStyles _editorStyles(ThemeData theme) {
    final base = TextStyle(
      fontFamily: AppTheme.sansFamily,
      fontSize: 19,
      height: 1.65,
      letterSpacing: -0.1,
      color: theme.colorScheme.onSurface,
    );
    return DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        base,
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        null,
      ),
      placeHolder: DefaultTextBlockStyle(
        base.copyWith(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        null,
      ),
    );
  }

  Future<void> _confirmReset(String dateKey) async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _BottomPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset this entry?',
              style: Theme.of(
                sheetContext,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'This clears everything saved for '
              '${DateFormat('MMMM d, yyyy').format(widget.date)} so the day '
              'starts fresh. You can write here again anytime.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Keep it'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await _resetEntry(dateKey);
                    },
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetEntry(String dateKey) async {
    await ref.read(journalProvider.notifier).deleteEntry(dateKey);
    if (!mounted) return;
    _controller.document = Document();
    _savedSnapshot = storedFromDocument(_controller.document);
    setState(() => _saved = true);
    Navigator.pop(context);
    showAppSnackBar(
      context,
      'Entry reset. This day is clear now.',
      type: ToastType.success,
    );
  }

  Future<void> _save() async {
    if (_controller.document.toPlainText().trim().isEmpty) {
      showAppSnackBar(
        context,
        'Nothing to save yet. Add a line whenever you feel ready.',
        type: ToastType.info,
      );
      return;
    }
    setState(() => _saving = true);
    final dateKey = DateFormat('yyyy-MM-dd').format(widget.date);
    await ref
        .read(journalProvider.notifier)
        .saveEntry(dateKey, storedFromDocument(_controller.document));
    if (!mounted) return;
    _savedSnapshot = storedFromDocument(_controller.document);
    setState(() {
      _saving = false;
      _saved = true;
    });
    showAppSnackBar(context, 'Entry saved', type: ToastType.success);
    await ReviewPromptService.recordJournalSaved();
    if (!mounted) return;
    await ReviewPromptService.maybeRequestReview(
      context,
      trigger: ReviewTrigger.journalSaved,
    );
  }
}

class _JournalListCard extends StatelessWidget {
  final JournalEntry entry;

  const _JournalListCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.parse(entry.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Card(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => JournalEntryEditor(date: date),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM d').format(date),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              richPreviewSpan(
                entry.content,
                _muted(theme, 14).copyWith(height: 1.45),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _TodayEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      onTap: onTap,
      child: Row(
        children: [
          Icon(LineIcons.penNib, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Today entry',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(LineIcons.angleRight, color: AppTheme.textSecondary),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onTap;

  const _DatePill({
    required this.date,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    final weekday = DateFormat('EEE').format(date);
    final day = DateFormat('d').format(date);
    final month = DateFormat('MMM').format(date);

    final fillColor = isToday
        ? accent.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.04);
    final borderColor = isToday
        ? accent.withValues(alpha: 0.55)
        : theme.dividerColor.withValues(alpha: 0.6);
    final topColor = isToday
        ? accent.withValues(alpha: 0.85)
        : theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final bottomColor = isToday ? accent : theme.colorScheme.onSurface;

    return PressScale(
      onTap: onTap,
      child: Container(
        width: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isToday ? 'Today' : weekday,
              style: TextStyle(
                fontFamily: AppTheme.sansFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                height: 1.1,
                color: topColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isToday ? '$month $day' : '$month $day',
              style: TextStyle(
                fontFamily: AppTheme.sansFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                height: 1.1,
                color: bottomColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerSheet extends StatefulWidget {
  final DateTime initialDate;

  const _DatePickerSheet({required this.initialDate});

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _date = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return _BottomPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose date',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              CalendarDatePicker(
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                onDateChanged: (date) => _date = date,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _date),
                  child: const Text('Open entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: PressScale(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: _softDecoration(theme, radius: 18),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _Card({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(20),
      decoration: _softDecoration(Theme.of(context), radius: 24),
      child: child,
    );

    if (onTap == null) return content;
    return PressScale(onTap: onTap, child: content);
  }
}

class _BottomPanel extends StatelessWidget {
  final Widget child;

  const _BottomPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: child,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary.withValues(alpha: 0.75),
            size: 38,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: _muted(theme, 14)),
        ],
      ),
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

TextStyle _muted(ThemeData theme, double size) {
  return TextStyle(color: AppTheme.textSecondary, fontSize: size);
}

BoxDecoration _softDecoration(ThemeData theme, {required double radius}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
  );
}
