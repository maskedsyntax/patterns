import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../widgets/desktop_chrome.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/recovery_ui.dart';
import '../../widgets/section_intro.dart';

const _outcomeLabels = {
  ResponseOutcome.resisted: 'Resisted',
  ResponseOutcome.delayed: 'Delayed',
  ResponseOutcome.partial: 'Partly did it',
  ResponseOutcome.performed: 'Did it',
};

Color _outcomeColor(ResponseOutcome outcome) {
  switch (outcome) {
    case ResponseOutcome.resisted:
      return AppTheme.softGreen;
    case ResponseOutcome.delayed:
      return AppTheme.warmYellow;
    case ResponseOutcome.partial:
      return AppTheme.compulsionChip;
    case ResponseOutcome.performed:
      return AppTheme.mutedRed;
  }
}

class ResponsePreventionScreen extends ConsumerWidget {
  const ResponsePreventionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logs = ref.watch(responsePreventionProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: staggered([
            Row(
              children: [
                const SizedBox.shrink(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Response Prevention',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openLog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Log'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'After a trigger, note how you responded to the urge. Every '
              'resisted or delayed urge is progress.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            const SectionIntro(id: 'responsePrevention'),
            logs.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(onLog: () => _openLog(context));
                }
                return Column(
                  children: [
                    for (final log in items) ...[
                      _LogCard(
                        log: log,
                        onDelete: () => _confirmDelete(context, ref, log),
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
                'Your logs are unavailable right now.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _openLog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        
        builder: (_) => const ResponsePreventionLogScreen(),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ResponsePreventionLog log,
  ) {
    final id = log.id;
    if (id == null) return;
    showDesktopDialog<void>(
      context: context,
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
                'Delete this log?',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'This entry will be removed for good.',
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
                            .read(responsePreventionProvider.notifier)
                            .deleteLog(id);
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

class _LogCard extends StatelessWidget {
  final ResponsePreventionLog log;
  final VoidCallback onDelete;

  const _LogCard({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _outcomeColor(log.outcome);
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
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _outcomeLabels[log.outcome]!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d').format(log.datetime),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 4),
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
            log.situation,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 6),
          Text(
            'Anxiety ${log.anxietyLevel}/10',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          if (log.note != null && log.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              log.note!,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onLog;
  const _EmptyState({required this.onLog});

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
            Icons.shield_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            'Track how you respond',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Log what happened after a trigger and how you handled the urge. '
            'Over time you will see your resistance grow.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLog,
              child: const Text('Log a response'),
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsePreventionLogScreen extends ConsumerStatefulWidget {
  const ResponsePreventionLogScreen({super.key});

  @override
  ConsumerState<ResponsePreventionLogScreen> createState() =>
      _ResponsePreventionLogScreenState();
}

class _ResponsePreventionLogScreenState
    extends ConsumerState<ResponsePreventionLogScreen> {
  final _situationController = TextEditingController();
  final _noteController = TextEditingController();
  ResponseOutcome _outcome = ResponseOutcome.resisted;
  double _anxiety = 5;
  bool _saving = false;

  @override
  void dispose() {
    _situationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final situation = _situationController.text.trim();
    if (situation.isEmpty) {
      showAppSnackBar(
        context,
        'Add a quick note on the situation to save.',
        type: ToastType.info,
      );
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final log = ResponsePreventionLog(
      datetime: now,
      situation: situation,
      outcome: _outcome,
      anxietyLevel: _anxiety.round(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: now,
    );
    await ref.read(responsePreventionProvider.notifier).addLog(log);
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(
      context,
      'Logged. That awareness counts.',
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
                const SizedBox.shrink(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Log a response',
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
              hint: 'The trigger and the urge you faced',
              controller: _situationController,
              minLines: 2,
            ),
            const SizedBox(height: 20),
            Text(
              'How did you respond?',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _OutcomePicker(
              outcome: _outcome,
              onChanged: (o) => setState(() => _outcome = o),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: recoverySoftDecoration(theme, radius: 18),
              child: RatingSlider(
                label: 'Anxiety at the time',
                value: _anxiety,
                onChanged: (v) => setState(() => _anxiety = v),
              ),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Note (optional)',
              hint: 'Anything you want to remember',
              controller: _noteController,
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
                    : const Text('Save log'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _OutcomePicker extends StatelessWidget {
  final ResponseOutcome outcome;
  final ValueChanged<ResponseOutcome> onChanged;

  const _OutcomePicker({required this.outcome, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in _outcomeLabels.entries)
          GestureDetector(
            onTap: () => onChanged(entry.key),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: outcome == entry.key
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: outcome == entry.key
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                ),
              ),
              child: Text(
                entry.value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: outcome == entry.key
                      ? theme.colorScheme.onPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
