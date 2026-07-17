import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/desktop_chrome.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/recovery_ui.dart';
import '../../widgets/section_intro.dart';

class ImplementationIntentionsScreen extends ConsumerWidget {
  const ImplementationIntentionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final intentions = ref.watch(implementationIntentionProvider);

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
                    'Implementation Intentions',
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
              'Pre-decide your response so it becomes automatic: '
              '"If X, then I will Y."',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            const SectionIntro(id: 'implementationIntentions'),
            intentions.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(onCreate: () => _openCreate(context));
                }
                return Column(
                  children: [
                    for (final intention in items) ...[
                      _IntentionCard(
                        intention: intention,
                        onDelete: () => _confirmDelete(context, ref, intention),
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
                'Your intentions are unavailable right now.',
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
        
        builder: (_) => const ImplementationIntentionEditScreen(),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ImplementationIntention intention,
  ) {
    final id = intention.id;
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
                'Delete this intention?',
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
                            .read(implementationIntentionProvider.notifier)
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

class _IntentionCard extends StatelessWidget {
  final ImplementationIntention intention;
  final VoidCallback onDelete;

  const _IntentionCard({required this.intention, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: recoverySoftDecoration(theme),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontFamily: AppTheme.displayFamily,
                ),
                children: [
                  TextSpan(
                    text: 'If ',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  TextSpan(text: intention.trigger),
                  TextSpan(
                    text: ', then ',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  TextSpan(text: intention.response),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
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
            Icons.lightbulb_outline_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            'Make your response automatic',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Linking a trigger to a planned response makes it far easier to '
            'follow through in the moment.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreate,
              child: const Text('New intention'),
            ),
          ),
        ],
      ),
    );
  }
}

class ImplementationIntentionEditScreen extends ConsumerStatefulWidget {
  const ImplementationIntentionEditScreen({super.key});

  @override
  ConsumerState<ImplementationIntentionEditScreen> createState() =>
      _ImplementationIntentionEditScreenState();
}

class _ImplementationIntentionEditScreenState
    extends ConsumerState<ImplementationIntentionEditScreen> {
  final _trigger = TextEditingController();
  final _response = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _trigger.dispose();
    _response.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final trigger = _trigger.text.trim();
    final response = _response.text.trim();
    if (trigger.isEmpty || response.isEmpty) {
      showAppSnackBar(
        context,
        'Fill in both the "if" and the "then" to save.',
        type: ToastType.info,
      );
      return;
    }
    setState(() => _saving = true);
    await ref
        .read(implementationIntentionProvider.notifier)
        .add(
          ImplementationIntention(
            trigger: trigger,
            response: response,
            createdAt: DateTime.now(),
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(context, 'Intention saved.', type: ToastType.success);
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
                    'New intention',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LabeledField(
              label: 'If…',
              hint: 'the trigger, e.g. I feel the urge to seek reassurance',
              controller: _trigger,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'then I will…',
              hint: 'your response, e.g. write my thoughts down instead',
              controller: _response,
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
                    : const Text('Save intention'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
