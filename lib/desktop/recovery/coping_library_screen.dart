import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/recovery_ui.dart';
import '../../widgets/section_intro.dart';

class _Strategy {
  final String title;
  final String body;
  const _Strategy(this.title, this.body);
}

class _CopingCategory {
  final String label;
  final List<_Strategy> strategies;
  const _CopingCategory(this.label, this.strategies);
}

const _categories = <_CopingCategory>[
  _CopingCategory('During urges', [
    _Strategy(
      'Deep breathing',
      'Slow your exhale. Breathe in for 4, out for 6. A longer out-breath '
          'tells your body it is safe to settle.',
    ),
    _Strategy(
      'Grounding (5-4-3-2-1)',
      'Name 5 things you can see, 4 you can feel, 3 you can hear, 2 you can '
          'smell, and 1 you can taste. Bring yourself back to right now.',
    ),
    _Strategy(
      'Urge surfing',
      'Picture the urge as a wave. Watch it rise, crest, and fall on its own. '
          'You do not have to act. It always passes.',
    ),
    _Strategy(
      'Acceptance statements',
      'Try: "This is just an intrusive thought. I can let it be here without '
          'responding to it."',
    ),
    _Strategy(
      'Mindful observation',
      'Watch the thought like a cloud drifting past. Notice it, label it '
          '"a thought", and let it move along.',
    ),
  ]),
  _CopingCategory('During anxiety', [
    _Strategy(
      'Progressive muscle relaxation',
      'Tense each muscle group for about 5 seconds, then release, from your '
          'feet up to your face. Notice the contrast as you let go.',
    ),
    _Strategy(
      'Mindfulness',
      'Rest your attention on your breath. When your mind wanders, gently and '
          'without judgement bring it back.',
    ),
    _Strategy(
      'Self-compassion',
      'Speak to yourself the way you would to a good friend: "This is hard, '
          'and I am doing my best."',
    ),
    _Strategy(
      'Go for a walk',
      'Take a slow walk and let your attention rest on each step and the air '
          'on your skin. Movement helps anxiety move through.',
    ),
  ]),
];

class CopingLibraryScreen extends StatelessWidget {
  const CopingLibraryScreen({super.key});

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
                    'Coping Library',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Healthy ways to ride out a hard moment.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            const SectionIntro(id: 'copingLibrary'),
            for (final category in _categories) ...[
              Text(
                category.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final strategy in category.strategies) ...[
                _StrategyCard(strategy: strategy),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
            ],
          ]),
        ),
      ),
    );
  }
}

class _StrategyCard extends StatefulWidget {
  final _Strategy strategy;
  const _StrategyCard({required this.strategy});

  @override
  State<_StrategyCard> createState() => _StrategyCardState();
}

class _StrategyCardState extends State<_StrategyCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: recoverySoftDecoration(theme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.strategy.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: AppMotion.fast,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.strategy.body,
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: AppMotion.fast,
            ),
          ],
        ),
      ),
    );
  }
}
