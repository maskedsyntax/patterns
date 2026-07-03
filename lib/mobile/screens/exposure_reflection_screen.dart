import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../widgets/recovery_ui.dart';
import '../widgets/section_intro.dart';

class ExposureReflectionScreen extends ConsumerWidget {
  const ExposureReflectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reflections = ref.watch(exposureReflectionProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 116),
          children: staggered([
            Row(
              children: [
                CircleBackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reflection Journal',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openCreate(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Capture what you learned after an exposure, while it is fresh.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            const SectionIntro(id: 'exposureReflection'),
            reflections.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(onCreate: () => _openCreate(context));
                }
                return Column(
                  children: [
                    for (final r in items) ...[
                      _ReflectionCard(
                        reflection: r,
                        onDelete: () => _confirmDelete(context, ref, r),
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
                'Your reflections are unavailable right now.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const ExposureReflectionEditScreen(),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ExposureReflection reflection,
  ) {
    final id = reflection.id;
    if (id == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(20),
          decoration: recoverySoftDecoration(
            Theme.of(sheetContext),
            radius: 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete this reflection?',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'It will be removed for good.',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await ref
                            .read(exposureReflectionProvider.notifier)
                            .delete(id);
                      },
                      child: const Text('Delete'),
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

class _ReflectionCard extends StatelessWidget {
  final ExposureReflection reflection;
  final VoidCallback onDelete;

  const _ReflectionCard({required this.reflection, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: recoverySoftDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reflection.whatHappened,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM d').format(reflection.datetime),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (reflection.whatILearned.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              reflection.whatILearned,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
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
      decoration: recoverySoftDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            'Reflect on an exposure',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A few prompts to help you notice what OCD got wrong and what you '
            'learned.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreate,
              child: const Text('New reflection'),
            ),
          ),
        ],
      ),
    );
  }
}

class ExposureReflectionEditScreen extends ConsumerStatefulWidget {
  const ExposureReflectionEditScreen({super.key});

  @override
  ConsumerState<ExposureReflectionEditScreen> createState() =>
      _ExposureReflectionEditScreenState();
}

class _ExposureReflectionEditScreenState
    extends ConsumerState<ExposureReflectionEditScreen> {
  final _whatHappened = TextEditingController();
  final _ocdPredicted = TextEditingController();
  final _actuallyHappened = TextEditingController();
  final _whatILearned = TextEditingController();
  final _doDifferently = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _whatHappened.dispose();
    _ocdPredicted.dispose();
    _actuallyHappened.dispose();
    _whatILearned.dispose();
    _doDifferently.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_whatHappened.text.trim().isEmpty) {
      showAppSnackBar(
        context,
        'Start with what happened — the rest is optional.',
        type: ToastType.info,
      );
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    await ref
        .read(exposureReflectionProvider.notifier)
        .add(
          ExposureReflection(
            datetime: now,
            whatHappened: _whatHappened.text.trim(),
            ocdPredicted: _ocdPredicted.text.trim(),
            actuallyHappened: _actuallyHappened.text.trim(),
            whatILearned: _whatILearned.text.trim(),
            doDifferently: _doDifferently.text.trim(),
            createdAt: now,
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(
      context,
      'Reflection saved.',
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
                CircleBackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'New reflection',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LabeledField(
              label: 'What happened?',
              hint: 'The exposure you did',
              controller: _whatHappened,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'What did OCD predict?',
              hint: 'The feared outcome',
              controller: _ocdPredicted,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'What actually happened?',
              hint: 'The real result',
              controller: _actuallyHappened,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'What did you learn?',
              hint: 'Any insight from the gap',
              controller: _whatILearned,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'What would you do differently?',
              hint: 'Next time',
              controller: _doDifferently,
              minLines: 2,
            ),
            const SizedBox(height: 22),
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
                    : const Text('Save reflection'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
