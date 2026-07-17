import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

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
import 'ybocs_screen.dart';

/// Daily recovery cockpit: today-first ERP, compact tools, and visible progress.
class RecoveryHubScreen extends ConsumerWidget {
  const RecoveryHubScreen({super.key});

  /// Fast-access tools for a hard moment. These also appear under their journey
  /// stage below — a distressed user must not have to scan a journey to find a
  /// grounding tool. All three are free.
  static const _sosTools = <_RecoveryTool>[
    _RecoveryTool(
      icon: Icons.health_and_safety_rounded,
      title: 'Emergency Toolkit',
      subtitle: 'Fast support.',
      destination: _RecoveryDestination.emergencyToolkit,
      stage: _Stage.practice,
    ),
    _RecoveryTool(
      icon: Icons.spa_rounded,
      title: 'Coping Library',
      subtitle: 'Ground and reset.',
      destination: _RecoveryDestination.copingLibrary,
      stage: _Stage.practice,
    ),
    _RecoveryTool(
      icon: Icons.hourglass_bottom_rounded,
      title: 'Compulsion Delay',
      subtitle: 'Create space.',
      destination: _RecoveryDestination.compulsionDelay,
      stage: _Stage.practice,
      fullscreen: true,
    ),
  ];

  /// The full library, tagged by ERP journey stage and Pro status. Rendered
  /// grouped so users find a tool by where they are in their work rather than
  /// scanning a flat wall of tiles.
  static const _tools = <_RecoveryTool>[
    // Assess — see where you are.
    _RecoveryTool(
      icon: Icons.fact_check_rounded,
      title: 'OCD Self-Check',
      subtitle: 'Y-BOCS check-in.',
      destination: _RecoveryDestination.ybocsSelfCheck,
      stage: _Stage.assess,
      fullscreen: true,
    ),
    _RecoveryTool(
      icon: Icons.local_fire_department_rounded,
      title: 'Recovery Metrics',
      subtitle: 'Track progress.',
      destination: _RecoveryDestination.recoveryMetrics,
      stage: _Stage.assess,
      pro: true,
    ),
    // Plan — set up your practice.
    _RecoveryTool(
      icon: Icons.stairs_rounded,
      title: 'Exposure Hierarchy',
      subtitle: 'Build your ladder.',
      destination: _RecoveryDestination.exposureHierarchy,
      stage: _Stage.plan,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.folder_special_rounded,
      title: 'Exposure Materials',
      subtitle: 'Scripts and links.',
      destination: _RecoveryDestination.exposureMaterials,
      stage: _Stage.plan,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.calendar_month_rounded,
      title: 'Structured Programs',
      subtitle: 'Guided weeks.',
      destination: _RecoveryDestination.structuredPrograms,
      stage: _Stage.plan,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.checklist_rounded,
      title: 'Action Planner',
      subtitle: 'Plan responses.',
      destination: _RecoveryDestination.actionPlanner,
      stage: _Stage.plan,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Implementation Intentions',
      subtitle: 'If-then plans.',
      destination: _RecoveryDestination.implementationIntentions,
      stage: _Stage.plan,
      pro: true,
    ),
    // Practice — do the reps.
    _RecoveryTool(
      icon: Icons.self_improvement_rounded,
      title: 'Guided ERP',
      subtitle: 'Practice a plan.',
      destination: _RecoveryDestination.guidedErp,
      stage: _Stage.practice,
    ),
    _RecoveryTool(
      icon: Icons.hourglass_bottom_rounded,
      title: 'Compulsion Delay',
      subtitle: 'Create space.',
      destination: _RecoveryDestination.compulsionDelay,
      stage: _Stage.practice,
      fullscreen: true,
    ),
    _RecoveryTool(
      icon: Icons.waves_rounded,
      title: 'Urge Surfing',
      subtitle: 'Ride the wave.',
      destination: _RecoveryDestination.urgeSurfing,
      stage: _Stage.practice,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.shield_rounded,
      title: 'Response Prevention',
      subtitle: 'Stay on track.',
      destination: _RecoveryDestination.responsePrevention,
      stage: _Stage.practice,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.help_outline_rounded,
      title: 'Uncertainty Training',
      subtitle: 'Practice maybe.',
      destination: _RecoveryDestination.uncertaintyTraining,
      stage: _Stage.practice,
      pro: true,
    ),
    // Review — reflect and learn.
    _RecoveryTool(
      icon: Icons.science_rounded,
      title: 'Behavioral Experiments',
      subtitle: 'Test OCD.',
      destination: _RecoveryDestination.behavioralExperiments,
      stage: _Stage.review,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.menu_book_rounded,
      title: 'Reflection Journal',
      subtitle: 'Capture learning.',
      destination: _RecoveryDestination.reflectionJournal,
      stage: _Stage.review,
      pro: true,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);

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
              const _RecoveryHeader(),
              const SizedBox(height: 16),
              _SosStrip(
                tools: _sosTools,
                onTap: (tool) => _open(
                  context,
                  tool.destination,
                  fullscreen: tool.fullscreen,
                ),
              ),
              const SizedBox(height: 18),
              for (final stage in _Stage.values) ...[
                _ToolSection(
                  title: stage.title,
                  subtitle: stage.subtitle,
                  child: _ToolList(
                    tools: _tools.where((t) => t.stage == stage).toList(),
                    isPro: isPro,
                    onTap: (tool) =>
                        _openTool(context, ref, tool, isPro: isPro),
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
    if (tool.pro && !isPro && !requirePro(context, ref)) return;
    _open(context, tool.destination, fullscreen: tool.fullscreen);
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
      case _RecoveryDestination.ybocsSelfCheck:
        return const YbocsScreen();
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
  ybocsSelfCheck,
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

/// The ERP journey stages the library is grouped into, ordered as a user
/// progresses. Plain-language titles/subtitles keep the framing calm.
enum _Stage {
  assess('Assess', 'See where you are.'),
  plan('Plan', 'Set up your practice.'),
  practice('Practice', 'Do the reps.'),
  review('Review', 'Reflect and learn.');

  const _Stage(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _RecoveryTool {
  final IconData icon;
  final String title;
  final String subtitle;
  final _RecoveryDestination destination;
  final _Stage stage;
  final bool pro;
  final bool fullscreen;

  const _RecoveryTool({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
    required this.stage,
    this.pro = false,
    this.fullscreen = false,
  });
}

class _RecoveryHeader extends StatelessWidget {
  const _RecoveryHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
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
          'Tools and practices, grouped by where you are in your work.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// Persistent quick-access to the in-the-moment tools, kept above the journey
/// stages so a distressed user reaches grounding in one tap.
class _SosStrip extends StatelessWidget {
  final List<_RecoveryTool> tools;
  final ValueChanged<_RecoveryTool> onTap;

  const _SosStrip({required this.tools, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _CockpitCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: AppTheme.warmYellow,
                size: 16,
              ),
              SizedBox(width: 7),
              Text(
                'Need help right now?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < tools.length; i++) ...[
                if (i != 0) const SizedBox(width: 8),
                Expanded(
                  child: _SosButton(
                    tool: tools[i],
                    onTap: () => onTap(tools[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  final _RecoveryTool tool;
  final VoidCallback onTap;

  const _SosButton({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF181817),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2D2B27)),
        ),
        child: Column(
          children: [
            Icon(tool.icon, color: AppTheme.warmYellow, size: 22),
            const SizedBox(height: 7),
            Text(
              tool.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ToolSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _CockpitCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(subtitle, style: _mutedStyle.copyWith(fontSize: 12)),
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

/// Compact full-width rows for a stage's tools. Rows fill the card edge to edge
/// and stay tidy whether a stage holds two tools or five — no empty grid cells
/// or tall tiles with dead space in the middle.
class _ToolList extends StatelessWidget {
  final List<_RecoveryTool> tools;
  final bool isPro;
  final ValueChanged<_RecoveryTool> onTap;

  const _ToolList({
    required this.tools,
    required this.isPro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tools.length; i++) ...[
          if (i != 0)
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFF262521),
            ),
          _ToolRow(
            tool: tools[i],
            locked: tools[i].pro && !isPro,
            onTap: () => onTap(tools[i]),
          ),
        ],
      ],
    );
  }
}

class _ToolRow extends StatelessWidget {
  final _RecoveryTool tool;
  final bool locked;
  final VoidCallback onTap;

  const _ToolRow({
    required this.tool,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.warmYellow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tool.icon, color: AppTheme.warmYellow, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tool.subtitle,
                    style: _mutedStyle.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              locked ? LineIcons.lock : LineIcons.angleRight,
              color: AppTheme.textSecondary,
              size: locked ? 15 : 18,
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
