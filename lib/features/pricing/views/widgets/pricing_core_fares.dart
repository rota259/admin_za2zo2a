import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/z_card.dart';
import '../../cubit/pricing_cubit.dart';
import '../../data/models/pricing_config.dart';
import 'pricing_field.dart';

/// The "Core fares" card: the six flat/multiplier fare inputs in a 2-up grid.
class PricingCoreFares extends StatelessWidget {
  const PricingCoreFares({super.key, required this.config, required this.cubit});

  final PricingConfig config;
  final PricingCubit cubit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fields = <Widget>[
      PricingField(
        label: 'Base fare',
        value: config.baseFare,
        prefix: 'E£',
        hint: 'Charged at the start of every trip',
        onChanged: cubit.setBaseFare,
      ),
      PricingField(
        label: 'Pickup surcharge',
        value: config.pickupSurcharge,
        prefix: 'E£',
        hint: 'Added when the trip is picked up',
        onChanged: cubit.setPickupSurcharge,
      ),
      PricingField(
        label: 'Minimum fare',
        value: config.minFare,
        prefix: 'E£',
        hint: 'The lowest a trip can be charged',
        onChanged: cubit.setMinFare,
      ),
      PricingField(
        label: 'Surge multiplier',
        value: config.surgeMultiplier,
        suffix: '×',
        hint: 'Applied during high demand (≥ 1.0)',
        onChanged: cubit.setSurge,
      ),
      PricingField(
        label: 'Waiting rate',
        value: config.waitingPerMin,
        prefix: 'E£',
        suffix: '/min',
        hint: 'While the driver waits',
        onChanged: cubit.setWaiting,
      ),
      PricingField(
        label: 'Cancellation fee',
        value: config.cancellationFee,
        prefix: 'E£',
        hint: 'Charged on a late cancellation',
        onChanged: cubit.setCancellation,
      ),
    ];

    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Core fares', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth < 520 ? 1 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fields.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  mainAxisExtent: 92,
                ),
                itemBuilder: (context, i) => fields[i],
              );
            },
          ),
        ],
      ),
    );
  }
}
