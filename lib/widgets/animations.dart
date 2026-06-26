import 'package:flutter/material.dart';

class AppMotion {
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);

  static const stagger = Duration(milliseconds: 28);
  static const smallOffset = 6.0;
  static const mediumOffset = 10.0;

  static const entranceCurve = Curves.easeOutCubic;
  static const stateCurve = Curves.easeInOutCubic;
  static const accentCurve = Curves.easeOutBack;

  const AppMotion._();
}

bool motionDisabled(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

/// A quiet entrance for content that should settle into place, not perform.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = AppMotion.medium,
    this.delay = Duration.zero,
    this.offset = AppMotion.mediumOffset,
    this.curve = AppMotion.entranceCurve,
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
    if (motionDisabled(context)) return widget.child;

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

/// A soft entrance for a single section.
class SoftReveal extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  const SoftReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.medium,
    this.offset = AppMotion.smallOffset,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: delay,
      duration: duration,
      offset: offset,
      child: child,
    );
  }
}

/// Helper: wraps a list of children with a subtle, capped reveal.
///
/// For long lists, pass [maxSteps] to cap how far the delay accumulates —
/// children past that index share the same (capped) delay and animate in
/// together, so the screen settles as grouped content instead of a sequence.
List<Widget> staggered(
  List<Widget> children, {
  Duration stagger = AppMotion.stagger,
  Duration initialDelay = Duration.zero,
  Duration duration = AppMotion.medium,
  double offset = AppMotion.smallOffset,
  int? maxSteps = 3,
}) {
  return [
    for (var i = 0; i < children.length; i++)
      FadeSlideIn(
        delay:
            initialDelay +
            stagger * (maxSteps == null ? i : i.clamp(0, maxSteps)),
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
    if (motionDisabled(context)) {
      return GestureDetector(
        behavior: widget.behavior,
        onTap: widget.onTap,
        child: widget.child,
      );
    }

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
    if (motionDisabled(context)) {
      final formatted = fractionDigits == 0
          ? value.round().toString()
          : value.toDouble().toStringAsFixed(fractionDigits);
      return Text('$prefix$formatted$suffix', style: style);
    }

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
