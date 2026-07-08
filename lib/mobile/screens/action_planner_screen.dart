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

class ActionPlannerScreen extends ConsumerWidget {
  const ActionPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plans = ref.watch(actionPlanProvider);

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
                    'Action Planner',
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
              'Decide your response before a trigger arrives.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            const SectionIntro(id: 'actionPlanner'),
            plans.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(onCreate: () => _openCreate(context));
                }
                return Column(
                  children: [
                    for (final plan in items) ...[
                      _PlanCard(
                        plan: plan,
                        onToggle: (v) => ref
                            .read(actionPlanProvider.notifier)
                            .setCompleted(plan, v),
                        onDelete: () => _confirmDelete(context, ref, plan),
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
                'Your plans are unavailable right now.',
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
        builder: (_) => const ActionPlanEditScreen(),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ActionPlan plan) {
    final id = plan.id;
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
                'Delete this plan?',
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
                        await ref.read(actionPlanProvider.notifier).delete(id);
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

class _PlanCard extends StatelessWidget {
  final ActionPlan plan;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _PlanCard({
    required this.plan,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = plan.completed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: recoverySoftDecoration(theme),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onToggle(!done),
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done
                    ? theme.colorScheme.primary
                    : AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.situation,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? AppTheme.textSecondary : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.plannedAction,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (plan.date != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _prettyDate(plan.date!),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
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
    );
  }

  String _prettyDate(String iso) {
    try {
      return DateFormat('EEE, MMM d').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
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
            Icons.checklist_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            'Plan ahead',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a likely trigger and decide now how you will respond, so the '
            'moment is easier.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreate,
              child: const Text('New plan'),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionPlanEditScreen extends ConsumerStatefulWidget {
  const ActionPlanEditScreen({super.key});

  @override
  ConsumerState<ActionPlanEditScreen> createState() =>
      _ActionPlanEditScreenState();
}

class _ActionPlanEditScreenState extends ConsumerState<ActionPlanEditScreen> {
  final _situation = TextEditingController();
  final _action = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _date;
  bool _saving = false;

  @override
  void dispose() {
    _situation.dispose();
    _action.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final situation = _situation.text.trim();
    final action = _action.text.trim();
    if (situation.isEmpty || action.isEmpty) {
      showAppSnackBar(
        context,
        'Add a trigger and your planned response to save.',
        type: ToastType.info,
      );
      return;
    }
    setState(() => _saving = true);
    await ref
        .read(actionPlanProvider.notifier)
        .add(
          ActionPlan(
            situation: situation,
            plannedAction: action,
            date: _date == null
                ? null
                : DateFormat('yyyy-MM-dd').format(_date!),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            createdAt: DateTime.now(),
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(context, 'Plan saved.', type: ToastType.success);
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
                    'New plan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LabeledField(
              label: 'Trigger / situation',
              hint: 'e.g. The urge to Google a symptom',
              controller: _situation,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Planned response',
              hint: 'e.g. Wait 15 minutes before searching',
              controller: _action,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Date (optional)',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: recoverySoftDecoration(theme, radius: 18),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _date == null
                          ? 'Pick a date'
                          : DateFormat('EEE, MMM d, y').format(_date!),
                      style: TextStyle(
                        color: _date == null
                            ? AppTheme.textSecondary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (_date != null)
                      GestureDetector(
                        onTap: () => setState(() => _date = null),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Notes (optional)',
              hint: 'Anything that helps',
              controller: _notes,
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
                    : const Text('Save plan'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
