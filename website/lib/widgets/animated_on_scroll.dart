import 'package:flutter/material.dart';

class AnimatedOnScroll extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideFromY;

  const AnimatedOnScroll({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.slideFromY = 30,
  });

  @override
  State<AnimatedOnScroll> createState() => _AnimatedOnScrollState();
}

class _AnimatedOnScrollState extends State<AnimatedOnScroll>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _slideY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideY = Tween<double>(begin: widget.slideFromY, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Once animation is complete, render child directly without any
        // Transform wrapper to avoid hit-testing issues on web.
        if (_controller.isCompleted) {
          return child!;
        }
        return Padding(
          padding: EdgeInsets.only(top: _slideY.value.clamp(0, 999)),
          child: Opacity(opacity: _opacity.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
