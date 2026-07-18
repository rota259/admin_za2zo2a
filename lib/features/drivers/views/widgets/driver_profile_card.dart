import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/z_badge.dart';
import '../../../../core/widgets/z_card.dart';
import '../../data/models/driver_model.dart';
import 'driver_avatar.dart';
import 'tier_badge.dart';

/// Header card: avatar, name + status + tier, contact line, and the four
/// live stat tiles (trips, rating, earnings, acceptance).
class DriverProfileCard extends StatelessWidget {
  const DriverProfileCard({super.key, required this.driver});

  final DriverModel driver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;

    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DriverAvatar(
                name: driver.fullName,
                initials: driver.initials,
                photoUrl: driver.profilePhoto,
                size: 72,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(driver.fullName,
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontSize: 22)),
                        ZBadge.forStatus(driver.status.name),
                        TierBadge(tier: driver.tier),
                        if (driver.isOnline)
                          const ZBadge(
                              label: 'Online', tone: ZBadgeTone.success),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _contact(context),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _stats(context),
          if (!driver.isVerified) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.info_outline, size: 15, color: t.warning),
                const SizedBox(width: 6),
                Text('Not yet verified',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: t.warning)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _contact(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    Widget item(IconData icon, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: t.text2),
            const SizedBox(width: 6),
            Text(text,
                style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
          ],
        );

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        item(Icons.phone_outlined, driver.phone),
        item(Icons.mail_outline, driver.email),
      ],
    );
  }

  Widget _stats(BuildContext context) {
    final tiles = [
      (_Stat('Total trips', '${driver.totalTrips}', Icons.route_outlined)),
      (_Stat('Rating',
          driver.rating > 0 ? driver.rating.toStringAsFixed(1) : '—',
          Icons.star_outline)),
      (_Stat('Earnings', 'E£${driver.earningsLifetime.toStringAsFixed(0)}',
          Icons.account_balance_wallet_outlined)),
      (_Stat('Acceptance', '${driver.acceptanceRate}%',
          Icons.check_circle_outline)),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth < 420 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            // Fixed height keeps the tile from over/under-sizing as the column
            // count changes with width.
            mainAxisExtent: 78,
          ),
          itemBuilder: (context, i) => _StatTile(stat: tiles[i]),
        );
      },
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(stat.icon, size: 14, color: t.text2),
              const SizedBox(width: 6),
              Flexible(
                child: Text(stat.label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: t.text2, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(stat.value,
              style: AppTypography.mono(size: 19, weight: FontWeight.w700)
                  .copyWith(color: t.text)),
        ],
      ),
    );
  }
}
