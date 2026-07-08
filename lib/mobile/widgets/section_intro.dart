import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../preferences.dart';
import 'recovery_ui.dart';

/// Copy for the one-time intro card shown the first time a user opens a
/// section. Keyed by a short [SectionIntro.id]. Kept in one place so all the
/// blurbs are easy to edit without touching the screens themselves.
const Map<String, ({String title, List<String> points})> sectionIntros = {
  // --- Main tabs ---
  'today': (
    title: 'Your daily anchor',
    points: [
      'A calm home base with a short reflection prompt and where you left off.',
      'Check in here once a day to keep the habit gentle and consistent.',
    ],
  ),
  'journal': (
    title: 'Write it down',
    points: [
      'Capture intrusive thoughts, feelings, and daily reflections in private.',
      'Naming a pattern is the first step to loosening its grip.',
    ],
  ),
  'track': (
    title: 'Log the moment',
    points: [
      'Record intrusive thoughts, compulsions, and how much distress they carried.',
      'Over time these entries reveal your triggers and what actually helps.',
    ],
  ),
  'recoveryHub': (
    title: 'Your recovery toolkit',
    points: [
      'Structured ERP exercises and coping tools, all in one place.',
      'Start with the free tools. Reach for the rest when you are ready.',
    ],
  ),
  'insights': (
    title: 'See the bigger picture',
    points: [
      'Charts turn your entries into trends across days and weeks.',
      'Progress in OCD recovery is rarely linear. This helps you spot it anyway.',
    ],
  ),

  // --- Free recovery tools ---
  'guidedErp': (
    title: 'Face it, step by step',
    points: [
      'Guided exposure and response prevention exercises to practice at your pace.',
      'The goal is to sit with discomfort without doing the compulsion.',
    ],
  ),
  'compulsionDelay': (
    title: 'Put a pause between urge and action',
    points: [
      'Delay a compulsion for a set time and notice the urge rise and fall.',
      'Each delay proves you can tolerate the feeling without acting on it.',
    ],
  ),
  'emergencyToolkit': (
    title: 'For the hard moments',
    points: [
      'Fast grounding techniques for when distress spikes.',
      'Keep it a tap away. You do not have to think clearly to use it.',
    ],
  ),
  'copingLibrary': (
    title: 'Skills worth revisiting',
    points: [
      'A reference of coping strategies and reframes you can return to anytime.',
      'Save the ones that land for you.',
    ],
  ),

  // --- Pro recovery tools ---
  'exposureHierarchy': (
    title: 'Build your ladder',
    points: [
      'List feared situations and rank them from easiest to hardest.',
      'Work up the ladder one rung at a time, not all at once.',
    ],
  ),
  'recoveryMetrics': (
    title: 'Measure what matters',
    points: [
      'Track exposures completed, avoidance, and distress over time.',
      'Small, steady numbers tell the real recovery story.',
    ],
  ),
  'urgeSurf': (
    title: 'Ride the wave',
    points: [
      'Urges rise, crest, and fall on their own if you let them.',
      'Surf one out here instead of acting on it.',
    ],
  ),
  'responsePrevention': (
    title: 'Resist the ritual',
    points: [
      'Plan and log how you held back from a compulsion.',
      'Response prevention is where exposures do their real work.',
    ],
  ),
  'structuredPrograms': (
    title: 'A guided path',
    points: [
      'Multi-day programs that sequence exposures for you.',
      'Follow along when you want structure instead of deciding each step.',
    ],
  ),
  'behavioralExperiments': (
    title: 'Test the fear',
    points: [
      'Predict what you fear will happen, then check what actually did.',
      'Reality is usually kinder than the anxious forecast.',
    ],
  ),
  'exposureReflection': (
    title: 'Reflect afterward',
    points: [
      'Journal what an exposure was like once the intensity fades.',
      'Reflection turns a hard moment into learning you can reuse.',
    ],
  ),
  'actionPlanner': (
    title: 'Plan the next step',
    points: [
      'Turn intentions into concrete, scheduled actions.',
      'A clear next step is easier to take than a vague resolve.',
    ],
  ),
  'implementationIntentions': (
    title: 'If-then plans',
    points: [
      'Decide in advance: "if X happens, I will do Y."',
      'Pre-committing makes the healthy response the automatic one.',
    ],
  ),
  'uncertaintyTraining': (
    title: 'Get comfortable not knowing',
    points: [
      'Short practices for tolerating doubt instead of seeking reassurance.',
      'OCD feeds on certainty. This starves it a little.',
    ],
  ),
  'exposureMaterials': (
    title: 'Your exposure materials',
    points: [
      'Store scripts, images, and notes you use during exposures.',
      'Keep everything you need for practice in one place.',
    ],
  ),
};

/// A one-time introduction card for a section. Shows the first time a user
/// opens the screen, then collapses to nothing on "Got it" (or if already
/// seen). Self-contained so stateless [ConsumerWidget] screens don't need to
/// become stateful - just drop `const SectionIntro(id: '<id>')` into the body.
class SectionIntro extends StatefulWidget {
  final String id;

  const SectionIntro({super.key, required this.id});

  static String _key(String id) => 'sectionSeen_$id';

  @override
  State<SectionIntro> createState() => _SectionIntroState();
}

class _SectionIntroState extends State<SectionIntro> {
  late bool _seen =
      mobilePreferences?.getBool(SectionIntro._key(widget.id)) ?? false;

  void _dismiss() {
    mobilePreferences?.setBool(SectionIntro._key(widget.id), true);
    setState(() => _seen = true);
  }

  @override
  Widget build(BuildContext context) {
    final intro = sectionIntros[widget.id];
    final reduceMotion = motionDisabled(context);

    final content = (_seen || intro == null)
        ? const SizedBox(width: double.infinity)
        : _buildCard(context, intro);

    // AnimatedSize gives a smooth collapse on dismiss; skipped when the user
    // has reduced motion so it snaps instead.
    if (reduceMotion) return content;
    return AnimatedSize(
      duration: AppMotion.medium,
      curve: AppMotion.stateCurve,
      alignment: Alignment.topCenter,
      child: content,
    );
  }

  Widget _buildCard(
    BuildContext context,
    ({String title, List<String> points}) intro,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: FadeSlideIn(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          decoration: recoverySoftDecoration(theme),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LineIcons.lightbulb,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      intro.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final point in intro.points) _bullet(theme, point),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _dismiss,
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
