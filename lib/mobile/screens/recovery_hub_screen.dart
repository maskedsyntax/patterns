import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../../providers/providers.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../preferences.dart';
import '../widgets/pro_gate.dart';
import 'action_planner_screen.dart';
import 'behavioral_experiments_screen.dart';
import 'compulsion_delay_screen.dart';
import 'coping_library_screen.dart';
import 'emergency_toolkit_screen.dart';
import 'erp_exercises_screen.dart';
import 'exposure_hierarchy_screen.dart';
import 'exposure_materials_screen.dart';
import 'exposure_reflection_screen.dart';
import 'implementation_intentions_screen.dart';
import 'recovery_metrics_screen.dart';
import 'response_prevention_screen.dart';
import 'structured_programs_screen.dart';
import 'uncertainty_training_screen.dart';
import 'urge_surf_screen.dart';

/// Daily recovery cockpit: today-first ERP, compact tools, and visible progress.
class RecoveryHubScreen extends ConsumerWidget {
  const RecoveryHubScreen({super.key});

  static const _freeTools = <_RecoveryTool>[
    _RecoveryTool(
      icon: Icons.self_improvement_rounded,
      title: 'Guided ERP',
      subtitle: 'Practice a plan.',
      destination: _RecoveryDestination.guidedErp,
    ),
    _RecoveryTool(
      icon: Icons.hourglass_bottom_rounded,
      title: 'Compulsion Delay',
      subtitle: 'Create space.',
      destination: _RecoveryDestination.compulsionDelay,
      fullscreen: true,
    ),
    _RecoveryTool(
      icon: Icons.health_and_safety_rounded,
      title: 'Emergency Toolkit',
      subtitle: 'Fast support.',
      destination: _RecoveryDestination.emergencyToolkit,
    ),
    _RecoveryTool(
      icon: Icons.spa_rounded,
      title: 'Coping Library',
      subtitle: 'Ground and reset.',
      destination: _RecoveryDestination.copingLibrary,
    ),
  ];

