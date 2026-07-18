import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_card.dart';
import '../../cubit/pricing_cubit.dart';
import '../../data/models/pricing_config.dart';
import 'pricing_field.dart';

/// The "Distance tiers" card — an editable row per per-km rate step, with the
/// open-ended final tier and add/remove controls.
class PricingTierEditor extends StatelessWidget {
  const PricingTierEditor({
    super.key,
    required this.tiers,
    required this.cubit,
  });

  final List<PerKmTier> tiers;
  final PricingCubit cubit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distance tiers', style: theme.textTheme.titleLarge),
                    Text(
                      'Per-kilometre rate steps down as trips get longer.',
                      style: theme.textTheme.bodySmall?.copyWith(color: t.text2),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: cubit.addTier,
                icon: Icon(Icons.add, size: 16, color: t.accentText),
                label: Text('Add tier',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: t.accentText)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < tiers.length; i++) ...[
            _TierRow(
              key: ValueKey('tier-$i-${tiers.length}'),
              index: i,
              tier: tiers[i],
              canRemove: tiers.length > 1,
              cubit: cubit,
            ),
            if (i < tiers.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    super.key,
    required this.index,
    required this.tier,
    required this.canRemove,
    required this.cubit,
  });

  final int index;
  final PerKmTier tier;
  final bool canRemove;
  final PricingCubit cubit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: tier.isOpenEnded
              ? _openEndedLabel(context)
              : PricingField(
                  label: index == 0 ? 'Up to' : 'Then up to',
                  value: tier.uptoKm ?? 0,
                  suffix: 'km',
                  onChanged: (v) => cubit.setTierUpto(index, v),
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: PricingField(
            label: 'Rate',
            value: tier.pricePerKm,
            prefix: 'E£',
            suffix: '/km',
            onChanged: (v) => cubit.setTierPrice(index, v),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: IconButton(
            onPressed: canRemove ? () => cubit.removeTier(index) : null,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: t.text3,
            tooltip: canRemove ? 'Remove tier' : 'At least one tier is required',
          ),
        ),
      ],
    );
  }

  Widget _openEndedLabel(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Beyond', style: theme.textTheme.titleSmall),
        const SizedBox(height: 7),
        Container(
          height: 44,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: t.surface2,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: t.border),
          ),
          child: Text('the last tier',
              style: theme.textTheme.bodyMedium?.copyWith(color: t.text3)),
        ),
      ],
    );
  }
}
