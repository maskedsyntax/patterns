import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';

enum _Phase { setup, countdown, reflection }

/// Compulsion Delay Tool — an active ERP practice. The user picks a compulsion,
/// chooses how long to sit with the urge, rides out a calm countdown, then
/// reflects on what happened. The whole flow stays gentle and non-punishing:
/// stopping early is always allowed and never scolded.
class CompulsionDelayFlow extends ConsumerStatefulWidget {
  final String? initialCompulsion;

  const CompulsionDelayFlow({super.key, this.initialCompulsion});

  @override
  ConsumerState<CompulsionDelayFlow> createState() =>
      _CompulsionDelayFlowState();
}

class _CompulsionDelayFlowState extends ConsumerState<CompulsionDelayFlow>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.setup;

  // Setup
  final TextEditingController _compulsionController = TextEditingController();
  double _urgeBefore = 5;
  int _plannedSeconds = 5 * 60;
  bool _custom = false;
  double _customMinutes = 10;

  // Countdown
  late final AnimationController _timer = AnimationController(vsync: this);

  // Reflection
  double _urgeAfter = 5;
  DelayOutcome? _outcome;
  final TextEditingController _noteController = TextEditingController();
  bool _completed = false;
  int _actualSeconds = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCompulsion != null) {
      _compulsionController.text = widget.initialCompulsion!;
    }
    _timer.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishTimer(completed: true);
      }
    });
  }

  @override
  void dispose() {
    _timer.dispose();
    _compulsionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ----- phase transitions -----

  void _begin() {
    if (_compulsionController.text.trim().isEmpty) {
      showAppSnackBar(
        context,
        'Whenever you’re ready, name the urge you want to sit with.',
        type: ToastType.info,
      );
      return;
    }
    _plannedSeconds = _custom ? (_customMinutes.round() * 60) : _plannedSeconds;
    _urgeAfter = _urgeBefore;
    _timer
      ..duration = Duration(seconds: _plannedSeconds)
      ..forward(from: 0);
    setState(() => _phase = _Phase.countdown);
  }

  void _finishTimer({required bool completed}) {
    if (_phase != _Phase.countdown) return;
    final remaining = (_timer.duration ?? Duration.zero) * (1 - _timer.value);
    _timer.stop();
    setState(() {
      _completed = completed;
      _actualSeconds = completed
          ? _plannedSeconds
          : (_plannedSeconds - remaining.inSeconds).clamp(0, _plannedSeconds);
      _phase = _Phase.reflection;
    });
  }

  void _confirmStop() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _BottomPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stop early?',
              style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'It’s okay to stop. Every moment you waited still counts as practice.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Keep going'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _finishTimer(completed: false);
                    },
                    child: const Text('I need to stop'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_outcome == null) {
      showAppSnackBar(
        context,
        'When you’re ready, choose what you ended up doing.',
        type: ToastType.info,
      );
      return;
    }
    setState(() => _saving = true);
    final session = DelaySession(
      compulsion: _compulsionController.text.trim(),
      plannedSeconds: _plannedSeconds,
      actualSeconds: _actualSeconds,
      completed: _completed,
      urgeBefore: _urgeBefore.round(),
      urgeAfter: _urgeAfter.round(),
      outcome: _outcome!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: DateTime.now(),
    );
    await ref.read(delaySessionProvider.notifier).addSession(session);
    if (!mounted) return;
    Navigator.pop(context);
    showAppSnackBar(
      context,
      'Practice logged. That took real courage.',
      type: ToastType.success,
    );
  }

  // ----- build -----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, primary, secondary) {
            return SharedAxisTransition(
              animation: primary,
              secondaryAnimation: secondary,
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: Colors.transparent,
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_phase),
            child: switch (_phase) {
              _Phase.setup => _buildSetup(context),
              _Phase.countdown => _buildCountdown(context),
              _Phase.reflection => _buildReflection(context),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSetup(BuildContext context) {
    final theme = Theme.of(context);
    final ocdAsync = ref.watch(ocdProvider);
    final suggestions = ocdAsync.maybeWhen(
      data: (entries) {
        final seen = <String>{};
        final out = <String>[];
        for (final e in entries) {
          if (e.type != OcdType.compulsion) continue;
          final text = e.content.trim();
          if (text.isEmpty || !seen.add(text.toLowerCase())) continue;
          out.add(text);
          if (out.length >= 6) break;
        }
        return out;
      },
      orElse: () => const <String>[],
    );

    return Column(
      children: [
        _Header(title: 'Pause the urge', onBack: () => Navigator.pop(context)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            children: staggered([
              Text(
                'Which urge are you sitting with?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: _compulsionController,
                minLines: 1,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'e.g. checking the lock, washing, googling…',
                ),
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in suggestions)
                      _SuggestionChip(
                        label: s,
                        selected:
                            _compulsionController.text.trim().toLowerCase() ==
                            s.toLowerCase(),
                        onTap: () => setState(() {
                          _compulsionController.text = s;
                        }),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              _UrgeCard(
                label: 'How strong is the urge right now?',
                value: _urgeBefore,
                onChanged: (v) => setState(() => _urgeBefore = v),
              ),
              const SizedBox(height: 24),
              Text(
                'How long will you wait?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _DurationPicker(
                seconds: _plannedSeconds,
                custom: _custom,
                onPreset: (secs) => setState(() {
                  _custom = false;
                  _plannedSeconds = secs;
                }),
                onCustom: () => setState(() => _custom = true),
              ),
              if (_custom) ...[
                const SizedBox(height: 16),
                _CustomMinutes(
                  minutes: _customMinutes,
                  onChanged: (m) => setState(() => _customMinutes = m),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _begin,
                  child: const Text('Begin'),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'You’re sitting with it',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notice the urge without acting. It will rise, then fall on its own.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _timer,
                builder: (context, _) {
                  final total = _timer.duration ?? Duration.zero;
                  final remaining = total * (1 - _timer.value);
                  return SizedBox(
                    width: 240,
                    height: 240,
                    child: CustomPaint(
                      painter: _RingPainter(
                        progress: _timer.value,
                        trackColor: theme.dividerColor.withValues(alpha: 0.6),
                        progressColor: theme.colorScheme.primary,
                      ),
                      child: Center(
                        child: Text(
                          _formatRemaining(remaining),
                          style: TextStyle(
                            fontFamily: AppTheme.displayFamily,
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _confirmStop,
              child: const Text('I need to stop'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _Header(title: 'How did that go?', onBack: null),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            children: staggered([
              Text(
                _completed
                    ? 'You waited the whole time. That’s the skill, right there.'
                    : 'You created space before acting. That still counts.',
                style: theme.textTheme.titleMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 24),
              _UrgeCard(
                label: 'How strong is the urge now?',
                value: _urgeAfter,
                onChanged: (v) => setState(() => _urgeAfter = v),
              ),
              const SizedBox(height: 24),
              Text(
                'What did you do with the urge?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _OutcomePicker(
                selected: _outcome,
                onChanged: (o) => setState(() => _outcome = o),
              ),
              const SizedBox(height: 24),
              Text(
                'Anything you noticed? (optional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'A short note is enough.',
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      _saving ? 'Saving...' : 'Save practice',
                      key: ValueKey(_saving),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

String _formatRemaining(Duration d) {
  final seconds = d.inSeconds.clamp(0, 1 << 31);
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(LineIcons.angleLeft),
            )
          else
            const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgeCard extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _UrgeCard({
    required this.label,
    required this.value,
    required this.onChanged,
  });

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
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                      color: _urgeColor(rounded),
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
          Slider(value: value, min: 0, max: 10, divisions: 10, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final int seconds;
  final bool custom;
  final ValueChanged<int> onPreset;
  final VoidCallback onCustom;

  const _DurationPicker({
    required this.seconds,
    required this.custom,
    required this.onPreset,
    required this.onCustom,
  });

  static const _presets = <int, String>{60: '1 min', 300: '5 min', 900: '15 min'};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: _softDecoration(Theme.of(context), radius: 24),
      child: Row(
        children: [
          for (final entry in _presets.entries)
            _SegmentChip(
              label: entry.value,
              selected: !custom && seconds == entry.key,
              onTap: () => onPreset(entry.key),
            ),
          _SegmentChip(
            label: 'Custom',
            selected: custom,
            onTap: onCustom,
          ),
        ],
      ),
    );
  }
}

class _CustomMinutes extends StatelessWidget {
  final double minutes;
  final ValueChanged<double> onChanged;

  const _CustomMinutes({required this.minutes, required this.onChanged});

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
                'Custom delay',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${minutes.round()} min',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Slider(
            value: minutes,
            min: 1,
            max: 60,
            divisions: 59,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _OutcomePicker extends StatelessWidget {
  final DelayOutcome? selected;
  final ValueChanged<DelayOutcome> onChanged;

  const _OutcomePicker({required this.selected, required this.onChanged});

  static const _labels = <DelayOutcome, String>{
    DelayOutcome.resisted: 'Resisted',
    DelayOutcome.delayed: 'Delayed it',
    DelayOutcome.performed: 'Did it',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: _softDecoration(Theme.of(context), radius: 24),
      child: Row(
        children: [
          for (final entry in _labels.entries)
            _SegmentChip(
              label: entry.value,
              selected: selected == entry.key,
              onTap: () => onChanged(entry.key),
            ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentChip({
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
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
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

class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? theme.colorScheme.primary
                : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
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

class _RingPainter extends CustomPainter {
  final double progress; // 0..1 elapsed
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    // Remaining arc shrinks clockwise from the top as time elapses.
    final sweep = 2 * math.pi * (1 - progress.clamp(0.0, 1.0));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}

BoxDecoration _softDecoration(ThemeData theme, {required double radius}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
  );
}

Color _urgeColor(int level) {
  if (level <= 3) return AppTheme.softGreen;
  if (level <= 7) return AppTheme.warmYellow;
  return AppTheme.mutedRed;
}
