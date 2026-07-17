import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/recovery_ui.dart';
import '../../content/ybocs_content.dart';

/// The Y-BOCS self-check: a staged flow that stays simple no matter how many
/// items it holds. Intro → symptom checklist → one-question-at-a-time severity
/// → results. Results are saved so someone can retake and watch trends shift.
///
/// This is a self-check aid, not a diagnosis — the UI says so at the start and
/// again at the end.
class YbocsScreen extends ConsumerStatefulWidget {
  const YbocsScreen({super.key});

  @override
  ConsumerState<YbocsScreen> createState() => _YbocsScreenState();
}

enum _Stage { intro, checklist, severity, results }

class _YbocsScreenState extends ConsumerState<YbocsScreen> {
  _Stage _stage = _Stage.intro;
  final Set<String> _selectedSymptoms = {};
  final List<int?> _answers = List<int?>.filled(
    ybocsSeverityQuestions.length,
    null,
  );
  int _questionIndex = 0;
  bool _saved = false;

  int get _obsessionScore {
    var sum = 0;
    for (var i = 0; i < ybocsSeverityQuestions.length; i++) {
      if (ybocsSeverityQuestions[i].dimension == YbocsDimension.obsessions) {
        sum += _answers[i] ?? 0;
      }
    }
    return sum;
  }

  int get _compulsionScore {
    var sum = 0;
    for (var i = 0; i < ybocsSeverityQuestions.length; i++) {
      if (ybocsSeverityQuestions[i].dimension == YbocsDimension.compulsions) {
        sum += _answers[i] ?? 0;
      }
    }
    return sum;
  }

  int get _total => _obsessionScore + _compulsionScore;

  List<YbocsSymptomCategory> get _selectedCategories => ybocsCategories
      .where((c) => c.items.any((i) => _selectedSymptoms.contains(i.id)))
      .toList();

  void _goTo(_Stage stage) => setState(() => _stage = stage);

  void _restart() {
    setState(() {
      _stage = _Stage.checklist;
      _selectedSymptoms.clear();
      for (var i = 0; i < _answers.length; i++) {
        _answers[i] = null;
      }
      _questionIndex = 0;
      _saved = false;
    });
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final assessment = YbocsAssessment(
      datetime: now,
      obsessionScore: _obsessionScore,
      compulsionScore: _compulsionScore,
      totalScore: _total,
      severity: ybocsSeverityForScore(_total),
      itemScores: _answers.map((a) => a ?? 0).toList(),
      themes: _selectedCategories.map((c) => c.id).toList(),
      symptoms: _selectedSymptoms.toList(),
      createdAt: now,
    );
    await ref.read(ybocsAssessmentProvider.notifier).add(assessment);
    if (!mounted) return;
    setState(() => _saved = true);
    showAppSnackBar(
      context,
      'Saved to your history.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_stage) {
          _Stage.intro => _IntroView(
            onBegin: () => _goTo(_Stage.checklist),
            onClose: () => Navigator.of(context).pop(),
          ),
          _Stage.checklist => _ChecklistView(
            selected: _selectedSymptoms,
            onToggle: (id) => setState(() {
              if (!_selectedSymptoms.add(id)) _selectedSymptoms.remove(id);
            }),
            onBack: () => _goTo(_Stage.intro),
            onContinue: () => _goTo(_Stage.severity),
          ),
          _Stage.severity => _SeverityView(
            index: _questionIndex,
            answers: _answers,
            onSelect: (score) => setState(() => _answers[_questionIndex] = score),
            onBack: () {
              if (_questionIndex == 0) {
                _goTo(_Stage.checklist);
              } else {
                setState(() => _questionIndex--);
              }
            },
            onNext: () {
              if (_questionIndex == ybocsSeverityQuestions.length - 1) {
                _goTo(_Stage.results);
              } else {
                setState(() => _questionIndex++);
              }
            },
          ),
          _Stage.results => _ResultsView(
            obsessionScore: _obsessionScore,
            compulsionScore: _compulsionScore,
            total: _total,
            categories: _selectedCategories,
            saved: _saved,
            onSave: _save,
            onRetake: _restart,
            onClose: () => Navigator.of(context).pop(),
          ),
        },
      ),
    );
  }
}

// ── Intro ──────────────────────────────────────────────────────────────────

class _IntroView extends ConsumerWidget {
  final VoidCallback onBegin;
  final VoidCallback onClose;

