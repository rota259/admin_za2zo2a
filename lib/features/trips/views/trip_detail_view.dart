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
import '../../../core/widgets/z_skeleton.dart';
import '../../../injection_container.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/trip_detail_cubit.dart';
import '../data/models/trip_model.dart';
import '../data/repos/trips_repo.dart';

/// Trip detail. Owns a [TripDetailCubit] scoped to [tripId] — full detail,
/// not owner-scoped. Read-only: no fare-override endpoint exists yet.
class TripDetailView extends StatelessWidget {
  const TripDetailView({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripDetailCubit(sl<TripsRepo>(), tripId)..load(),
      child: const _TripDetailBody(),
    );
  }
}

class _TripDetailBody extends StatelessWidget {
  const _TripDetailBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TripDetailCubit>();

    return AdminPage(
      title: 'Trip detail',
      parent: 'Trips',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZButton(
            label: 'Back to trips',
            icon: Icons.arrow_back,
            variant: ZButtonVariant.ghost,
            size: ZButtonSize.small,
            onPressed: () => context.go(AppRoutes.trips),
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocBuilder<TripDetailCubit, TripDetailState>(
            builder: (context, state) {
              return switch (state.status) {
                DetailStatus.loading => const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: ZSkeletonList(rows: 6),
                  ),
                DetailStatus.error => SizedBox(
                    height: 320,
                    child: ZErrorState(
                      message: state.error ?? 'Failed to load trip.',
                      onRetry: cubit.load,
                    ),
                  ),
                DetailStatus.ready => _Content(state: state),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final TripDetailState state;

  @override
  Widget build(BuildContext context) {
    final trip = state.trip!;
    final left = Column(
      children: [
        _RouteCard(trip: trip),
        const SizedBox(height: AppSpacing.lg),
        _PeopleCard(trip: trip),
        const SizedBox(height: AppSpacing.lg),
        _FareCard(trip: trip),
      ],
    );
    final right = _TimelineCard(trip: trip);

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
            SizedBox(width: 320, child: right),
          ],
        );
      },
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.trip});
  final TripModel trip;

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
              Text('Trip route', style: theme.textTheme.titleLarge),
              const Spacer(),
              ZBadge.forStatus(trip.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _point(context, Icons.trip_origin, 'Pickup', trip.origin.address),
          const SizedBox(height: AppSpacing.sm),
          _point(context, Icons.location_on, 'Drop-off',
              trip.destination.address),
          if (trip.distanceKm != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '${trip.distanceKm!.toStringAsFixed(1)} km'
              '${trip.estimatedDurationMin != null ? ' · ~${trip.estimatedDurationMin} min' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(color: t.text3),
            ),
          ],
          if (trip.status == 'cancelled' && trip.cancellationReason != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: t.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                'Cancelled${trip.cancelledBy != null ? ' by ${trip.cancelledBy}' : ''}: '
                '${trip.cancellationReason}',
                style: theme.textTheme.bodySmall?.copyWith(color: t.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _point(
      BuildContext context, IconData icon, String label, String address) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: t.text3),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 70,
          child: Text(label,
              style: theme.textTheme.bodySmall?.copyWith(color: t.text3)),
        ),
        Expanded(
          child: Text(address, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _PeopleCard extends StatelessWidget {
  const _PeopleCard({required this.trip});
  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('People', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _personRow(context, 'Rider', trip.rider, trip.riderRating),
          const SizedBox(height: AppSpacing.md),
          if (trip.driver != null)
            _personRow(context, 'Driver', trip.driver!, trip.driverRating)
          else
            _unassignedRow(context),
        ],
      ),
    );
  }

  Widget _personRow(
      BuildContext context, String role, TripPerson p, num? rating) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(role,
              style: theme.textTheme.bodySmall?.copyWith(color: t.text3)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.fullName, style: theme.textTheme.titleMedium),
              Text(p.phone,
                  style: AppTypography.mono(size: 12.5, color: t.text3)),
            ],
          ),
        ),
        if (rating != null)
          Row(
            children: [
              Icon(Icons.star_rounded, size: 15, color: t.warning),
              const SizedBox(width: 3),
              Text(rating.toStringAsFixed(1),
                  style: AppTypography.mono(size: 13)),
            ],
          ),
      ],
    );
  }

  Widget _unassignedRow(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text('Driver',
              style: theme.textTheme.bodySmall?.copyWith(color: t.text3)),
        ),
        Text('Not yet assigned',
            style: theme.textTheme.bodyMedium?.copyWith(color: t.text3)),
      ],
    );
  }
}

class _FareCard extends StatelessWidget {
  const _FareCard({required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final fare = trip.fare;

    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Fare', style: theme.textTheme.titleLarge),
              const Spacer(),
              Text('${fare.total.toStringAsFixed(2)} EGP',
                  style: AppTypography.mono(
                      size: 18, weight: FontWeight.w700, color: t.text)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (fare.baseFare != null) _row(context, 'Base fare', fare.baseFare!),
          if (fare.distanceFare != null)
            _row(context, 'Distance fare', fare.distanceFare!),
          if (fare.timeFare != null) _row(context, 'Time fare', fare.timeFare!),
          if (fare.bookingFee != null)
            _row(context, 'Booking fee', fare.bookingFee!),
          if (fare.discount != null && fare.discount != 0)
            _row(context, 'Discount', -fare.discount!),
          if (fare.surgeMultiplier != null && fare.surgeMultiplier != 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Surge',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: t.text2)),
                  ),
                  Text('×${fare.surgeMultiplier!.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          if (trip.payment != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text('Payment',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: t.text2)),
                ),
                ZBadge.forStatus(trip.payment!.status),
                const SizedBox(width: AppSpacing.sm),
                Text(trip.payment!.method, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
          if (trip.fareOverride != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: t.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                'Overridden: ${trip.fareOverride!.previousTotal.toStringAsFixed(2)} → '
                '${trip.fareOverride!.newTotal.toStringAsFixed(2)} EGP — '
                '${trip.fareOverride!.reason}',
                style: theme.textTheme.bodySmall?.copyWith(color: t.warning),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, double value) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
          ),
          Text(value.toStringAsFixed(2), style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.trip});
  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Timeline', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _entry(context, 'Requested', trip.requestedAt),
          _entry(context, 'Accepted', trip.acceptedAt),
          _entry(context, 'Started', trip.startedAt),
          _entry(context, 'Completed', trip.completedAt),
          _entry(context, 'Cancelled', trip.cancelledAt),
        ],
      ),
    );
  }

  Widget _entry(BuildContext context, String label, DateTime? at) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final done = at != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.circle_outlined,
            size: 15,
            color: done ? t.greenText : t.text3,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: done ? t.text : t.text3)),
          ),
          Text(
            done ? _fmt(at) : '—',
            style: theme.textTheme.bodySmall?.copyWith(color: t.text3),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
