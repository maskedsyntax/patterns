import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../widgets/section_intro.dart';
import 'exposure_materials_screen.dart';

BoxDecoration _softDecoration(ThemeData theme, {double radius = 22}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor),
  );
}

// ---------------------------------------------------------------------------
// List screen
// ---------------------------------------------------------------------------

class ExposureHierarchyScreen extends ConsumerWidget {
  const ExposureHierarchyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hierarchies = ref.watch(exposureHierarchyProvider);
    final stepsAsync = ref.watch(exposureStepProvider);
    final steps = stepsAsync.asData?.value ?? const <ExposureStep>[];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 116),
          children: staggered([
            Row(
              children: [
                _CircleBackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Exposure Hierarchy',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openBuilder(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Build a ladder of exposures and climb it one rung at a time.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            const SectionIntro(id: 'exposureHierarchy'),
            hierarchies.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(onCreate: () => _openBuilder(context));
                }
                return Column(
                  children: [
                    for (final h in items) ...[
                      _HierarchyCard(
                        hierarchy: h,
                        steps: steps
                            .where((s) => s.hierarchyId == h.id)
                            .toList(),
                        onOpen: () => _openDetail(context, h),
                        onArchive: () => _confirmArchive(context, ref, h),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Text(
                'Your hierarchies are unavailable right now.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _openBuilder(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const ExposureHierarchyBuilderScreen(),
      ),
    );
  }

  void _openDetail(BuildContext context, ExposureHierarchy hierarchy) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExposureHierarchyDetailScreen(hierarchy: hierarchy),
      ),
    );
  }

  void _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    ExposureHierarchy hierarchy,
  ) {
    final id = hierarchy.id;
    if (id == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(20),
          decoration: _softDecoration(Theme.of(sheetContext), radius: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Archive this hierarchy?',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'It will leave your list. This is just to keep things tidy — '
                'progress you made still counts.',
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
                        await ref
                            .read(exposureHierarchyProvider.notifier)
                            .archiveHierarchy(id);
                      },
                      child: const Text('Archive'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HierarchyCard extends StatelessWidget {
  final ExposureHierarchy hierarchy;
  final List<ExposureStep> steps;
  final VoidCallback onOpen;
  final VoidCallback onArchive;

  const _HierarchyCard({
    required this.hierarchy,
    required this.steps,
    required this.onOpen,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = steps.length;
    final done = steps
        .where((s) => s.status == ExposureStepStatus.completed)
        .length;
    final pct = total == 0 ? 0.0 : done / total;

    return PressScale(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _softDecoration(theme),
        child: Row(
          children: [
            _ProgressRing(value: pct),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hierarchy.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total == 0
                        ? hierarchy.theme
                        : '$done of $total steps · ${hierarchy.theme}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                LineIcons.verticalEllipsis,
                color: AppTheme.textSecondary,
                size: 18,
              ),
              onSelected: (value) {
                if (value == 'archive') onArchive();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'archive', child: Text('Archive')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _softDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.stairs_rounded, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            'Start your first ladder',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'List exposures from easiest to hardest, then work your way up at '
            'your own pace.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreate,
              child: const Text('Build a hierarchy'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Builder screen
// ---------------------------------------------------------------------------

class _DraftStep {
  final TextEditingController description;
  double difficulty = 3;
  double anxiety = 5;

  _DraftStep({String text = ''})
    : description = TextEditingController(text: text);

  void dispose() => description.dispose();
}

class ExposureHierarchyBuilderScreen extends ConsumerStatefulWidget {
  const ExposureHierarchyBuilderScreen({super.key});

  @override
  ConsumerState<ExposureHierarchyBuilderScreen> createState() =>
      _ExposureHierarchyBuilderScreenState();
}

class _ExposureHierarchyBuilderScreenState
    extends ConsumerState<ExposureHierarchyBuilderScreen> {
  final _titleController = TextEditingController();
  final _themeController = TextEditingController();
  final List<_DraftStep> _steps = [_DraftStep()];
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _themeController.dispose();
    for (final step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() => _steps.add(_DraftStep()));
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index).dispose();
      if (_steps.isEmpty) _steps.add(_DraftStep());
    });
  }

  void _move(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _steps.length) return;
    setState(() {
      final step = _steps.removeAt(index);
      _steps.insert(target, step);
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final theme = _themeController.text.trim();
    final steps = _steps
        .where((s) => s.description.text.trim().isNotEmpty)
        .toList();

    if (title.isEmpty) {
      showAppSnackBar(
        context,
        'Give your hierarchy a name to get started.',
        type: ToastType.info,
      );
      return;
    }
    if (steps.isEmpty) {
      showAppSnackBar(
        context,
        'Add at least one exposure step.',
        type: ToastType.info,
      );
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final hierarchy = ExposureHierarchy(
      title: title,
      theme: theme.isEmpty ? 'General' : theme,
      createdAt: now,
      updatedAt: now,
    );
    final stepModels = [
      for (var i = 0; i < steps.length; i++)
        ExposureStep(
          orderIndex: i,
          description: steps[i].description.text.trim(),
          difficulty: steps[i].difficulty.round(),
          anxietyRating: steps[i].anxiety.round(),
        ),
    ];

    await ref
        .read(exposureHierarchyProvider.notifier)
        .addHierarchyWithSteps(hierarchy, stepModels);

    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(
      context,
      'Hierarchy created. Take it one rung at a time.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          children: staggered([
            Row(
              children: [
                _CircleBackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'New hierarchy',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _LabeledField(
              label: 'Name',
              hint: 'e.g. Touching door handles',
              controller: _titleController,
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'Theme (optional)',
              hint: 'e.g. Contamination',
              controller: _themeController,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Steps — easiest first',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addStep,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _steps.length; i++) ...[
              _StepEditorCard(
                index: i,
                total: _steps.length,
                draft: _steps[i],
                onChanged: () => setState(() {}),
                onRemove: () => _removeStep(i),
                onMoveUp: () => _move(i, -1),
                onMoveDown: () => _move(i, 1),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create hierarchy'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _StepEditorCard extends StatelessWidget {
  final int index;
  final int total;
  final _DraftStep draft;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const _StepEditorCard({
    required this.index,
    required this.total,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softDecoration(theme, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Step ${index + 1}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              _MiniIconButton(
                icon: LineIcons.angleUp,
                onTap: index == 0 ? null : onMoveUp,
              ),
              _MiniIconButton(
                icon: LineIcons.angleDown,
                onTap: index == total - 1 ? null : onMoveDown,
              ),
              _MiniIconButton(icon: LineIcons.times, onTap: onRemove),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: draft.description,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'What will you expose yourself to?',
            ),
          ),
          const SizedBox(height: 8),
          _RatingSlider(
            label: 'Difficulty',
            value: draft.difficulty,
            onChanged: (v) {
              draft.difficulty = v;
              onChanged();
            },
          ),
          _RatingSlider(
            label: 'Anticipated anxiety',
            value: draft.anxiety,
            onChanged: (v) {
              draft.anxiety = v;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail / climb screen
// ---------------------------------------------------------------------------

class ExposureHierarchyDetailScreen extends ConsumerWidget {
  final ExposureHierarchy hierarchy;
  const ExposureHierarchyDetailScreen({super.key, required this.hierarchy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stepsAsync = ref.watch(exposureStepProvider);
    final materials =
        ref.watch(exposureMaterialProvider).asData?.value ??
        const <ExposureMaterial>[];
    final steps =
        (stepsAsync.asData?.value ?? const <ExposureStep>[])
            .where((s) => s.hierarchyId == hierarchy.id)
            .toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final total = steps.length;
    final done = steps
        .where((s) => s.status == ExposureStepStatus.completed)
        .length;
    final pct = total == 0 ? 0.0 : done / total;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          children: staggered([
            Row(
              children: [
                _CircleBackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hierarchy.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        hierarchy.theme,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _ProgressRing(value: pct),
              ],
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < steps.length; i++) ...[
              _ClimbStepCard(
                number: i + 1,
                step: steps[i],
                onStatus: (status) {
                  ref
                      .read(exposureStepProvider.notifier)
                      .updateStep(
                        steps[i].copyWith(
                          status: status,
                          completedAt: status == ExposureStepStatus.completed
                              ? DateTime.now()
                              : null,
                          clearCompletedAt:
                              status != ExposureStepStatus.completed,
                        ),
                      );
                },
              ),
              for (final m in materials.where(
                (x) => x.linkedStepId == steps[i].id,
              )) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: MaterialCard(
                    material: m,
                    onDelete: () => ref
                        .read(exposureMaterialProvider.notifier)
                        .delete(m),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExposureMaterialsScreen(
                        linkedStepId: steps[i].id,
                        linkedHierarchyId: hierarchy.id,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Material'),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ]),
        ),
      ),
    );
  }
}

class _ClimbStepCard extends StatelessWidget {
  final int number;
  final ExposureStep step;
  final ValueChanged<ExposureStepStatus> onStatus;

  const _ClimbStepCard({
    required this.number,
    required this.step,
    required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = step.status == ExposureStepStatus.completed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.14),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Text(
                        '$number',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Difficulty ${step.difficulty}/10 · Anxiety ${step.anxietyRating}/10',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _StatusPicker(status: step.status, onChanged: onStatus),
        ],
      ),
    );
  }
}

class _StatusPicker extends StatelessWidget {
  final ExposureStepStatus status;
  final ValueChanged<ExposureStepStatus> onChanged;

  const _StatusPicker({required this.status, required this.onChanged});

  static const _labels = {
    ExposureStepStatus.notStarted: 'Not started',
    ExposureStepStatus.inProgress: 'In progress',
    ExposureStepStatus.completed: 'Done',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          for (final entry in _labels.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.key),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: status == entry.key
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    entry.value,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: status == entry.key
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _RatingSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _RatingSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '${value.round()}/10',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double value;
  const _ProgressRing({required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 4,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: _softDecoration(theme, radius: 14),
        child: const Icon(LineIcons.angleLeft, size: 20),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _MiniIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: 18,
        color: disabled ? Theme.of(context).disabledColor : null,
      ),
    );
  }
}
