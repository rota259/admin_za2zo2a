import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';

/// Driver tier pill (7px radius, per the design's `tierBadge`).
///
/// The backend tiers are `standard | gold | platinum` — mapped to the design's
/// colours (standard → blue, gold → amber, platinum → slate).
class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.tier});

  final String tier;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _style(tier.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              fontSize: 12,
            ),
      ),
    );
  }

  (String, Color) _style(String tier) => switch (tier) {
        'gold' => ('Gold', const Color(0xFFD97706)),
        'platinum' => ('Platinum', const Color(0xFF64748B)),
        _ => ('Standard', const Color(0xFF3B82F6)),
      };
}

/// A star + rating figure, per the list's Rating column.
class RatingCell extends StatelessWidget {
  const RatingCell({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFD97706)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          rating > 0 ? rating.toStringAsFixed(1) : '—',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
