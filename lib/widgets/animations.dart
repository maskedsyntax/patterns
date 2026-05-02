import 'package:flutter/material.dart';

/// Fade + slide-up entrance. Plays once on first build.
/// Use [delay] for staggered effects in lists or columns.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    this.delay = Duration.zero,
    this.offset = 16,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - curved.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Helper: wraps a list of children with a cascading [stagger] delay.
List<Widget> staggered(
  List<Widget> children, {
  Duration stagger = const Duration(milliseconds: 55),
  Duration initialDelay = Duration.zero,
  Duration duration = const Duration(milliseconds: 420),
  double offset = 14,
}) {
  return [
    for (var i = 0; i < children.length; i++)
      FadeSlideIn(
        delay: initialDelay + stagger * i,
        duration: duration,
        offset: offset,
        child: children[i],
      ),
  ];
}

/// Wrap a tappable surface to get a subtle scale-on-press response.
/// Pairs well with InkWell/GestureDetector inside the child.
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;
  final HitTestBehavior behavior;

  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 130),
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _setDown(bool value) {
    if (_down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Number that smoothly interpolates between values.
class AnimatedCounter extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final int fractionDigits;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.fractionDigits = 0,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, v, _) {
        final formatted = fractionDigits == 0
            ? v.round().toString()
            : v.toStringAsFixed(fractionDigits);
        return Text('$prefix$formatted$suffix', style: style);
      },
    );
  }
}
