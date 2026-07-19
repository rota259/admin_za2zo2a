import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';

/// Two circular radial glows (ellipse-approximated), whose opacity + centre
/// drift are animated by the parent brand panel.
class LoginGlowOverlay extends StatelessWidget {
  const LoginGlowOverlay({
    super.key,
    required this.glow1,
    required this.glow2,
    required this.drift,
  });

  final double glow1;
  final double glow2;
  final double drift;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: glow1.clamp(0.0, 1.0),
              child: Transform.scale(
                scaleX: 680 / 420,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.64 + drift * 0.01, -0.84),
                      radius: 0.62,
                      stops: const [0.0, 0.6],
                      colors: const [Color(0x52FFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: glow2.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.84, 1.16 - drift * 0.01),
                    radius: 0.72,
                    stops: const [0.0, 0.55],
                    colors: const [Color(0x8EFF7896), Color(0x00FF7896)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The brand + OPERATOR lockup at the top of the panel.
class LoginBrandLockup extends StatelessWidget {
  const LoginBrandLockup({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              child: const Icon(Icons.directions_car_filled_outlined,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'Za2zo2a',
          style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white, fontSize: 19, letterSpacing: -0.38),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            'OPERATOR',
            style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.22),
          ),
        ),
      ],
    );
  }
}

/// A thin decorative ring.
class LoginRing extends StatelessWidget {
  const LoginRing({super.key, required this.size, required this.opacity});

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
              color: Colors.white.withValues(alpha: opacity), width: 1.5),
        ),
      ),
    );
  }
}
