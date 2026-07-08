import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/paywall_sheet.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onImport;

  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onImport,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  var _index = 0;

  bool get _isFinal => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This screen is visually hard-coded dark (fixed dark gradient + glass
    // cards), so force the dark theme regardless of the app's resolved
    // themeMode. Otherwise, in light mode, themed descendants (buttons,
    // theme-derived text) render light-on-dark and become unreadable.
    return Theme(
      data: AppTheme.mobileDarkTheme,
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0B0A), AppTheme.deepCharcoal],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
            child: Column(
              children: [
                _TopBar(
                  index: _index,
                  count: _pages.length,
                  onSkip: widget.onStart,
                  onBack: _index == 0 ? null : _previous,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPageView(page: _pages[index]);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _BottomActions(
                  finalStep: _isFinal,
                  onNext: _next,
                  onStart: widget.onStart,
                  onUnlock: () => PaywallSheet.show(context),
                  onImport: widget.onImport,
                ),
                const SizedBox(height: 8),
                Text(
                  'Private by design. Not a diagnosis or replacement for care.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _next() {
    if (_isFinal) {
      widget.onStart();
      return;
    }
    _controller.nextPage(
      duration: AppMotion.medium,
      curve: Curves.easeOutCubic,
    );
  }

  void _previous() {
    _controller.previousPage(
      duration: AppMotion.medium,
      curve: Curves.easeOutCubic,
    );
  }
}

class _TopBar extends StatelessWidget {
  final int index;
  final int count;
  final VoidCallback onSkip;
  final VoidCallback? onBack;

  const _TopBar({
    required this.index,
    required this.count,
    required this.onSkip,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: onBack == null
                  ? const SizedBox(height: 40, key: ValueKey('no-back'))
                  : IconButton(
                      key: const ValueKey('back'),
                      tooltip: 'Back',
                      onPressed: onBack,
                      icon: const Icon(LineIcons.angleLeft, size: 20),
                    ),
            ),
          ),
        ),
        Expanded(
          child: _ProgressDots(index: index, count: count),
        ),
        SizedBox(
          width: 58,
          child: TextButton(onPressed: onSkip, child: const Text('Skip')),
        ),
      ],
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int index;
  final int count;

  const _ProgressDots({required this.index, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: i == index ? 22 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == index ? AppTheme.warmYellow : const Color(0xFF3B3935),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeSlideIn(
                  duration: AppMotion.slow,
                  child: _OnboardingVisual(page: page),
                ),
                const SizedBox(height: 28),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 90),
                  child: Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 34,
                      height: 1.08,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 130),
                  child: Text(
                    page.body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.48,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 170),
                  child: _FeatureCard(page: page),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingVisual({required this.page});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 188,
      height: 188,
      child: CustomPaint(
        painter: _SignalPainter(color: page.color),
        child: Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [page.color, page.color.withValues(alpha: 0.62)],
              ),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(page.icon, color: const Color(0xFF17130A), size: 38),
          ),
        ),
      ),
    );
  }
}

class _SignalPainter extends CustomPainter {
  final Color color;

  const _SignalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.26);
    for (final radius in [54.0, 74.0, 94.0]) {
      canvas.drawCircle(center, radius, ringPaint);
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.34);
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.16 + i * 0.17);
      final y = center.dy + math.sin(i * 1.2) * 22;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SignalPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _FeatureCard extends StatelessWidget {
  final _OnboardingPage page;

  const _FeatureCard({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _glassDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < page.points.length; i++) ...[
            _PointRow(text: page.points[i]),
            if (i != page.points.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PointRow extends StatelessWidget {
  final String text;

  const _PointRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.warmYellow.withValues(alpha: 0.14),
          ),
          child: const Icon(
            LineIcons.check,
            color: AppTheme.warmYellow,
            size: 13,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool finalStep;
  final VoidCallback onNext;
  final VoidCallback onStart;
  final VoidCallback onUnlock;
  final VoidCallback onImport;

  const _BottomActions({
    required this.finalStep,
    required this.onNext,
    required this.onStart,
    required this.onUnlock,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    if (!finalStep) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(onPressed: onNext, child: const Text('Continue')),
          TextButton(
            onPressed: onImport,
            child: const Text('Import existing data'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(onPressed: onStart, child: const Text('Start free')),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: onUnlock, child: const Text('Unlock Pro')),
        const SizedBox(height: 8),
        Text(
          'One-time unlock. No subscription.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            height: 1.3,
          ),
        ),
        TextButton(
          onPressed: onImport,
          child: const Text('Import existing data'),
        ),
      ],
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;
  final List<String> points;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.points,
    required this.color,
  });
}

final _pages = <_OnboardingPage>[
  const _OnboardingPage(
    icon: LineIcons.feather,
    title: 'Understand your patterns.',
    body:
        'A calm private space to notice thoughts, urges, compulsions, and what helps you move through them.',
    points: [
      'Private local-first reflection',
      'Gentle tracking without pressure',
      'Built for noticing, not judging',
    ],
    color: AppTheme.warmYellow,
  ),
  const _OnboardingPage(
    icon: LineIcons.bullseye,
    title: 'Track what OCD repeats.',
    body:
        'Log intrusive thoughts, distress, responses, and themes so the loops become easier to see.',
    points: [
      'Journal thoughts and daily context',
      'Track urges, distress, and responses',
      'See themes emerge over time',
    ],
    color: Color(0xFF7BBF91),
  ),
  const _OnboardingPage(
    icon: Icons.self_improvement_rounded,
    title: 'Practice responding differently.',
    body:
        'Use daily ERP practice, delay tools, and recovery progress to build small moments of freedom.',
    points: [
      'Daily ERP habit support',
      'Compulsion delay and urge practice',
      'Progress that reflects real effort',
    ],
    color: AppTheme.warmYellow,
  ),
  const _OnboardingPage(
    icon: LineIcons.unlock,
    title: 'Start simple. Go deeper with Pro.',
    body:
        'Free gives you journaling, tracking, and insights. Pro unlocks the active ERP toolkit for structured recovery practice.',
    points: [
      'Free: journal, track, and understand patterns',
      'Pro: guided ERP, exposures, and response prevention',
      'Recovery metrics, programs, and deeper practice tools',
    ],
    color: AppTheme.warmYellow,
  ),
];

BoxDecoration _glassDecoration() {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1B1B19), Color(0xFF141413)],
    ),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFF34322D)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.22),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
