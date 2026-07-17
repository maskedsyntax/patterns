import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/recovery_ui.dart';
import '../../widgets/section_intro.dart';

class UrgeSurfScreen extends ConsumerWidget {
  const UrgeSurfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessions = ref.watch(urgeSurfProvider);

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
                    'Urge Surfing',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Urges rise, crest, and fall on their own. Ride one out without '
              'acting on it.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            const SectionIntro(id: 'urgeSurf'),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startSurf(context),
                icon: const Icon(Icons.waves_rounded, size: 18),
                label: const Text('Start a surf'),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Past surfs',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            sessions.when(
              data: (items) {
                if (items.isEmpty) {
                  return Text(
                    'No surfs yet. Your first one will appear here.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  );
                }
                return Column(
                  children: [
                    for (final s in items) ...[
                      _SurfCard(session: s),
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
                'Your surfs are unavailable right now.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _startSurf(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        
        builder: (_) => const UrgeSurfFlow(),
      ),
    );
  }
}

class _SurfCard extends StatelessWidget {
  final UrgeSurfSession session;
  const _SurfCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mins = (session.durationSeconds / 60).floor();
    final secs = session.durationSeconds % 60;
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
                  session.trigger.isEmpty ? 'An urge' : session.trigger,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                DateFormat('MMM d').format(session.datetime),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Urge ${session.initialUrge} → peak ${session.peakUrge} → '
            '${session.finalUrge}   ·   surfed ${mins}m ${secs}s',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Surf flow
// ---------------------------------------------------------------------------

enum _Phase { setup, surfing, reflection }

class UrgeSurfFlow extends ConsumerStatefulWidget {
  /// When false (e.g. launched from the free Emergency Toolkit), the session is
  /// not persisted - surfing stays free, while tracking/history is Pro.
  final bool record;

  const UrgeSurfFlow({super.key, this.record = true});

  @override
  ConsumerState<UrgeSurfFlow> createState() => _UrgeSurfFlowState();
}

class _UrgeSurfFlowState extends ConsumerState<UrgeSurfFlow>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.setup;
  final _triggerController = TextEditingController();
  final _noteController = TextEditingController();

  double _initialUrge = 6;
  double _currentUrge = 6;
  double _finalUrge = 4;
  int _peakUrge = 6;
  int _plannedSeconds = 180;
  bool _saving = false;

  late final AnimationController _timer = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _timer.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishSurf(elapsed: _plannedSeconds);
      }
    });
  }

  @override
  void dispose() {
    _timer.dispose();
    _triggerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _begin() {
    setState(() {
      _currentUrge = _initialUrge;
      _peakUrge = _initialUrge.round();
      _finalUrge = _initialUrge;
      _phase = _Phase.surfing;
    });
    _timer
      ..duration = Duration(seconds: _plannedSeconds)
      ..forward(from: 0);
  }

  void _finishSurf({required int elapsed}) {
    if (_phase != _Phase.surfing) return;
    _timer.stop();
    HapticFeedback.mediumImpact();
    setState(() => _phase = _Phase.reflection);
  }

  void _endEarly() {
    final elapsed = (_plannedSeconds * _timer.value).round();
    _finishSurf(elapsed: elapsed);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    if (widget.record) {
      final now = DateTime.now();
      final actualSeconds = (_plannedSeconds * _timer.value).round();
      final session = UrgeSurfSession(
        datetime: now,
        trigger: _triggerController.text.trim(),
        initialUrge: _initialUrge.round(),
        peakUrge: _peakUrge,
        finalUrge: _finalUrge.round(),
        durationSeconds: actualSeconds == 0 ? _plannedSeconds : actualSeconds,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: now,
      );
      await ref.read(urgeSurfProvider.notifier).addSession(session);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(
      context,
      'Nice work riding that out.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppMotion.medium,
          child: switch (_phase) {
            _Phase.setup => _buildSetup(),
            _Phase.surfing => _buildSurfing(),
            _Phase.reflection => _buildReflection(),
          },
        ),
      ),
    );
  }

  Widget _buildSetup() {
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      children: staggered([
        Row(
          children: [
            const SizedBox.shrink(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Before you surf',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LabeledField(
          label: 'What is the urge? (optional)',
          hint: 'e.g. Urge to wash my hands again',
          controller: _triggerController,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: recoverySoftDecoration(theme, radius: 18),
          child: RatingSlider(
            label: 'How strong is it right now?',
            value: _initialUrge,
            onChanged: (v) => setState(() => _initialUrge = v),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'How long will you surf?',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _DurationPicker(
          seconds: _plannedSeconds,
          onChanged: (s) => setState(() => _plannedSeconds = s),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: _begin, child: const Text('Begin')),
        ),
      ]),
    );
  }

  Widget _buildSurfing() {
    final theme = Theme.of(context);
    return Padding(
      key: const ValueKey('surfing'),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Ride it out',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Notice the urge without feeding it. It will pass.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _timer,
            builder: (context, _) {
              final remaining = (_plannedSeconds * (1 - _timer.value)).ceil();
              final mins = (remaining / 60).floor();
              final secs = remaining % 60;
              return SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: 1 - _timer.value,
                        strokeWidth: 8,
                        backgroundColor: theme.dividerColor,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      '$mins:${secs.toString().padLeft(2, '0')}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFamily: AppTheme.displayFamily,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: recoverySoftDecoration(theme, radius: 18),
            child: RatingSlider(
              label: 'Urge right now',
              value: _currentUrge,
              onChanged: (v) => setState(() {
                _currentUrge = v;
                if (v.round() > _peakUrge) _peakUrge = v.round();
              }),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _endEarly,
              child: const Text("I'm done"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflection() {
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('reflection'),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      children: staggered([
        Text(
          'How was that?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: recoverySoftDecoration(theme, radius: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your wave',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Started at ${_initialUrge.round()} · peaked at $_peakUrge',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: recoverySoftDecoration(theme, radius: 18),
          child: RatingSlider(
            label: 'Where is the urge now?',
            value: _finalUrge,
            onChanged: (v) => setState(() => _finalUrge = v),
          ),
        ),
        const SizedBox(height: 16),
        LabeledField(
          label: 'Note (optional)',
          hint: 'What did you notice?',
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
                : Text(widget.record ? 'Save surf' : 'Finish'),
          ),
        ),
      ]),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final int seconds;
  final ValueChanged<int> onChanged;

  const _DurationPicker({required this.seconds, required this.onChanged});

  static const _options = {60: '1 min', 180: '3 min', 300: '5 min'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: recoverySoftDecoration(theme, radius: 16),
      child: Row(
        children: [
          for (final entry in _options.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.key),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: seconds == entry.key
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.value,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: seconds == entry.key
                          ? theme.colorScheme.onPrimary
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
