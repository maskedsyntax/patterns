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
                      return _OnboardingPageView(
                        page: _pages[index],
                        isFinal: index == _pages.length - 1,
                      );
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
  final bool isFinal;

  const _OnboardingPageView({required this.page, this.isFinal = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isFinal
                  ? _finalChildren(context)
                  : _standardChildren(context),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _standardChildren(BuildContext context) {
    final theme = Theme.of(context);
    return [
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
    ];
  }

  // The final slide is sized to fit the viewport so it never scrolls behind the
  // fixed action buttons below it. A tighter hero plus a two-column Free vs Pro
  // comparison keeps the offer clear without the cramped, scrollable feel.
  List<Widget> _finalChildren(BuildContext context) {
    return [
      FadeSlideIn(
        duration: AppMotion.slow,
        child: _OnboardingVisual(page: page, size: 132),
      ),
      const SizedBox(height: 22),
      FadeSlideIn(
        delay: const Duration(milliseconds: 90),
        child: Text(
          page.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.displayFamily,
            fontWeight: FontWeight.w600,
            fontSize: 30,
            height: 1.08,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      const SizedBox(height: 12),
      FadeSlideIn(
        delay: const Duration(milliseconds: 130),
        child: Text(
          'Everything free stays free. Pro adds the active ERP toolkit.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.4,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: 20),
      FadeSlideIn(
        delay: const Duration(milliseconds: 170),
        child: const _FreeProCompareCard(),
      ),
    ];
  }
}

class _OnboardingVisual extends StatelessWidget {
  final _OnboardingPage page;
  final double size;

  const _OnboardingVisual({required this.page, this.size = 188});

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.447;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SignalPainter(color: page.color),
        child: Center(
          child: Container(
            width: inner,
            height: inner,
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
            child: Icon(
              page.icon,
              color: const Color(0xFF17130A),
              size: size * 0.202,
            ),
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
    for (final fraction in [0.287, 0.394, 0.497]) {
      canvas.drawCircle(center, size.width * fraction, ringPaint);
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

class _FreeProCompareCard extends StatelessWidget {
  const _FreeProCompareCard();

  static const _free = ['Journaling', 'OCD tracking', 'Insights & trends'];
  static const _pro = ['Guided ERP', 'Exposure tools', 'Response prevention'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: _CompareColumn(
                label: 'FREE',
                accent: AppTheme.textSecondary,
                items: _free,
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: const Color(0xFF34322D),
            ),
            const Expanded(
              child: _CompareColumn(
                label: 'PRO',
                accent: AppTheme.warmYellow,
                items: _pro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareColumn extends StatelessWidget {
  final String label;
  final Color accent;
  final List<String> items;

  const _CompareColumn({
    required this.label,
    required this.accent,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(LineIcons.check, color: accent, size: 13),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  items[i],
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.25,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
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
    title: 'A calm, private space.',
    body:
        'Patterns lives on your device — no account, no cloud, no one watching. A gentle place to notice OCD, not judge it.',
    points: [
      'Private and local-first by design',
      'No sign-up, ever',
      'Support to practice with, not a diagnosis',
    ],
    color: AppTheme.warmYellow,
  ),
  const _OnboardingPage(
    icon: Icons.self_improvement_rounded,
    title: 'A simple daily loop.',
    body:
        'The same gentle rhythm each day: notice what shows up, track it, practice responding differently, and reflect.',
    points: [
      'Notice and journal a thought',
      'Track urges, distress, and responses',
      'Practice ERP and delay tools',
    ],
    color: Color(0xFF7BBF91),
  ),
  const _OnboardingPage(
    icon: LineIcons.compass,
    title: 'Everything, one tap away.',
    body:
        "Five simple tabs, each with one job. We'll give you a quick tour in a moment.",
    points: [
      'Today — your daily anchor and next step',
      'Recovery — every tool, grouped by stage',
      'Insights — your trends over time',
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
