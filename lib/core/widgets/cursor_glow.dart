import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../util/ambient_motion.dart';

/// An ambient radial glow that follows the mouse across [child], easing toward
/// the cursor with a soft trailing lag. Painted *behind* the child, so content
/// stays fully readable — it only shows through transparent/gutter areas.
///
/// Deliberately subtle: this is an operator tool, not a landing page. Honours
/// [AmbientMotion.enabled] so tests/goldens render a static child.
class CursorGlow extends StatefulWidget {
  const CursorGlow({
    super.key,
    required this.child,
    required this.color,
    this.opacity = 0.06,
    this.radius = 620,
  });

  final Widget child;
  final Color color;

  /// Peak glow opacity at the cursor centre.
  final double opacity;

  /// Glow radius in logical pixels.
  final double radius;

  @override
  State<CursorGlow> createState() => _CursorGlowState();
}

class _CursorGlowState extends State<CursorGlow>
    with SingleTickerProviderStateMixin {
  // The eased glow centre, repainted by the CustomPaint (not a widget rebuild).
  final ValueNotifier<Offset?> _glow = ValueNotifier<Offset?>(null);
  Offset? _target;

  // Created only when motion is on, so disabled (test) builds never spin a
  // ticker — and dispose never lazily creates one on a defunct element.
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    if (AmbientMotion.enabled) _ticker = createTicker(_tick);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _glow.dispose();
    super.dispose();
  }

  void _onHover(PointerHoverEvent e) {
    _target = e.localPosition;
    _glow.value ??= e.localPosition; // start at first hover, no fly-in
    if (_ticker != null && !_ticker!.isActive) _ticker!.start();
  }

  void _onExit(PointerExitEvent _) {
    _target = null; // ease back out; the ticker fades the glow away
    if (_ticker != null && !_ticker!.isActive) _ticker!.start();
  }

  void _tick(Duration _) {
    final current = _glow.value;
    final target = _target;

    if (target == null) {
      // No cursor: drop the glow, then stop.
      _glow.value = null;
      _ticker?.stop();
      return;
    }

    final start = current ?? target;
    final next = Offset.lerp(start, target, 0.12)!;
    _glow.value = next;

    // Settled — stop until the next hover to save frames.
    if ((next - target).distance < 0.4) _ticker?.stop();
  }

  @override
  Widget build(BuildContext context) {
    if (!AmbientMotion.enabled) return widget.child;

    return MouseRegion(
      opaque: false,
      onHover: _onHover,
      onExit: _onExit,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _GlowPainter(
                    glow: _glow,
                    color: widget.color,
                    opacity: widget.opacity,
                    radius: widget.radius,
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.glow,
    required this.color,
    required this.opacity,
    required this.radius,
  }) : super(repaint: glow);

  final ValueNotifier<Offset?> glow;
  final Color color;
  final double opacity;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = glow.value;
    if (center == null) return;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.color != color || old.opacity != opacity || old.radius != radius;
}
