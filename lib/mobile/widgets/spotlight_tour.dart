import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';

/// One step of a [showSpotlightTour]: a widget to spotlight (via its
/// [GlobalKey]) and the copy to show beside it. [onShow] runs just before the
/// step appears — e.g. to switch the visible tab so the real screen shows
/// behind the cutout. [ctaLabel], when set, turns the primary button into a
/// custom call to action (used for the finale that launches the self-check).
class TourStep {
  /// The widget to spotlight. When null, the step shows a centered card over a
  /// full scrim (used for the concluding step, which has no single anchor).
  final GlobalKey? targetKey;
  final String title;
  final List<String> points;
  final String? ctaLabel;
  final VoidCallback? onShow;

  const TourStep({
    this.targetKey,
    required this.title,
    this.points = const [],
    this.ctaLabel,
    this.onShow,
  });
}

/// Shows a one-time coach-mark tour that dims the screen and spotlights each
/// [TourStep]'s target in turn. [onFinish] fires when the tour ends (completed
/// or skipped) — persist the "seen" flag there. [onFinaleCta] fires when the
/// user taps a step's [TourStep.ctaLabel] button.
void showSpotlightTour(
  BuildContext context, {
  required List<TourStep> steps,
  required VoidCallback onFinish,
  VoidCallback? onFinaleCta,
}) {
  if (steps.isEmpty) {
    onFinish();
    return;
  }
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  var closed = false;
  void close({bool runCta = false}) {
    if (closed) return;
    closed = true;
    entry.remove();
    if (runCta) onFinaleCta?.call();
    onFinish();
  }

  entry = OverlayEntry(
    builder: (_) => _SpotlightOverlay(steps: steps, onClose: close),
  );
  overlay.insert(entry);
}

class _SpotlightOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final void Function({bool runCta}) onClose;

  const _SpotlightOverlay({required this.steps, required this.onClose});

  @override
  State<_SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<_SpotlightOverlay> {
  int _index = 0;
  Rect? _rect;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  TourStep get _step => widget.steps[_index];
  bool get _isLast => _index == widget.steps.length - 1;

  void _prepare() {
    _rect = null;
    _ready = false;
    final myIndex = _index;
    // Defer onShow out of the current build/mount phase — it may switch tabs,
    // i.e. setState on an ancestor, which is illegal during build. A
    // target-less step is ready immediately (centered card).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _index != myIndex) return;
      _step.onShow?.call();
      if (_step.targetKey == null) {
        setState(() => _ready = true);
      } else {
        _track(myIndex, frames: 40);
      }
    });
  }

  /// Re-measures the target every frame for a short window, so the highlight
  /// follows any route/tab transition (e.g. a Settings pop sliding Home in)
  /// into its settled position instead of freezing on a mid-animation frame.
  void _track(int myIndex, {required int frames}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _index != myIndex) return;
      final rect = _rectFor(_step.targetKey);
      if (rect != null && (rect != _rect || !_ready)) {
        setState(() {
          _rect = rect;
          _ready = true;
        });
      }
      if (frames > 1) {
        _track(myIndex, frames: frames - 1);
      } else if (!_ready) {
        // Never measured — show the card centered rather than trap the user
        // behind a scrim with no way forward.
        setState(() => _ready = true);
      }
    });
  }

  Rect? _rectFor(GlobalKey? key) {
    final ctx = key?.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    // Measure relative to the overlay (not the raw screen) so the rect lines up
    // with the painter's canvas even though the app sits inside a centered
    // max-width frame.
    final overlayBox = Overlay.of(context).context.findRenderObject();
    final ancestor = overlayBox is RenderBox ? overlayBox : null;
    return box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
  }

  void _next() {
    if (_isLast) {
      widget.onClose();
      return;
    }
    setState(() => _index++);
    _prepare();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Swallow taps so nothing behind the scrim is triggered mid-tour.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: CustomPaint(painter: _SpotlightPainter(_rect)),
            ),
          ),
          if (_ready) _buildBubble(size, _rect),
        ],
      ),
    );
  }

  Widget _buildBubble(Size size, Rect? rect) {
    final bubble = _TourBubble(
      key: ValueKey(_index),
      step: _step,
      index: _index,
      total: widget.steps.length,
      isLast: _isLast,
      onNext: _next,
      onSkip: () => widget.onClose(),
      onCta: _step.ctaLabel != null
          ? () => widget.onClose(runCta: true)
          : null,
      reduceMotion: motionDisabled(context),
    );
    const constraints = BoxConstraints(maxWidth: 440);

    // No target → concluding card, centered over a full scrim.
    if (rect == null) {
      return Positioned.fill(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: ConstrainedBox(constraints: constraints, child: bubble),
          ),
        ),
      );
    }

    // Target near the top → bubble below it; near the bottom (tab bar) → above.
    final placeBelow = rect.center.dy < size.height / 2;
    const margin = 16.0;
    return Positioned(
      left: margin,
      right: margin,
      top: placeBelow ? rect.bottom + 14 : null,
      bottom: placeBelow ? null : size.height - rect.top + 14,
      child: Align(
        alignment: placeBelow ? Alignment.topCenter : Alignment.bottomCenter,
        child: ConstrainedBox(constraints: constraints, child: bubble),
      ),
    );
  }
}

class _TourBubble extends StatelessWidget {
  final TourStep step;
  final int index;
  final int total;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onCta;
  final bool reduceMotion;

  const _TourBubble({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
    required this.onCta,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1F1D), Color(0xFF141413)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A382F)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${index + 1} of $total',
                style: const TextStyle(
                  color: AppTheme.warmYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (!isLast || onCta != null)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Skip'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            step.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          for (final point in step.points) _bullet(point),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onCta ?? onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(step.ctaLabel ?? (isLast ? 'Done' : 'Next')),
            ),
          ),
        ],
      ),
    );

    return reduceMotion
        ? card
        : FadeSlideIn(duration: AppMotion.medium, child: card);
  }

  Widget _bullet(String text) {
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? rect;

  const _SpotlightPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Paint()..color = Colors.black.withValues(alpha: 0.82);
    if (rect == null) {
      canvas.drawRect(Offset.zero & size, scrim);
      return;
    }
    // Keep the cutout fully on-screen so an edge tab's ring isn't clipped.
    const m = 5.0;
    final inflated = rect!.inflate(6);
    final holeRect = Rect.fromLTRB(
      inflated.left.clamp(m, size.width - m),
      inflated.top.clamp(m, size.height - m),
      inflated.right.clamp(m, size.width - m),
      inflated.bottom.clamp(m, size.height - m),
    );
    final rrect = RRect.fromRectAndRadius(
      holeRect,
      const Radius.circular(16),
    );
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()..addRRect(rrect);
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, hole),
      scrim,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppTheme.warmYellow.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.rect != rect;
}