  const _IntroView({required this.onBegin, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final history = ref.watch(ybocsAssessmentProvider).asData?.value ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      children: staggered([
        Row(
          children: [
            CircleBackButton(onTap: onClose),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'OCD Self-Check',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'A guided walk through the Yale-Brown Obsessive Compulsive Scale '
          '(Y-BOCS): the patterns you notice, and how much they affect you.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 18),
        const _DisclaimerCard(),
        const SizedBox(height: 16),
        _CockpitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _IntroPoint(
                icon: Icons.checklist_rounded,
                title: 'Spot the patterns',
                body: 'Tick the obsessions and compulsions that feel familiar.',
              ),
              SizedBox(height: 14),
              _IntroPoint(
                icon: Icons.speed_rounded,
                title: 'Measure the impact',
                body: '10 short questions rate how much they take from your day.',
              ),
              SizedBox(height: 14),
              _IntroPoint(
                icon: Icons.insights_rounded,
                title: 'See where you stand',
                body: 'Get your themes and a severity band you can retake anytime.',
              ),
            ],
          ),
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 16),
          _HistorySection(history: history),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onBegin,
            child: Text(history.isEmpty ? 'Begin' : 'Take it again'),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Takes about 10 minutes. Everything stays private on your device.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
        ),
      ]),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warmYellow.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.warmYellow.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.warmYellow),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is a self-check to help you understand your experience — '
              'not a diagnosis. Only a qualified professional can diagnose OCD. '
              'Bring your results to them if anything here resonates.',
              style: TextStyle(
                color: AppTheme.textPrimary,
                height: 1.45,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _IntroPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.warmYellow.withValues(alpha: 0.14),
          ),
          child: Icon(icon, color: AppTheme.warmYellow, size: 21),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistorySection extends ConsumerWidget {
  final List<YbocsAssessment> history;

  const _HistorySection({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CockpitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your history',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Retaking every few weeks shows whether things are shifting.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          for (final a in history.take(5)) ...[
            _HistoryRow(
              assessment: a,
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Assessment?'),
                    content: const Text('This will permanently delete this Y-BOCS assessment history entry.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  ref.read(ybocsAssessmentProvider.notifier).delete(a.id!);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final YbocsAssessment assessment;
  final VoidCallback onDelete;

  const _HistoryRow({required this.assessment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF181817),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D2B27)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: assessment.severity.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${assessment.severity.label} · ${assessment.totalScore}/40',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, y').format(assessment.datetime),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              LineIcons.trash,
              size: 18,
              color: AppTheme.textSecondary,
            ),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}

// ── Checklist ────────────────────────────────────────────────────────────────

class _ChecklistView extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const _ChecklistView({
    required this.selected,
    required this.onToggle,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final obsessions =
        ybocsCategories.where((c) => c.kind == YbocsDimension.obsessions);
    final compulsions =
        ybocsCategories.where((c) => c.kind == YbocsDimension.compulsions);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(
            children: [
              CircleBackButton(onTap: onBack),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'What feels familiar?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: staggered([
              Text(
                'Tick anything you\'ve experienced, now or in the past. Skip '
                'what doesn\'t fit — there are no wrong answers.',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 18),
              _GroupLabel(
                label: 'Obsessions',
                sub: 'Unwanted thoughts, images, or urges',
              ),
              const SizedBox(height: 10),
              for (final c in obsessions) ...[
                _CategoryBlock(
                  category: c,
                  selected: selected,
                  onToggle: onToggle,
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
              _GroupLabel(
                label: 'Compulsions',
                sub: 'Behaviours or mental acts to feel less anxious',
              ),
              const SizedBox(height: 10),
              for (final c in compulsions) ...[
                _CategoryBlock(
                  category: c,
                  selected: selected,
                  onToggle: onToggle,
                ),
                const SizedBox(height: 10),
              ],
            ]),
          ),
        ),
        _BottomBar(
          child: ElevatedButton(
            onPressed: onContinue,
            child: Text(
              selected.isEmpty
                  ? 'Continue'
                  : 'Continue · ${selected.length} selected',
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  final String sub;

  const _GroupLabel({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
        ),
      ],
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  final YbocsSymptomCategory category;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _CategoryBlock({
    required this.category,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = category.items.where((i) => selected.contains(i.id)).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: recoverySoftDecoration(theme, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (final item in category.items)
            _CheckRow(
              label: item.label,
              checked: selected.contains(item.id),
              onTap: () => onToggle(item.id),
            ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;

  const _CheckRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: checked
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: checked
                      ? theme.colorScheme.primary
                      : const Color(0xFF4A473F),
                  width: 1.5,
                ),
              ),
              child: checked
                  ? Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  color: checked
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Severity ─────────────────────────────────────────────────────────────────

class _SeverityView extends StatelessWidget {
  final int index;
  final List<int?> answers;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _SeverityView({
    required this.index,
    required this.answers,
    required this.onSelect,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = ybocsSeverityQuestions.length;
    final question = ybocsSeverityQuestions[index];
    final answer = answers[index];
    final isLast = index == total - 1;
    final dimensionLabel = question.dimension == YbocsDimension.obsessions
        ? 'Obsessions'
        : 'Compulsions';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(
            children: [
              CircleBackButton(onTap: onBack),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1} of $total',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      dimensionLabel,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (index + 1) / total,
              minHeight: 6,
              backgroundColor: const Color(0xFF2B2926),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.warmYellow,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            key: ValueKey(index),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: staggered([
              Text(
                question.prompt,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < question.options.length; i++) ...[
                _OptionRow(
                  label: question.options[i],
                  selected: answer == i,
                  onTap: () => onSelect(i),
                ),
                const SizedBox(height: 10),
              ],
            ]),
          ),
        ),
        _BottomBar(
          child: ElevatedButton(
            onPressed: answer == null ? null : onNext,
            child: Text(isLast ? 'See results' : 'Next'),
          ),
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : const Color(0xFF4A473F),
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results ──────────────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final int obsessionScore;
  final int compulsionScore;
  final int total;
  final List<YbocsSymptomCategory> categories;
  final bool saved;
  final Future<void> Function() onSave;
  final VoidCallback onRetake;
  final VoidCallback onClose;

  const _ResultsView({
    required this.obsessionScore,
    required this.compulsionScore,
    required this.total,
    required this.categories,
    required this.saved,
    required this.onSave,
    required this.onRetake,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = ybocsSeverityForScore(total);
    final hasObsessions =
        categories.any((c) => c.kind == YbocsDimension.obsessions) ||
        obsessionScore > 0;
    final hasCompulsions =
        categories.any((c) => c.kind == YbocsDimension.compulsions) ||
        compulsionScore > 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(
            children: [
              CircleBackButton(onTap: onClose),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your results',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: staggered([
              _SeverityCard(severity: severity, total: total),
              const SizedBox(height: 14),
              _BreakdownCard(
                obsessionScore: obsessionScore,
                compulsionScore: compulsionScore,
              ),
              const SizedBox(height: 14),
              _TypesCard(
                hasObsessions: hasObsessions,
                hasCompulsions: hasCompulsions,
              ),
              if (categories.isNotEmpty) ...[
                const SizedBox(height: 14),
                _ThemesCard(categories: categories),
              ],
              const SizedBox(height: 14),
              const _NextStepsCard(),
            ]),
          ),
        ),
        _BottomBar(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetake,
                  child: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: saved ? null : () => onSave(),
                  child: Text(saved ? 'Saved ✓' : 'Save to my history'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeverityCard extends StatelessWidget {
  final YbocsSeverity severity;
  final int total;

  const _SeverityCard({required this.severity, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            severity.color.withValues(alpha: 0.20),
            severity.color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: severity.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total',
                style: TextStyle(
                  fontFamily: AppTheme.displayFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 52,
                  height: 1,
                  color: severity.color,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  ' / 40',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: severity.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  severity.label,
                  style: TextStyle(
                    color: severity.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            severity.blurb,
            style: const TextStyle(color: AppTheme.textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final int obsessionScore;
  final int compulsionScore;

  const _BreakdownCard({
    required this.obsessionScore,
    required this.compulsionScore,
  });

  @override
  Widget build(BuildContext context) {
    return _CockpitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where it weighs most',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 14),
          _ScoreBar(label: 'Obsessions', score: obsessionScore),
          const SizedBox(height: 12),
          _ScoreBar(label: 'Compulsions', score: compulsionScore),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score; // out of 20

  const _ScoreBar({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
            Text(
              '$score/20',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: score / 20,
            minHeight: 8,
            backgroundColor: const Color(0xFF2B2926),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.warmYellow,
            ),
          ),
        ),
      ],
    );
  }
}

class _TypesCard extends StatelessWidget {
  final bool hasObsessions;
  final bool hasCompulsions;

  const _TypesCard({required this.hasObsessions, required this.hasCompulsions});

  @override
  Widget build(BuildContext context) {
    final types = <String>[
      if (hasObsessions) 'Obsessions',
      if (hasCompulsions) 'Compulsions',
    ];
    final text = switch (types.length) {
      0 => 'You didn\'t flag a clear pattern this time — that\'s okay.',
      2 => 'You noticed both obsessions and compulsions — the two often feed '
          'each other.',
      _ => 'You mainly noticed ${types.first.toLowerCase()}.',
    };
    return _CockpitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The types you noticed',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (types.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final t in types) _Chip(label: t)],
            ),
          if (types.isNotEmpty) const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ThemesCard extends StatelessWidget {
  final List<YbocsSymptomCategory> categories;

  const _ThemesCard({required this.categories});

  @override
  Widget build(BuildContext context) {
    return _CockpitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your themes',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'The areas your obsessions and compulsions cluster around.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in categories) _Chip(label: c.title),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warmYellow.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.warmYellow.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.favorite_border_rounded, color: AppTheme.warmYellow),
              SizedBox(width: 10),
              Text(
                'What now?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'This score is a snapshot, not a diagnosis. If these patterns are '
            'affecting your life, a therapist trained in ERP can help — and the '
            'Recovery tools here are a good place to start practising in the '
            'meantime.',
            style: TextStyle(
              color: AppTheme.textPrimary,
              height: 1.5,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared bits ──────────────────────────────────────────────────────────────

class _CockpitCard extends StatelessWidget {
  final Widget child;

  const _CockpitCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: recoverySoftDecoration(theme),
      child: child,
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Widget child;

  const _BottomBar({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}
