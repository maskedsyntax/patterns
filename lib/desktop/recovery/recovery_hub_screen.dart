import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../../app_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pro_gate.dart';
import '../widgets/desktop_chrome.dart';
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

/// Desktop Recovery: Master-Detail dashboard matching the high-fidelity mockup.
class RecoveryHubScreen extends ConsumerStatefulWidget {
  const RecoveryHubScreen({super.key});

  @override
  ConsumerState<RecoveryHubScreen> createState() => _RecoveryHubScreenState();
}

class _RecoveryHubScreenState extends ConsumerState<RecoveryHubScreen> {
  _RecoveryDestination? _selected;

  static const _sosTools = <_RecoveryTool>[
    _RecoveryTool(
      icon: Icons.health_and_safety_rounded,
      title: 'Emergency Toolkit',
      subtitle: 'Fast support for intense moments',
      destination: _RecoveryDestination.emergencyToolkit,
    ),
    _RecoveryTool(
      icon: Icons.spa_rounded,
      title: 'Coping Library',
      subtitle: 'Grounding and coping strategies',
      destination: _RecoveryDestination.copingLibrary,
    ),
    _RecoveryTool(
      icon: Icons.hourglass_bottom_rounded,
      title: 'Compulsion Delay',
      subtitle: 'Create space before acting',
      destination: _RecoveryDestination.compulsionDelay,
    ),
  ];

  static const _assessTools = <_RecoveryTool>[
    _RecoveryTool(
      icon: Icons.fact_check_rounded,
      title: 'OCD Self-Check',
      subtitle: 'Y-BOCS inspired check-in',
      destination: _RecoveryDestination.ybocsSelfCheck,
    ),
    _RecoveryTool(
      icon: Icons.bar_chart_rounded,
      title: 'Recovery Metrics',
      subtitle: 'Track your progress',
      destination: _RecoveryDestination.recoveryMetrics,
      pro: true,
    ),
  ];

  static const _planTools = <_RecoveryTool>[
    _RecoveryTool(
      icon: Icons.layers_rounded,
      title: 'Exposure Hierarchy',
      subtitle: 'Build your ladder',
      destination: _RecoveryDestination.exposureHierarchy,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.folder_special_rounded,
      title: 'Exposure Materials',
      subtitle: 'Scripts and links',
      destination: _RecoveryDestination.exposureMaterials,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.checklist_rounded,
      title: 'Action Planner',
      subtitle: 'Plan responses',
      destination: _RecoveryDestination.actionPlanner,
      pro: true,
    ),
  ];

  static const _practiceTools = <_RecoveryTool>[
    _RecoveryTool(
      icon: Icons.self_improvement_rounded,
      title: 'Guided ERP',
      subtitle: 'Practice with guidance',
      destination: _RecoveryDestination.guidedErp,
    ),
    _RecoveryTool(
      icon: Icons.help_outline_rounded,
      title: 'Uncertainty Training',
      subtitle: 'Practice maybe',
      destination: _RecoveryDestination.uncertaintyTraining,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.waves_rounded,
      title: 'Urge Surfing',
      subtitle: 'Ride the wave',
      destination: _RecoveryDestination.urgeSurfing,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.shield_rounded,
      title: 'Response Prevention',
      subtitle: 'Stay on track',
      destination: _RecoveryDestination.responsePrevention,
      pro: true,
    ),
  ];

  static const _reviewTools = <_RecoveryTool>[
    _RecoveryTool(
      icon: Icons.science_rounded,
      title: 'Behavioral Experiments',
      subtitle: 'Test OCD beliefs',
      destination: _RecoveryDestination.behavioralExperiments,
      pro: true,
    ),
    _RecoveryTool(
      icon: Icons.menu_book_rounded,
      title: 'Reflection Journal',
      subtitle: 'Capture learning',
      destination: _RecoveryDestination.reflectionJournal,
      pro: true,
    ),
  ];

  String get _detailTitle {
    if (_selected == null) return 'Recovery';
    final all = [
      ..._sosTools,
      ..._assessTools,
      ..._planTools,
      ..._practiceTools,
      ..._reviewTools
    ];
    return all
        .where((t) => t.destination == _selected)
        .map((t) => t.title)
        .firstOrNull ??
        'Recovery';
  }