  static const _proTools = <_RecoveryTool>[
    _RecoveryTool(
      icon: Icons.stairs_rounded,
      title: 'Exposure Hierarchy',
      subtitle: 'Build your ladder.',
      destination: _RecoveryDestination.exposureHierarchy,
    ),
    _RecoveryTool(
      icon: Icons.folder_special_rounded,
      title: 'Exposure Materials',
      subtitle: 'Scripts and links.',
      destination: _RecoveryDestination.exposureMaterials,
    ),
    _RecoveryTool(
      icon: Icons.shield_rounded,
      title: 'Response Prevention',
      subtitle: 'Stay on track.',
      destination: _RecoveryDestination.responsePrevention,
    ),
    _RecoveryTool(
      icon: Icons.calendar_month_rounded,
      title: 'Structured Programs',
      subtitle: 'Guided weeks.',
      destination: _RecoveryDestination.structuredPrograms,
    ),
    _RecoveryTool(
      icon: Icons.waves_rounded,
      title: 'Urge Surfing',
      subtitle: 'Ride the wave.',
      destination: _RecoveryDestination.urgeSurfing,
    ),
    _RecoveryTool(
      icon: Icons.help_outline_rounded,
      title: 'Uncertainty Training',
      subtitle: 'Practice maybe.',
      destination: _RecoveryDestination.uncertaintyTraining,
    ),
    _RecoveryTool(
      icon: Icons.checklist_rounded,
      title: 'Action Planner',
      subtitle: 'Plan responses.',
      destination: _RecoveryDestination.actionPlanner,
    ),
    _RecoveryTool(
      icon: Icons.science_rounded,
      title: 'Behavioral Experiments',
      subtitle: 'Test OCD.',
      destination: _RecoveryDestination.behavioralExperiments,
    ),
    _RecoveryTool(
      icon: Icons.local_fire_department_rounded,
      title: 'Recovery Metrics',
      subtitle: 'Track progress.',
      destination: _RecoveryDestination.recoveryMetrics,
    ),
    _RecoveryTool(
      icon: Icons.menu_book_rounded,
      title: 'Reflection Journal',
      subtitle: 'Capture learning.',
      destination: _RecoveryDestination.reflectionJournal,
    ),
    _RecoveryTool(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Implementation Intentions',
      subtitle: 'If-then plans.',
      destination: _RecoveryDestination.implementationIntentions,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);
    final delays = ref.watch(delaySessionProvider).asData?.value ?? const [];
    final erp = ref.watch(erpExerciseSessionProvider).asData?.value ?? const [];
    final steps = ref.watch(exposureStepProvider).asData?.value ?? const [];
    final responses =
        ref.watch(responsePreventionProvider).asData?.value ?? const [];
    final surfs = ref.watch(urgeSurfProvider).asData?.value ?? const [];
    final journals = ref.watch(journalProvider).asData?.value ?? const [];
    final ocds = ref.watch(ocdProvider).asData?.value ?? const [];

    final recoveryMetrics = AnalyticsService.buildRecoveryMetrics(
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

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0B0A), AppTheme.deepCharcoal],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 116),
            children: staggered([
              _CockpitHeader(streak: recoveryMetrics.practiceStreakDays),
              const SizedBox(height: 14),
              _DailyPracticeCard(
                weeklyActivity: recoveryMetrics.weeklyActivity,
                onStart: () => _open(context, _RecoveryDestination.guidedErp),
              ),
              const SizedBox(height: 12),
              _ToolSection(
                title: 'Free tools',
                actionLabel: 'See all',
                onAction: () => _showToolsSheet(
                  context,
                  ref,
                  title: 'Free tools',
                  tools: _freeTools,
                  isPro: isPro,
                ),
                child: _ToolGrid(
                  tools: _freeTools,
                  isPro: true,
                  onTap: (tool) => _openTool(context, ref, tool, isPro: true),
                ),
              ),
              const SizedBox(height: 12),
              _ToolSection(
                title: 'Pro tools',
                pro: true,
                actionLabel: 'See all',
                onAction: () => _showToolsSheet(
                  context,
                  ref,
                  title: 'Pro tools',
                  tools: _proTools,
                  isPro: isPro,
                  locked: !isPro,
                ),
                child: _ToolGrid(
                  tools: _proTools.take(4).toList(),
                  isPro: isPro,
                  locked: !isPro,
                  onTap: (tool) => _openTool(context, ref, tool, isPro: isPro),
                ),
              ),
              const SizedBox(height: 12),
              _ProgressCard(
                score: dashboard.recoveryScore,
                onTap: () {
                  if (!requirePro(context, ref)) return;
                  _open(context, _RecoveryDestination.recoveryMetrics);
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _openTool(
    BuildContext context,
    WidgetRef ref,
    _RecoveryTool tool, {
    required bool isPro,
  }) {
    if (!isPro && !requirePro(context, ref)) return;
    _open(context, tool.destination, fullscreen: tool.fullscreen);
  }

  void _showToolsSheet(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required List<_RecoveryTool> tools,
    required bool isPro,
    bool locked = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _ToolsSheet(
        title: title,
        tools: tools,
        locked: locked,
        isPro: isPro,
        onTap: (tool) {
          Navigator.of(sheetContext).pop();
          _openTool(context, ref, tool, isPro: isPro);
        },
      ),
    );
  }

  void _open(
    BuildContext context,
    _RecoveryDestination destination, {
    bool fullscreen = false,
  }) {
    final screen = _screenFor(destination);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: fullscreen,
        builder: (_) => screen,
      ),
    );
  }

  Widget _screenFor(_RecoveryDestination destination) {
    switch (destination) {
      case _RecoveryDestination.guidedErp:
        return const ErpExercisesScreen(showBack: true);
      case _RecoveryDestination.compulsionDelay:
        return const CompulsionDelayFlow();
      case _RecoveryDestination.emergencyToolkit:
        return const EmergencyToolkitScreen();
      case _RecoveryDestination.copingLibrary:
        return const CopingLibraryScreen();
      case _RecoveryDestination.exposureHierarchy:
        return const ExposureHierarchyScreen();
      case _RecoveryDestination.exposureMaterials:
        return const ExposureMaterialsScreen();
      case _RecoveryDestination.responsePrevention:
        return const ResponsePreventionScreen();
      case _RecoveryDestination.structuredPrograms:
        return const StructuredProgramsScreen();
      case _RecoveryDestination.urgeSurfing:
        return const UrgeSurfScreen();
      case _RecoveryDestination.uncertaintyTraining:
        return const UncertaintyTrainingScreen();
      case _RecoveryDestination.actionPlanner:
        return const ActionPlannerScreen();
      case _RecoveryDestination.behavioralExperiments:
        return const BehavioralExperimentsScreen();
      case _RecoveryDestination.recoveryMetrics:
        return const RecoveryMetricsScreen();
      case _RecoveryDestination.reflectionJournal:
        return const ExposureReflectionScreen();
      case _RecoveryDestination.implementationIntentions:
        return const ImplementationIntentionsScreen();
    }
  }
}

enum _RecoveryDestination {
  guidedErp,
  compulsionDelay,
  emergencyToolkit,
  copingLibrary,
  exposureHierarchy,
  exposureMaterials,
  responsePrevention,
  structuredPrograms,
  urgeSurfing,
  uncertaintyTraining,
  actionPlanner,
  behavioralExperiments,
  recoveryMetrics,
  reflectionJournal,
  implementationIntentions,
}

