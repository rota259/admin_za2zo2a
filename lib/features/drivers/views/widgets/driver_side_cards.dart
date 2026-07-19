import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/z_button.dart';
import '../../../../core/widgets/z_card.dart';
import '../../../../core/widgets/z_reason_dialog.dart';
import '../../cubit/driver_detail_cubit.dart';
import '../../data/models/driver_model.dart';
import 'verification_card.dart';

/// The detail screen's right column: vehicle facts, selfie verification, and
/// the block/unblock "danger zone".
class DriverSideCards extends StatelessWidget {
  const DriverSideCards({
    super.key,
    required this.driver,
    required this.state,
    required this.cubit,
  });

  final DriverModel driver;
  final DriverDetailState state;
  final DriverDetailCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _VehicleCard(driver: driver),
        const SizedBox(height: AppSpacing.lg),
        VerificationCard(verification: state.verification),
        const SizedBox(height: AppSpacing.lg),
        _DangerZone(driver: driver, state: state, cubit: cubit),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.driver});
  final DriverModel driver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = driver.vehicle;
    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _row(context, 'Model', v.display),
          _row(context, 'Colour', v.color.isEmpty ? '—' : v.color),
          _row(context, 'Year', v.year > 0 ? '${v.year}' : '—'),
          _row(context, 'Seats', '${v.seats}'),
          _row(context, 'Plate', v.plateNumber, mono: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool mono = false}) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
          ),
          Text(
            value,
            style: mono
                ? AppTypography.mono(size: 13, weight: FontWeight.w600)
                    .copyWith(color: t.text)
                : theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({
    required this.driver,
    required this.state,
    required this.cubit,
  });

  final DriverModel driver;
  final DriverDetailState state;
  final DriverDetailCubit cubit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final blocked = !driver.isActive;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.danger.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: t.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Danger zone',
              style: theme.textTheme.titleLarge?.copyWith(color: t.danger)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            blocked
                ? 'This driver is blocked and cannot go online. You can '
                    'reinstate them.'
                : "Restrict this driver's access. A reason is required and "
                    'recorded in the audit log.',
            style: theme.textTheme.bodySmall?.copyWith(color: t.text2),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (blocked)
            ZButton(
              label: 'Unblock driver',
              icon: Icons.lock_open_outlined,
              variant: ZButtonVariant.secondary,
              expand: true,
              loading: state.busyBlock,
              onPressed:
                  state.anyActionBusy ? null : () => _unblock(context),
            )
          else
            ZButton(
              label: 'Block driver',
              icon: Icons.block,
              variant: ZButtonVariant.danger,
              expand: true,
              loading: state.busyBlock,
              onPressed: state.anyActionBusy ? null : () => _block(context),
            ),
        ],
      ),
    );
  }

  Future<void> _block(BuildContext context) async {
    final reason = await ZReasonDialog.show(
      context,
      icon: Icons.block,
      title: 'Block this driver?',
      body: 'They lose access immediately and cannot accept trips. They are '
          'forced offline. You can unblock later.',
      confirmLabel: 'Block driver',
      requireReason: true,
      reasonHint: 'Reason for blocking (recorded in the audit log)…',
      danger: true,
    );
    if (reason != null) cubit.setBlocked(true, reason: reason);
  }

  Future<void> _unblock(BuildContext context) async {
    final ok = await ZReasonDialog.show(
      context,
      icon: Icons.lock_open_outlined,
      title: 'Unblock this driver?',
      body: 'They regain access and can go online and accept trips again.',
      confirmLabel: 'Unblock driver',
    );
    if (ok != null) cubit.setBlocked(false);
  }
}