  void _select(BuildContext context, WidgetRef ref, _RecoveryTool tool) {
    if (tool.pro && !ref.read(proProvider) && !requirePro(context, ref)) {
      return;
    }
    setState(() => _selected = tool.destination);
  }

  Widget _screenFor(_RecoveryDestination destination) {
    switch (destination) {
      case _RecoveryDestination.guidedErp:
        return const ErpExercisesScreen(showBack: false);
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

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(proProvider);
    final theme = Theme.of(context);

    return DesktopPageScaffold(
      title: _detailTitle,
      actions: [
        if (_selected != null)
          IconButton(
            tooltip: 'Back to library',
            onPressed: () => setState(() => _selected = null),
            icon: const Icon(LineIcons.angleLeft, size: 18),
          ),
      ],
      body: _selected != null
          ? KeyedSubtree(
              key: ValueKey(_selected!.name),
              child: Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute<void>(
                    settings: settings,
                    builder: (_) => MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeBottom: true,
                      child: _screenFor(_selected!),
                    ),
                  );
                },
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Column: Workspace tools
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: const EdgeInsets.only(right: 32),
                      children: [
                        Text(
                          'Recovery',
                          style: TextStyle(
                            fontFamily: AppTheme.displayFamily,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tools and guidance to support your healing.',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.55),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Section 1: Need help now
                        _buildSectionHeader(theme, 'Need help now'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final tool in _sosTools)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _VerticalToolCard(
                                    icon: tool.icon,
                                    title: tool.title,
                                    subtitle: tool.subtitle,
                                    onTap: () => _select(context, ref, tool),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Section 2: Assess
                        _buildSectionHeader(theme, 'Assess'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final tool in _assessTools)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _HorizontalToolCard(
                                    icon: tool.icon,
                                    title: tool.title,
                                    subtitle: tool.subtitle,
                                    locked: tool.pro && !isPro,
                                    onTap: () => _select(context, ref, tool),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Section 3: Plan & Prepare
                        _buildSectionHeader(theme, 'Plan & Prepare'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final tool in _planTools)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _HorizontalToolCard(
                                    icon: tool.icon,
                                    title: tool.title,
                                    subtitle: tool.subtitle,
                                    locked: tool.pro && !isPro,
                                    onTap: () => _select(context, ref, tool),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Section 4: Practice
                        _buildSectionHeader(theme, 'Practice'),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 3.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            for (final tool in _practiceTools)
                              _HorizontalToolCard(
                                icon: tool.icon,
                                title: tool.title,
                                subtitle: tool.subtitle,
                                locked: tool.pro && !isPro,
                                onTap: () => _select(context, ref, tool),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Section 5: Review
                        _buildSectionHeader(theme, 'Review'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final tool in _reviewTools)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _HorizontalToolCard(
                                    icon: tool.icon,
                                    title: tool.title,
                                    subtitle: tool.subtitle,
                                    locked: tool.pro && !isPro,
                                    onTap: () => _select(context, ref, tool),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right Column: Winding path mountain illustration
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.dividerColor),
                        image: const DecorationImage(
                          image: AssetImage('assets/recovery_path_bg.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.85),
                              Colors.black.withOpacity(0.0),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                          ),
                        ),
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Healing isn't linear,\nbut progress is real.",
                              style: TextStyle(
                                fontFamily: AppTheme.displayFamily,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "You're showing up, that matters.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.75),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }
}

enum _RecoveryDestination {
  emergencyToolkit,
  copingLibrary,
  compulsionDelay,
  ybocsSelfCheck,
  recoveryMetrics,
  exposureHierarchy,
  exposureMaterials,
  structuredPrograms,
  urgeSurfing,
  responsePrevention,
  uncertaintyTraining,
  actionPlanner,
  behavioralExperiments,
  reflectionJournal,
  implementationIntentions,
  guidedErp,
}

class _RecoveryTool {
  final IconData icon;
  final String title;
  final String subtitle;
  final _RecoveryDestination destination;
  final bool pro;

  const _RecoveryTool({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
    this.pro = false,
  });
}

/// Vertical card button (used in Need help now)
class _VerticalToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _VerticalToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary, // Gold
                  size: 24,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal card button (used in Assess, Practice, Plan, etc.)
class _HorizontalToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool locked;
  final VoidCallback onTap;

  const _HorizontalToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.locked,
    required this.onTap,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary, // Gold
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (locked)
                Icon(
                  LineIcons.lock,
                  size: 15,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
