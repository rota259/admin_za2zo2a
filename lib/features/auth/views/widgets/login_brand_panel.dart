import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';

/// The login screen's crimson brand panel.
///
/// One deliberate omission: the design's stat block ("1,284 trips today",
/// "312 drivers online", "4.9 avg rating") is mock data and the backend
/// exposes no stats endpoint, so it is left out rather than fabricated.
class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return ClipRect(
          child: DecoratedBox(
            // linear-gradient(155deg, #2a0512 0%, #7d0c2b 44%, #e8194b 130%).
            // 155deg in CSS runs top→bottom rotated clockwise; the 130% stop
            // pushes pure crimson past the corner, so the visible corner never
            // reaches full accent.
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.42, -1.0),
                end: Alignment(0.42, 1.0),
                stops: [0.0, 0.44, 1.30],
                colors: [
                  Color(0xFF2A0512),
                  Color(0xFF7D0C2B),
                  AppTokens.brand,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Two radial glows at opacity .5, per the design's overlay.
                const Positioned.fill(child: _GlowOverlay()),

                // Decorative rings, positioned by % of panel height.
                Positioned(right: -60, top: h * 0.38, child: const _Ring(size: 340, opacity: 0.14)),
                Positioned(right: 20, top: h * 0.30, child: const _Ring(size: 200, opacity: 0.10)),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 52,
                    vertical: 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _BrandLockup(),
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
                                letterSpacing: 1.82, // .14em × 13px
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Run the fleet from a single, calm cockpit.',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 42,
                                height: 1.06,
                                letterSpacing: -1.26, // -.03em × 42px
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Drivers, riders, trips, pricing and safety — '
                              'everything that keeps Cairo moving, in one place.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Design places its stat row here — omitted (see above).
                      const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// `radial-gradient(680px 420px at 82% 8%, rgba(255,255,255,.16), transparent 60%)`
/// + `radial-gradient(520px 520px at 8% 108%, rgba(255,120,150,.28), transparent 55%)`
/// at layer opacity .5. Flutter's RadialGradient is circular, so each ellipse
/// is drawn circular and scaled — visually equivalent at these sizes.
class _GlowOverlay extends StatelessWidget {
  const _GlowOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.5,
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.scale(
                scaleX: 680 / 420,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.64, -0.84), // 82% 8%
                      radius: 0.62,
                      stops: [0.0, 0.6],
                      colors: [Color(0x29FFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.84, 1.16), // 8% 108%
                    radius: 0.72,
                    stops: [0.0, 0.55],
                    colors: [Color(0x47FF7896), Color(0x00FF7896)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // backdrop-filter: blur(4px) behind a translucent tile.
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: const Icon(
                Icons.directions_car_filled_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'Za2zo2a',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontSize: 19,
            letterSpacing: -0.38, // -.02em × 19px
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            'OPERATOR',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.22, // .02em × 11px
            ),
          ),
        ),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: opacity),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
