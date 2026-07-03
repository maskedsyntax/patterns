import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/review_prompt.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../main_shell.dart' show mobileRootNavigatorKey;
import '../widgets/section_intro.dart';

class OcdTrackerScreen extends ConsumerStatefulWidget {
  final VoidCallback onAdd;
  final VoidCallback onDelay;

  const OcdTrackerScreen({
    super.key,
    required this.onAdd,
    required this.onDelay,
  });

  @override
  ConsumerState<OcdTrackerScreen> createState() => _OcdTrackerScreenState();
}

class _OcdTrackerScreenState extends ConsumerState<OcdTrackerScreen> {
  OcdType? _selectedType;
  OcdType? _previousType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(filteredOcdProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Row(
                  children: [
                    Expanded(child: Text('Track', style: _screenTitle(theme))),
                    _PauseUrgePill(onTap: widget.onDelay),
                  ],
                ),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FilterBar(
                  selectedType: _selectedType,
                  onChanged: (type) {
                    if (type == _selectedType) return;
                    setState(() {
                      _previousType = _selectedType;
                      _selectedType = type;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionIntro(id: 'track'),
            ),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  final filtered = _selectedType == null
                      ? entries
                      : entries
                            .where((entry) => entry.type == _selectedType)
                            .toList();
                  final previousIndex = _typeOrder(_previousType);
                  final currentIndex = _typeOrder(_selectedType);
                  final goingForward = currentIndex >= previousIndex;
                  final body = filtered.isEmpty
                      ? KeyedSubtree(
                          key: ValueKey(
                            'empty-${_selectedType?.name ?? 'all'}',
                          ),
                          child: _EmptyTrackState(onAdd: widget.onAdd),
                        )
                      : ListView.builder(
                          key: ValueKey(_selectedType?.name ?? 'all'),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 116),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return FadeSlideIn(
                              delay: Duration(
                                milliseconds: 18 * index.clamp(0, 3),
                              ),
                              duration: AppMotion.medium,
                              offset: AppMotion.smallOffset,
                              child: _OcdEventCard(entry: filtered[index]),
                            );
                          },
                        );
                  return PageTransitionSwitcher(
                    duration: AppMotion.medium,
                    reverse: !goingForward,
                    transitionBuilder: (child, primary, secondary) {
                      if (motionDisabled(context)) return child;
                      return SharedAxisTransition(
                        animation: primary,
                        secondaryAnimation: secondary,
                        transitionType: SharedAxisTransitionType.horizontal,
                        fillColor: Colors.transparent,
                        child: child,
                      );
                    },
                    child: body,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OcdEventFlow extends ConsumerStatefulWidget {
  final OcdType initialType;
  final OcdEntry? entry;

  const OcdEventFlow({super.key, required this.initialType, this.entry});

  @override
  ConsumerState<OcdEventFlow> createState() => _OcdEventFlowState();
}

class _OcdEventFlowState extends ConsumerState<OcdEventFlow> {
  late OcdType _type = widget.initialType;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  double _distress = 5;
  bool _saving = false;
  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry == null) return;
    _type = entry.type;
    _contentController.text = entry.content;
    _actionController.text = entry.actionTaken ?? '';
    _responseController.text = entry.response;
    _distress = entry.distressLevel.toDouble();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _actionController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LineIcons.angleLeft),
                  ),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit event' : 'Track event',
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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: staggered([
                  _TypeToggle(
                    selected: _type,
                    onChanged: (type) => setState(() => _type = type),
                  ),
                  const SizedBox(height: 22),
                  _FlowField(
                    controller: _contentController,
                    label: 'What happened?',
                    hint: _type == OcdType.obsession
                        ? 'Name the thought or image.'
                        : 'Name the urge or compulsion.',
                    minLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _FlowField(
                    controller: _actionController,
                    label: 'What did you do?',
                    hint: 'A short note is enough.',
                    minLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _FlowField(
                    controller: _responseController,
                    label: 'Strategy / Response',
                    hint: 'What helped you respond differently?',
                    minLines: 3,
                  ),
                  const SizedBox(height: 22),
                  _DistressCard(
                    value: _distress,
                    onChanged: (value) => setState(() => _distress = value),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          _saving
                              ? 'Saving...'
                              : _isEditing
                              ? 'Update event'
                              : 'Save event',
                          key: ValueKey(_saving),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_contentController.text.trim().isEmpty) {
      showAppSnackBar(
        context,
        'Whenever you’re ready, add a few words about what happened.',
        type: ToastType.info,
      );
      return;
    }
    setState(() => _saving = true);
    final existing = widget.entry;
    final now = DateTime.now();
    final entry = OcdEntry(
      id: existing?.id,
      type: _type,
      datetime: existing?.datetime ?? now,
      content: _contentController.text.trim(),
      distressLevel: _distress.round(),
      response: _responseController.text.trim(),
      actionTaken: _actionController.text.trim().isEmpty
          ? null
          : _actionController.text.trim(),
      createdAt: existing?.createdAt ?? now,
    );
    if (_isEditing) {
      await ref.read(ocdProvider.notifier).updateEntry(entry);
    } else {
      await ref.read(ocdProvider.notifier).addEntry(entry);
    }
    await ReviewPromptService.recordOcdSaved(entry.distressLevel);
    final eligibleHappyMoment =
        !_isEditing &&
        entry.distressLevel <= ReviewPromptService.maxOcdDistressForTrigger;
    if (mounted) {
      showAppSnackBar(
        context,
        _isEditing ? 'Event updated' : 'Event saved',
        type: ToastType.success,
      );
      Navigator.pop(context);
    }
    if (!eligibleHappyMoment) return;
    // Defer until after the pop settles, then prompt against the root
    // navigator's context so the dialog lands on the tracker screen rather
    // than racing the disposing flow.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rootContext = mobileRootNavigatorKey.currentContext;
      if (rootContext == null) return;
      ReviewPromptService.maybeRequestReview(
        rootContext,
        trigger: ReviewTrigger.ocdLowDistress,
      );
    });
  }
}

class _FilterBar extends StatelessWidget {
  final OcdType? selectedType;
  final ValueChanged<OcdType?> onChanged;

  const _FilterBar({required this.selectedType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: _softDecoration(Theme.of(context), radius: 22),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: selectedType == null,
            onTap: () => onChanged(null),
          ),
          _FilterChip(
            label: 'Obsessions',
            selected: selectedType == OcdType.obsession,
            onTap: () => onChanged(OcdType.obsession),
          ),
          _FilterChip(
            label: 'Compulsions',
            selected: selectedType == OcdType.compulsion,
            onTap: () => onChanged(OcdType.compulsion),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : AppTheme.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _OcdEventCard extends ConsumerWidget {
  final OcdEntry entry;

  const _OcdEventCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: _softDecoration(theme, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeChip(type: entry.type),
              const Spacer(),
              Text(
                DateFormat('MMM d, h:mm a').format(entry.datetime),
                style: _muted(12),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Edit event',
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                color: AppTheme.textSecondary,
                onPressed: entry.id == null
                    ? null
                    : () => _openEditor(context, entry),
                icon: const Icon(LineIcons.edit),
              ),
              IconButton(
                tooltip: 'Delete event',
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                color: AppTheme.textSecondary,
                onPressed: entry.id == null
                    ? null
                    : () => _confirmDelete(context, ref, entry),
                icon: const Icon(LineIcons.trash),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            entry.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.sansFamily,
              color: theme.colorScheme.onSurface,
              fontSize: 16,
              height: 1.38,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Distress ${entry.distressLevel}/10',
                style: TextStyle(
                  color: _distressColor(entry.distressLevel),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.response.isEmpty ? 'No strategy noted' : entry.response,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _muted(13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, OcdEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => OcdEventFlow(initialType: entry.type, entry: entry),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, OcdEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete event?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'This removes the event from your local history.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref
                          .read(ocdProvider.notifier)
                          .deleteEntry(entry.id!);
                      if (context.mounted) {
                        showAppSnackBar(
                          context,
                          'Event deleted',
                          type: ToastType.success,
                        );
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final OcdType selected;
  final ValueChanged<OcdType> onChanged;

  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: _softDecoration(Theme.of(context), radius: 24),
      child: Row(
        children: [
          _FilterChip(
            label: 'Obsession',
            selected: selected == OcdType.obsession,
            onTap: () => onChanged(OcdType.obsession),
          ),
          _FilterChip(
            label: 'Compulsion',
            selected: selected == OcdType.compulsion,
            onTap: () => onChanged(OcdType.compulsion),
          ),
        ],
      ),
    );
  }
}

class _FlowField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;

  const _FlowField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: minLines + 2,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _DistressCard extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _DistressCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _softDecoration(theme, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Distress',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: value, end: value),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) {
                  final rounded = v.round();
                  return AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: _distressColor(rounded),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                    child: Text('$rounded/10'),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PauseUrgePill extends StatelessWidget {
  final VoidCallback onTap;

  const _PauseUrgePill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LineIcons.hourglassHalf,
              color: theme.colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 7),
            Text(
              'Pause an urge',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final OcdType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final isObsession = type == OcdType.obsession;
    final color = isObsession
        ? AppTheme.obsessionChip
        : AppTheme.compulsionChip;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isObsession ? 'Obsession' : 'Compulsion',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyTrackState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyTrackState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LineIcons.bullseye,
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'No events yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log only what feels useful. A short note is enough.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: onAdd,
            child: const Text('Track OCD Event'),
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final Widget child;

  const _BottomPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.dividerColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

TextStyle _screenTitle(ThemeData theme) {
  return TextStyle(
    fontFamily: AppTheme.sansFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
    color: theme.colorScheme.onSurface,
  );
}

TextStyle _muted(double size) {
  return TextStyle(color: AppTheme.textSecondary, fontSize: size);
}

BoxDecoration _softDecoration(ThemeData theme, {required double radius}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
  );
}

Color _distressColor(int level) {
  if (level <= 3) return AppTheme.softGreen;
  if (level <= 7) return AppTheme.warmYellow;
  return AppTheme.mutedRed;
}

int _typeOrder(OcdType? type) {
  if (type == null) return 0;
  if (type == OcdType.obsession) return 1;
  return 2;
}
