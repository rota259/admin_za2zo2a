import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/util/ambient_motion.dart';
import 'login_brand_panel_parts.dart';

/// The login screen's crimson brand panel, with a slow ambient background:
/// two radial glows that gently "breathe" and decorative rings that drift.
///
/// The motion is deliberately slow and low-contrast — a calm brand moment, not
/// a distraction. Only the background layers repaint each frame; the content is
/// held static via the [AnimatedBuilder] child. Ambient motion is off in tests
/// (see [AmbientMotion]).
///
/// One deliberate omission: the design's stat block ("1,284 trips today", …) is
/// mock data with no backend, so it is left out rather than fabricated.
class LoginBrandPanel extends StatefulWidget {
  const LoginBrandPanel({super.key});

  @override
  State<LoginBrandPanel> createState() => _LoginBrandPanelState();
}

class _LoginBrandPanelState extends State<LoginBrandPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void initState() {
    super.initState();
    if (AmbientMotion.enabled) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _wave(double t, double freq, [double phase = 0]) =>
      math.sin(2 * math.pi * (t * freq) + phase);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const LoginBrandLockup(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CONTROL PANEL',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1.82,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Run the fleet from a single, calm cockpit.',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 42,
                    height: 1.06,
                    letterSpacing: -1.26,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Drivers, riders, trips, pricing and safety — everything '
                  'that keeps Cairo moving, in one place.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox.shrink(),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return ClipRect(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.42, -1.0),
                end: Alignment(0.42, 1.0),
                stops: [0.0, 0.44, 1.30],
                colors: [Color(0xFF2A0512), Color(0xFF7D0C2B), AppTokens.brand],
              ),
            ),
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                final t = _c.value;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: LoginGlowOverlay(
                        glow1: 0.42 + 0.14 * _wave(t, 1.0),
                        glow2: 0.36 + 0.12 * _wave(t, 1.6, 1.1),
                        drift: 6 * _wave(t, 0.7),
                      ),
                    ),
                    Positioned(
                      right: -60,
                      top: h * 0.38 + 10 * _wave(t, 0.8),
                      child: Transform.rotate(
                        angle: t * 2 * math.pi * 0.12,
                        child: const LoginRing(size: 340, opacity: 0.14),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: h * 0.30 - 12 * _wave(t, 1.05, 0.6),
                      child: const LoginRing(size: 200, opacity: 0.10),
                    ),
                    child!,
                  ],
                );
              },
              child: content,
            ),
          ),
        );
      },
    );
  }
}
