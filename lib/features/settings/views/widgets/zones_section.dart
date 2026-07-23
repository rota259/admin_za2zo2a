import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_badge.dart';
import '../../../../core/widgets/z_button.dart';
import '../../../../core/widgets/z_card.dart';
import '../../../../core/widgets/z_empty_state.dart';
import '../../../../core/widgets/z_reason_dialog.dart';
import '../../../../core/widgets/z_skeleton.dart';
import '../../cubit/zones_cubit.dart';
import '../../data/models/zone_model.dart';
import 'zone_form_dialog.dart';

/// Service zones — list + create/toggle/delete. `GET/POST/PATCH/DELETE
/// /api/admin/zones`, unpaginated per the spec.
class ZonesSection extends StatelessWidget {
  const ZonesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ZonesCubit>();
    final theme = Theme.of(context);

    return BlocBuilder<ZonesCubit, ZonesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Service zones', style: theme.textTheme.titleLarge),
                const Spacer(),
                ZButton(
                  label: 'New zone',
                  icon: Icons.add,
                  size: ZButtonSize.small,
                  onPressed: () => _create(context, cubit),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _body(context, state, cubit),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, ZonesState state, ZonesCubit cubit) {
    if (state.status == ZonesStatus.loading) {
      return const ZSkeletonList(rows: 4);
    }
    if (state.status == ZonesStatus.error) {
      return SizedBox(
        height: 220,
        child: ZErrorState(
            message: state.error ?? 'Failed to load zones.',
            onRetry: cubit.load),
      );
    }
    if (state.isEmpty) {
      return const SizedBox(
        height: 220,
        child: ZEmptyState(
          title: 'No zones yet',
          message: 'Create a service zone to set per-area surge overrides.',
          icon: Icons.map_outlined,
        ),
      );
    }
    return Column(
      children: [
        for (final z in state.zones)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ZoneCard(zone: z, busy: state.busy, cubit: cubit),
          ),
      ],
    );
  }

  Future<void> _create(BuildContext context, ZonesCubit cubit) async {
    final result = await ZoneFormDialog.show(context);
    if (result != null) {
      cubit.create(name: result.$1, areas: result.$2, surgeMultiplier: result.$3);
    }
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({required this.zone, required this.busy, required this.cubit});

  final ZoneModel zone;
  final bool busy;
  final ZonesCubit cubit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return ZCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(zone.name, style: theme.textTheme.titleMedium),
                    const SizedBox(width: AppSpacing.sm),
                    ZBadge.forStatus(zone.isActive ? 'active' : 'blocked'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  zone.areas.isEmpty ? 'No areas listed' : zone.areas.join(', '),
                  style: theme.textTheme.bodySmall?.copyWith(color: t.text2),
                ),
                const SizedBox(height: 6),
                Text(
                  '×${zone.surgeMultiplier.toStringAsFixed(2)} surge · '
                  '${zone.driverCount} drivers online',
                  style: theme.textTheme.labelSmall?.copyWith(color: t.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ZButton(
            label: zone.isActive ? 'Deactivate' : 'Activate',
            variant: ZButtonVariant.secondary,
            size: ZButtonSize.small,
            onPressed: busy ? null : () => cubit.toggleActive(zone),
          ),
          const SizedBox(width: AppSpacing.sm),
          ZButton(
            label: 'Delete',
            variant: ZButtonVariant.danger,
            size: ZButtonSize.small,
            onPressed: busy ? null : () => _delete(context),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await ZReasonDialog.show(
      context,
      icon: Icons.delete_outline,
      title: 'Delete "${zone.name}"?',
      body: 'This removes the zone and its surge override. This cannot be undone.',
      confirmLabel: 'Delete zone',
      danger: true,
    );
    if (ok != null) cubit.delete(zone);
  }
}
