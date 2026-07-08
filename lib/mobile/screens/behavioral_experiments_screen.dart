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

class BehavioralExperimentsScreen extends ConsumerWidget {
  const BehavioralExperimentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final experiments = ref.watch(behavioralExperimentProvider);

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
                    'Behavioral Experiments',
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
              'Test what OCD predicts against what actually happens.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            const SectionIntro(id: 'behavioralExperiments'),
            experiments.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(onCreate: () => _openCreate(context));
                }
                return Column(
                  children: [
                    for (final exp in items) ...[
                      _ExperimentCard(
                        experiment: exp,
                        onRecord: () => _openOutcome(context, exp),
                        onDelete: () => _confirmDelete(context, ref, exp),
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
                'Your experiments are unavailable right now.',
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
        builder: (_) => const BehavioralExperimentEditScreen(),
      ),
    );
  }

  void _openOutcome(BuildContext context, BehavioralExperiment exp) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => BehavioralExperimentEditScreen(existing: exp),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BehavioralExperiment exp,
  ) {
    final id = exp.id;
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
                'Delete this experiment?',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
                            .read(behavioralExperimentProvider.notifier)
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

class _ExperimentCard extends StatelessWidget {
  final BehavioralExperiment experiment;
  final VoidCallback onRecord;
  final VoidCallback onDelete;

  const _ExperimentCard({
    required this.experiment,
    required this.onRecord,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = experiment.status == ExperimentStatus.completed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: recoverySoftDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${experiment.confidence}% sure',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d').format(experiment.datetime),
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
          const SizedBox(height: 10),
          Text(
            experiment.fearPrediction,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            experiment.experiment,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (completed) ...[
            const SizedBox(height: 12),
            _LabeledBlock(label: 'What happened', value: experiment.outcome),
            if (experiment.learning.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _LabeledBlock(label: 'Learned', value: experiment.learning),
            ],
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRecord,
                child: const Text('Record what happened'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabeledBlock extends StatelessWidget {
  final String label;
  final String value;
  const _LabeledBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
      ],
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
            Icons.science_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            'Put a fear to the test',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Write down what OCD predicts, run a small experiment, and record '
            'what really happens.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreate,
              child: const Text('New experiment'),
            ),
          ),
        ],
      ),
    );
  }
}

class BehavioralExperimentEditScreen extends ConsumerStatefulWidget {
  final BehavioralExperiment? existing;
  const BehavioralExperimentEditScreen({super.key, this.existing});

  @override
  ConsumerState<BehavioralExperimentEditScreen> createState() =>
      _BehavioralExperimentEditScreenState();
}

class _BehavioralExperimentEditScreenState
    extends ConsumerState<BehavioralExperimentEditScreen> {
  late final TextEditingController _predictionController;
  late final TextEditingController _experimentController;
  final _outcomeController = TextEditingController();
  final _learningController = TextEditingController();
  double _confidence = 70;
  bool _saving = false;

  bool get _outcomeMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _predictionController = TextEditingController(
      text: existing?.fearPrediction ?? '',
    );
    _experimentController = TextEditingController(
      text: existing?.experiment ?? '',
    );
    _confidence = (existing?.confidence ?? 70).toDouble();
  }

  @override
  void dispose() {
    _predictionController.dispose();
    _experimentController.dispose();
    _outcomeController.dispose();
    _learningController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_outcomeMode) {
      final outcome = _outcomeController.text.trim();
      if (outcome.isEmpty) {
        showAppSnackBar(
          context,
          'Note what actually happened to finish up.',
          type: ToastType.info,
        );
        return;
      }
      setState(() => _saving = true);
      final existing = widget.existing!;
      await ref
          .read(behavioralExperimentProvider.notifier)
          .edit(
            BehavioralExperiment(
              id: existing.id,
              datetime: existing.datetime,
              fearPrediction: existing.fearPrediction,
              confidence: existing.confidence,
              experiment: existing.experiment,
              outcome: outcome,
              learning: _learningController.text.trim(),
              status: ExperimentStatus.completed,
              createdAt: existing.createdAt,
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnackBar(
        context,
        'Recorded. Evidence beats prediction.',
        type: ToastType.success,
      );
      return;
    }

    final prediction = _predictionController.text.trim();
    final experiment = _experimentController.text.trim();
    if (prediction.isEmpty || experiment.isEmpty) {
      showAppSnackBar(
        context,
        'Add a prediction and an experiment to save.',
        type: ToastType.info,
      );
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    await ref
        .read(behavioralExperimentProvider.notifier)
        .add(
          BehavioralExperiment(
            datetime: now,
            fearPrediction: prediction,
            confidence: _confidence.round(),
            experiment: experiment,
            createdAt: now,
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(
      context,
      'Experiment saved. Try it out, then record what happens.',
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
                    _outcomeMode ? 'Record outcome' : 'New experiment',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_outcomeMode) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: recoverySoftDecoration(theme, radius: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledBlock(
                      label: 'Prediction',
                      value: widget.existing!.fearPrediction,
                    ),
                    const SizedBox(height: 10),
                    _LabeledBlock(
                      label: 'Experiment',
                      value: widget.existing!.experiment,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'What actually happened?',
                hint: 'The real outcome',
                controller: _outcomeController,
                minLines: 2,
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'What did you learn? (optional)',
                hint: 'How did reality compare to the fear?',
                controller: _learningController,
                minLines: 2,
              ),
            ] else ...[
              LabeledField(
                label: 'What does OCD predict?',
                hint: 'e.g. If I don\'t check, the house will flood',
                controller: _predictionController,
                minLines: 2,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: recoverySoftDecoration(theme, radius: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'How sure are you it will come true?',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${_confidence.round()}%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _confidence,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: (v) => setState(() => _confidence = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Your experiment',
                hint: 'e.g. Leave without checking and see what happens',
                controller: _experimentController,
                minLines: 2,
              ),
            ],
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
                    : Text(_outcomeMode ? 'Save outcome' : 'Save experiment'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