class _RecoveryTool {
  final IconData icon;
  final String title;
  final String subtitle;
  final _RecoveryDestination destination;
  final bool fullscreen;

  const _RecoveryTool({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
    this.fullscreen = false,
  });
}

class _CockpitHeader extends StatelessWidget {
  final int streak;

  const _CockpitHeader({required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recovery',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Tools and practices to help you respond to OCD differently.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _StreakPill(streak: streak),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int streak;

  const _StreakPill({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 13, 9),
      decoration: _cockpitDecoration(radius: 26),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.warmYellow.withValues(alpha: 0.14),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppTheme.warmYellow,
              size: 19,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                streak == 1 ? 'day streak' : 'day streak',
                style: _mutedStyle.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyPracticeCard extends StatelessWidget {
  final List<bool> weeklyActivity;
  final VoidCallback onStart;

  const _DailyPracticeCard({
    required this.weeklyActivity,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return _CockpitCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.warmYellow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF17130A),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily ERP practice',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'A small daily step builds long-term change.',
                      style: _mutedStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Start today'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _WeeklyPracticeRow(activity: weeklyActivity),
        ],
      ),
    );
  }
}

class _WeeklyPracticeRow extends StatelessWidget {
  final List<bool> activity;

  const _WeeklyPracticeRow({required this.activity});

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Column(
              children: [
                Text(
                  _labels[(today.subtract(Duration(days: 6 - i)).weekday - 1) %
                      7],
                  style: _mutedStyle.copyWith(fontSize: 10.5),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activity.length > i && activity[i]
                        ? AppTheme.warmYellow
                        : Colors.transparent,
                    border: Border.all(
                      color: activity.length > i && activity[i]
                          ? AppTheme.warmYellow
                          : const Color(0xFF3B3935),
                      width: 1.5,
                    ),
                  ),
                  child: activity.length > i && activity[i]
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF17130A),
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ToolSection extends StatelessWidget {
  final String title;
  final bool pro;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;

  const _ToolSection({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.child,
    this.pro = false,
  });

  @override
  Widget build(BuildContext context) {
    return _CockpitCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              if (pro) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warmYellow.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'PRO',
                    style: TextStyle(
                      color: AppTheme.warmYellow,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: AppTheme.warmYellow,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ToolGrid extends StatelessWidget {
  final List<_RecoveryTool> tools;
  final bool isPro;
  final bool locked;
  final ValueChanged<_RecoveryTool> onTap;

  const _ToolGrid({
    required this.tools,
    required this.isPro,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 350 ? 2 : 4;
        final gap = 8.0;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tool in tools)
              SizedBox(
                width: tileWidth,
                child: _ToolTile(
                  tool: tool,
                  locked: locked || !isPro,
                  onTap: () => onTap(tool),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ToolTile extends StatelessWidget {
  final _RecoveryTool tool;
  final bool locked;
  final VoidCallback onTap;

  const _ToolTile({
    required this.tool,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        height: 126,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF181817),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2D2B27)),
        ),
        child: Stack(
          children: [
            if (locked)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  LineIcons.lock,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(tool.icon, color: AppTheme.warmYellow, size: 27),
                const Spacer(),
                Text(
                  tool.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tool.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _mutedStyle.copyWith(fontSize: 10.5, height: 1.18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int score;
  final VoidCallback onTap;

  const _ProgressCard({required this.score, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: _CockpitCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _ProgressRing(score: score),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recovery progress',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text("You've come a long way.", style: _mutedStyle),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: score.clamp(0, 100) / 100,
                          minHeight: 8,
                          backgroundColor: const Color(0xFF2B2926),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.warmYellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  LineIcons.angleRight,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int score;

  const _ProgressRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: CustomPaint(
        painter: _ProgressRingPainter(score),
        child: Center(
          child: Text(
            '$score%',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19),
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final int score;

  const _ProgressRingPainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 5;
    final track = Paint()
      ..color = const Color(0xFF2B2926)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..color = AppTheme.warmYellow
      ..strokeWidth = 6
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
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

class _ToolsSheet extends StatelessWidget {
  final String title;
  final List<_RecoveryTool> tools;
  final bool locked;
  final bool isPro;
  final ValueChanged<_RecoveryTool> onTap;

  const _ToolsSheet({
    required this.title,
    required this.tools,
    required this.locked,
    required this.isPro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: _cockpitDecoration(radius: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: _ToolGrid(
                  tools: tools,
                  isPro: isPro,
                  locked: locked,
                  onTap: onTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CockpitCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _CockpitCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: _cockpitDecoration(),
      child: child,
    );
  }
}

BoxDecoration _cockpitDecoration({double radius = 20}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1B1B19), Color(0xFF141413)],
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

const _mutedStyle = TextStyle(
  color: AppTheme.textSecondary,
  fontSize: 12,
  height: 1.25,
);
