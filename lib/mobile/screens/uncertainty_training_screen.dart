import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../widgets/recovery_ui.dart';
import '../widgets/section_intro.dart';

class UncertaintyExercise {
  final String id;
  final String title;
  final String intro;
  final String why;
  final String prompt;
  const UncertaintyExercise({
    required this.id,
    required this.title,
    required this.intro,
    required this.why,
    required this.prompt,
  });
}

const uncertaintyExercises = <UncertaintyExercise>[
  UncertaintyExercise(
    id: 'maybe',
    title: 'Maybe, maybe not',
    intro:
        'When OCD demands certainty, answer it with "maybe, maybe not" and '
        'carry on.',
    why:
        'Agreeing to uncertainty starves the compulsion of the reassurance it '
        'feeds on.',
    prompt: 'Pick a worry and respond to it: "Maybe, maybe not." Sit with it.',
  ),
  UncertaintyExercise(
    id: 'unanswered',
    title: 'Leave it unanswered',
    intro: 'Let a nagging question stay open instead of resolving it.',
    why:
        'Your brain learns that an unanswered question is uncomfortable but '
        'safe — and the discomfort fades.',
    prompt: 'Choose one question you would normally settle, and leave it be.',
  ),
  UncertaintyExercise(
    id: 'resist',
    title: 'Resist certainty-seeking',
    intro: 'Notice the pull to check, google, or ask — and don\'t.',
    why:
        'Each time you resist, the urge to seek certainty gets a little '
        'quieter.',
    prompt: 'Catch one certainty-seeking urge and let it pass unanswered.',
  ),
];

class UncertaintyTrainingScreen extends ConsumerWidget {
  const UncertaintyTrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logs = ref.watch(uncertaintyLogProvider).asData?.value ?? const [];

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
                    'Uncertainty Training',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Build your willingness to live with not knowing.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            const SectionIntro(id: 'uncertaintyTraining'),
            for (final exercise in uncertaintyExercises) ...[
              _ExerciseCard(
                exercise: exercise,
                practiceCount: logs
                    .where((l) => l.exerciseId == exercise.id)
                    .length,
                onTap: () => _openPractice(context, exercise),
              ),
              const SizedBox(height: 10),
            ],
          ]),
        ),
      ),
    );
  }

  void _openPractice(BuildContext context, UncertaintyExercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => UncertaintyPracticeScreen(exercise: exercise),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final UncertaintyExercise exercise;
  final int practiceCount;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.practiceCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: recoverySoftDecoration(theme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (practiceCount > 0)
                  Text(
                    '$practiceCount×',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              exercise.intro,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UncertaintyPracticeScreen extends ConsumerStatefulWidget {
  final UncertaintyExercise exercise;
  const UncertaintyPracticeScreen({super.key, required this.exercise});

  @override
  ConsumerState<UncertaintyPracticeScreen> createState() =>
      _UncertaintyPracticeScreenState();
}

class _UncertaintyPracticeScreenState
    extends ConsumerState<UncertaintyPracticeScreen> {
  final _note = TextEditingController();
  double _willingness = 5;
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _log() async {
    setState(() => _saving = true);
    final now = DateTime.now();
    await ref
        .read(uncertaintyLogProvider.notifier)
        .add(
          UncertaintyLog(
            datetime: now,
            exerciseId: widget.exercise.id,
            willingness: _willingness.round(),
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            createdAt: now,
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(
      context,
      'Logged. Willingness grows with practice.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = widget.exercise;
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
                    exercise.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: recoverySoftDecoration(theme, radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.intro,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'WHY IT WORKS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.why,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                exercise.prompt,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: recoverySoftDecoration(theme, radius: 18),
              child: RatingSlider(
                label: 'How willing were you to sit with not knowing?',
                value: _willingness,
                onChanged: (v) => setState(() => _willingness = v),
              ),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Note (optional)',
              hint: 'What did you notice?',
              controller: _note,
              minLines: 2,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _log,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Log this practice'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
