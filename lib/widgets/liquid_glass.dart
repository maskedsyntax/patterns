import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A reusable "Liquid Glass" surface, approximating the iOS 26 material in pure
/// Flutter. It combines three things plain frosted glass lacks:
///
/// 1. **Vibrancy** - the backdrop blur is composed with a saturation boost, so
///    content behind glows through instead of looking milky.
/// 2. **Specular edge light** - a bright rim along the top edge (the glass
///    bevel), fading toward the bottom (see [_GlassRim]).
/// 3. **Depth** - a soft outer drop shadow plus a faint translucent body.
class LiquidGlass extends StatelessWidget {
  final Widget child;

  /// Corner radius for the rounded-rect shape. Ignored when [circle] is true.
  final double borderRadius;

  /// Render as a circle (e.g. the FAB) instead of a rounded rectangle.
  final bool circle;

  /// Optional accent wash blended into the glass body (e.g. amber for the FAB).
  final Color? tint;

  final double blurSigma;
  final double saturation;

  /// Overall opacity of the translucent body (0 = clearest, 1 = most opaque).
  final double opacity;

  /// Drop shadow beneath the surface. Pass null to omit (e.g. nested surfaces).
  final List<BoxShadow>? shadows;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.circle = false,
    this.tint,
    this.blurSigma = 24,
    this.saturation = 1.6,
    this.opacity = 1.0,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shape = circle
        ? const CircleBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          );

    // Translucent body - lighter/clearer than a flat fill so content shows
    // through. Brighter at the top to read as a lit glass pane. A [tint] folds
    // straight into the gradient (e.g. amber glass for the FAB).
    final List<Color> bodyColors;
    if (tint != null) {
      bodyColors = [
        tint!.withValues(alpha: (isDark ? 0.88 : 0.94) * opacity),
        tint!.withValues(alpha: (isDark ? 0.64 : 0.74) * opacity),
      ];
    } else if (isDark) {
      bodyColors = [
        Colors.white.withValues(alpha: 0.14 * opacity),
        theme.colorScheme.surface.withValues(alpha: 0.40 * opacity),
      ];
    } else {
      bodyColors = [
        Colors.white.withValues(alpha: 0.55 * opacity),
        Colors.white.withValues(alpha: 0.28 * opacity),
      ];
    }
    final bodyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: bodyColors,
    );

    Widget glass = ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: _glassFilter(),
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: bodyGradient),
          child: child,
        ),
      ),
    );

    // Specular rim painted on top of the glass body.
    glass = CustomPaint(
      foregroundPainter: _GlassRim(shape: shape, isDark: isDark),
      child: glass,
    );

    if (shadows != null && shadows!.isNotEmpty) {
      glass = DecoratedBox(
        decoration: ShapeDecoration(shape: shape, shadows: shadows),
        child: glass,
      );
    }
    return glass;
  }

  ui.ImageFilter _glassFilter() {
    final blur = ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);
    // ColorFilter implements ImageFilter, so it composes with the blur to add
    // vibrancy (saturation boost) to the blurred backdrop.
    return ui.ImageFilter.compose(
      outer: ColorFilter.matrix(_saturationMatrix(saturation)),
      inner: blur,
    );
  }
}

/// Luminance-preserving saturation matrix (4x5, row-major) for [ColorFilter].
/// [s] = 1.0 is identity; > 1 boosts saturation.
List<double> _saturationMatrix(double s) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final sr = (1 - s) * lr, sg = (1 - s) * lg, sb = (1 - s) * lb;
  return <double>[
    sr + s,
    sg,
    sb,
    0,
    0,
    sr,
    sg + s,
    sb,
    0,
    0,
    sr,
    sg,
    sb + s,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

/// Strokes the glass shape with a top-bright / bottom-faint gradient to read as
/// a beveled glass edge catching light.
class _GlassRim extends CustomPainter {
  final ShapeBorder shape;
  final bool isDark;

  _GlassRim({required this.shape, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.55 : 0.85),
          Colors.white.withValues(alpha: isDark ? 0.10 : 0.30),
          Colors.white.withValues(alpha: 0.04),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);
    canvas.drawPath(path, rim);
  }

  @override
  bool shouldRepaint(_GlassRim old) =>
      old.isDark != isDark || old.shape != shape;
}
