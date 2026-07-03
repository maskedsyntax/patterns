import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../preferences.dart';
import '../widgets/pro_gate.dart';
import '../widgets/section_intro.dart';
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

/// The "Recovery" tab — a hub that gathers every ERP tool. Free tools sit on
/// top; Pro tools appear below with a lock badge until Patterns Pro is unlocked.
class RecoveryHubScreen extends ConsumerWidget {
  const RecoveryHubScreen({super.key});

  static const _proTools = <_ProTool>[
    _ProTool(
      icon: Icons.stairs_rounded,
      title: 'Exposure Hierarchy',
      subtitle: 'Build a fear ladder and climb it step by step',
    ),
    _ProTool(
      icon: Icons.local_fire_department_rounded,
      title: 'Recovery Metrics',
      subtitle: 'Streaks and progress across all your ERP work',
    ),
    _ProTool(
      icon: Icons.waves_rounded,
      title: 'Urge Surfing',
      subtitle: 'Ride an urge and watch it rise and fall',
    ),
    _ProTool(
      icon: Icons.shield_rounded,
      title: 'Response Prevention',
      subtitle: 'Log how you resisted after a trigger',
    ),
    _ProTool(
      icon: Icons.calendar_month_rounded,
      title: 'Structured Programs',
      subtitle: 'Multi-week guided ERP progressions',
    ),
    _ProTool(
      icon: Icons.science_rounded,
      title: 'Behavioral Experiments',
      subtitle: 'Test what OCD predicts against reality',
    ),
    _ProTool(
      icon: Icons.menu_book_rounded,
      title: 'Reflection Journal',
      subtitle: 'Capture insights after each exposure',
    ),
    _ProTool(
      icon: Icons.checklist_rounded,
      title: 'Action Planner',
      subtitle: 'Plan your response before a trigger hits',
    ),
    _ProTool(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Implementation Intentions',
      subtitle: '"If this happens, then I will…" plans',
    ),
    _ProTool(
      icon: Icons.help_outline_rounded,
      title: 'Uncertainty Training',
      subtitle: 'Practice living with not knowing',
    ),
    _ProTool(
      icon: Icons.folder_special_rounded,
      title: 'Exposure Materials',
      subtitle: 'Scripts, loop tapes, images & links for exposures',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPro = ref.watch(proProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 116),
          children: staggered([
            _HubHeader(theme: theme),
            const SizedBox(height: 20),
            const SectionIntro(id: 'recoveryHub'),
            _SectionLabel(theme: theme, label: 'Practice'),
            const SizedBox(height: 12),
            _ToolCard(
              icon: Icons.self_improvement_rounded,
              title: 'Guided ERP',
              subtitle: 'Reuse a plan, practice, and learn from the result',
              onTap: () => _push(context, const ErpExercisesScreen(showBack: true)),
            ),
            const SizedBox(height: 10),
            _ToolCard(
              icon: Icons.hourglass_bottom_rounded,
              title: 'Compulsion Delay',
              subtitle: 'Sit with the urge before acting on it',
              onTap: () => _pushFullscreen(context, const CompulsionDelayFlow()),
            ),
            const SizedBox(height: 10),
            _ToolCard(
              icon: Icons.health_and_safety_rounded,
              title: 'Emergency toolkit',
              subtitle: 'Quick help for a high-distress moment',
              onTap: () => _push(context, const EmergencyToolkitScreen()),
            ),
            const SizedBox(height: 10),
            _ToolCard(
              icon: Icons.spa_rounded,
              title: 'Coping library',
              subtitle: 'Grounding, acceptance, and relaxation',
              onTap: () => _push(context, const CopingLibraryScreen()),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _SectionLabel(theme: theme, label: 'Pro tools'),
                const SizedBox(width: 8),
                if (!isPro) const ProLockBadge(),
              ],
            ),
            const SizedBox(height: 12),
            for (final tool in _proTools) ...[
              _ToolCard(
                icon: tool.icon,
                title: tool.title,
                subtitle: tool.subtitle,
                locked: !isPro,
                onTap: () {
                  if (!requirePro(context, ref)) return;
                  final page = _pageFor(tool.title);
                  if (page != null) {
                    _push(context, page);
                  } else {
                    showAppSnackBar(
                      context,
                      '${tool.title} is coming soon.',
                      type: ToastType.info,
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ]),
        ),
      ),
    );
  }

  /// Returns the destination screen for a built Pro tool, or null if it's not
  /// implemented yet (shows a "coming soon" toast instead).
  Widget? _pageFor(String title) {
    switch (title) {
      case 'Exposure Hierarchy':
        return const ExposureHierarchyScreen();
      case 'Recovery Metrics':
        return const RecoveryMetricsScreen();
      case 'Urge Surfing':
        return const UrgeSurfScreen();
      case 'Response Prevention':
        return const ResponsePreventionScreen();
      case 'Structured Programs':
        return const StructuredProgramsScreen();
      case 'Behavioral Experiments':
        return const BehavioralExperimentsScreen();
      case 'Reflection Journal':
        return const ExposureReflectionScreen();
      case 'Action Planner':
        return const ActionPlannerScreen();
      case 'Implementation Intentions':
        return const ImplementationIntentionsScreen();
      case 'Uncertainty Training':
        return const UncertaintyTrainingScreen();
      case 'Exposure Materials':
        return const ExposureMaterialsScreen();
      default:
        return null;
    }
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _pushFullscreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => screen),
    );
  }
}

class _ProTool {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProTool({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _HubHeader extends StatelessWidget {
  final ThemeData theme;
  const _HubHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recovery',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Practice the skills that loosen OCD's grip.",
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final ThemeData theme;
  final String label;
  const _SectionLabel({required this.theme, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool locked;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (locked)
              const ProLockBadge()
            else
              Icon(
                LineIcons.angleRight,
                color: AppTheme.textSecondary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
