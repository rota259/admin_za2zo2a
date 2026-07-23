import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/z_badge.dart';
import '../../../core/widgets/z_button.dart';
import '../../../core/widgets/z_card.dart';
import '../../../core/widgets/z_empty_state.dart';
import '../../../core/widgets/z_reason_dialog.dart';
import '../../../core/widgets/z_skeleton.dart';
import '../../../injection_container.dart';
import '../../drivers/views/widgets/driver_avatar.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/rider_detail_cubit.dart';
import '../data/models/rider_model.dart';
import '../data/repos/riders_repo.dart';

/// Rider detail. Owns a [RiderDetailCubit] scoped to [riderId] and toasts the
/// outcome of the block/unblock action.
class RiderDetailView extends StatelessWidget {
  const RiderDetailView({super.key, required this.riderId});

  final String riderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RiderDetailCubit(sl<RidersRepo>(), riderId)..load(),
      child: const _RiderDetailBody(),
    );
  }
}

class _RiderDetailBody extends StatefulWidget {
  const _RiderDetailBody();

  @override
  State<_RiderDetailBody> createState() => _RiderDetailBodyState();
}

class _RiderDetailBodyState extends State<_RiderDetailBody> {
  @override
  void initState() {
    super.initState();
    context.read<RiderDetailCubit>().results.listen((r) {
      if (!mounted) return;
      final t = context.tokens;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(r.message),
          backgroundColor: r.isError ? t.danger : t.toastBg,
          behavior: SnackBarBehavior.floating,
        ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RiderDetailCubit>();

    return AdminPage(
      title: 'Rider detail',
      parent: 'Riders',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZButton(
            label: 'Back to riders',
            icon: Icons.arrow_back,
            variant: ZButtonVariant.ghost,
            size: ZButtonSize.small,
            onPressed: () => context.go(AppRoutes.riders),
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocBuilder<RiderDetailCubit, RiderDetailState>(
            builder: (context, state) {
              return switch (state.status) {
                DetailStatus.loading => const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: ZSkeletonList(rows: 6),
                  ),
                DetailStatus.error => SizedBox(
                    height: 320,
                    child: ZErrorState(
                      message: state.error ?? 'Failed to load rider.',
                      onRetry: cubit.load,
                    ),
                  ),
                DetailStatus.ready => _Content(state: state, cubit: cubit),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.cubit});

  final RiderDetailState state;
  final RiderDetailCubit cubit;

  @override
  Widget build(BuildContext context) {
    final rider = state.rider!;
    final left = _ProfileCard(rider: rider);
    final right = Column(
      children: [
        _WalletCard(wallet: state.wallet!),
        const SizedBox(height: AppSpacing.lg),
        _StatsCard(stats: state.stats!),
        const SizedBox(height: AppSpacing.lg),
        _DangerZone(rider: rider, state: state, cubit: cubit),
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 900) {
          return Column(
            children: [left, const SizedBox(height: AppSpacing.lg), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: AppSpacing.lg),
            SizedBox(width: 340, child: right),
          ],
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.rider});
  final RiderModel rider;

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
              DriverAvatar(
                  name: rider.fullName,
                  initials: rider.initials,
                  photoUrl: rider.profilePhoto,
                  size: 54),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rider.fullName, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ZBadge.forStatus(
                            rider.isActive ? 'active' : 'blocked'),
                        const SizedBox(width: AppSpacing.sm),
                        if (rider.isVerified)
                          const ZBadge(
                              label: 'Verified', tone: ZBadgeTone.success)
                        else
                          const ZBadge(
                              label: 'Unverified', tone: ZBadgeTone.neutral),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _row(context, 'Email', rider.email.isEmpty ? '—' : rider.email),
          _row(context, 'Phone', rider.phone.isEmpty ? '—' : rider.phone,
              mono: true),
          _row(
            context,
            'Rating',
            '${rider.rating.toStringAsFixed(1)} · ${rider.totalRatings} ratings',
          ),
          _row(context, 'Joined', _fmt(rider.createdAt)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool mono = false}) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? AppTypography.mono(size: 13, weight: FontWeight.w600)
                      .copyWith(color: t.text)
                  : theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.wallet});
  final RiderWallet wallet;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wallet', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(wallet.balance.toStringAsFixed(2),
                  style: AppTypography.mono(
                      size: 22, weight: FontWeight.w700, color: t.text)),
              const SizedBox(width: AppSpacing.xs),
              Text(wallet.currency,
                  style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final RiderStats stats;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip stats', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _row(context, 'Total trips', '${stats.totalTrips}'),
          _row(context, 'Completed', '${stats.completedTrips}'),
          _row(context, 'Cancelled', '${stats.cancelledTrips}'),
          _row(context, 'Total spent',
              '${stats.totalSpent.toStringAsFixed(2)} EGP'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
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
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({
    required this.rider,
    required this.state,
    required this.cubit,
  });

  final RiderModel rider;
  final RiderDetailState state;
  final RiderDetailCubit cubit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final blocked = !rider.isActive;

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
                ? 'This rider is blocked and cannot request trips. You can '
                    'reinstate them.'
                : "Restrict this rider's access. A reason is required and "
                    'recorded in the audit log.',
            style: theme.textTheme.bodySmall?.copyWith(color: t.text2),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (blocked)
            ZButton(
              label: 'Unblock rider',
              icon: Icons.lock_open_outlined,
              variant: ZButtonVariant.secondary,
              expand: true,
              loading: state.busyBlock,
              onPressed: state.busyBlock ? null : () => _unblock(context),
            )
          else
            ZButton(
              label: 'Block rider',
              icon: Icons.block,
              variant: ZButtonVariant.danger,
              expand: true,
              loading: state.busyBlock,
              onPressed: state.busyBlock ? null : () => _block(context),
            ),
        ],
      ),
    );
  }

  Future<void> _block(BuildContext context) async {
    final reason = await ZReasonDialog.show(
      context,
      icon: Icons.block,
      title: 'Block this rider?',
      body: 'They lose access immediately and cannot request trips. You can '
          'unblock later.',
      confirmLabel: 'Block rider',
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
      title: 'Unblock this rider?',
      body: 'They regain access and can request trips again.',
      confirmLabel: 'Unblock rider',
    );
    if (ok != null) cubit.setBlocked(false);
  }
}
