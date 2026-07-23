import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/z_badge.dart';
import '../../../../core/widgets/z_empty_state.dart';
import '../../../../core/widgets/z_filter_tabs.dart';
import '../../../../core/widgets/z_pager.dart';
import '../../../../core/widgets/z_skeleton.dart';
import '../../../../core/widgets/z_table.dart';
import '../../cubit/trips_list_cubit.dart';
import '../../data/models/trip_model.dart';

/// The trips card: status filter tabs, the responsive table, and the pager.
/// Pure layout — all state comes from [TripsListCubit].
class TripsTableCard extends StatelessWidget {
  const TripsTableCard({
    super.key,
    required this.state,
    required this.onSelectFilter,
    required this.onRowTap,
    required this.onPrev,
    required this.onNext,
    required this.onRetry,
  });

  final TripsListState state;
  final ValueChanged<TripFilter> onSelectFilter;
  final ValueChanged<TripModel> onRowTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  static const _columns = [
    ZColumn('Trip', minWidth: 200, flex: 3),
    ZColumn('Status', minWidth: 120, flex: 2),
    ZColumn('Rider', minWidth: 150, flex: 2, priority: 2),
    ZColumn('Driver', minWidth: 150, flex: 2, priority: 2),
    ZColumn('Fare', minWidth: 90, flex: 1, priority: 1),
    ZColumn('Requested', minWidth: 130, flex: 1, priority: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: t.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _Toolbar(state: state, onSelectFilter: onSelectFilter),
          _body(context),
          if (state.status == ListStatus.ready)
            ZPager(
              page: state.page,
              pages: state.pages,
              total: state.total,
              hasPrev: state.hasPrev,
              hasNext: state.hasNext,
              onPrev: onPrev,
              onNext: onNext,
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (state.status == ListStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: ZSkeletonList(rows: 8),
      );
    }
    if (state.status == ListStatus.error) {
      return SizedBox(
        height: 320,
        child: ZErrorState(
            message: state.error ?? 'Failed to load trips.', onRetry: onRetry),
      );
    }
    if (state.isEmpty) {
      return const SizedBox(
        height: 320,
        child: ZEmptyState(
          title: 'No trips here',
          message: 'No trips match this filter.',
          icon: Icons.route_outlined,
        ),
      );
    }
    return ZTable(
      columns: _columns,
      onRowTap: (i) => onRowTap(state.trips[i]),
      rows: [for (final t in state.trips) _row(context, t)],
    );
  }

  List<Widget> _row(BuildContext context, TripModel trip) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trip.origin.address,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium),
          Row(
            children: [
              Icon(Icons.arrow_downward, size: 11, color: t.text3),
              const SizedBox(width: 4),
              Expanded(
                child: Text(trip.destination.address,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: t.text3)),
              ),
            ],
          ),
        ],
      ),
      Align(
          alignment: Alignment.centerLeft,
          child: ZBadge.forStatus(trip.status)),
      Text(trip.rider.fullName,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
      Text(trip.driver?.fullName ?? '—',
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
      Text(trip.fare.total.toStringAsFixed(2),
          style: AppTypography.mono(size: 13, weight: FontWeight.w600)),
      Text(_when(trip.requestedAt),
          style: theme.textTheme.bodySmall?.copyWith(color: t.text2)),
    ];
  }

  String _when(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.state, required this.onSelectFilter});

  final TripsListState state;
  final ValueChanged<TripFilter> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ZFilterTabs<TripFilter>(
          values: TripFilter.values,
          current: state.filter,
          labelFor: (f) => f.label,
          countFor: state.countFor,
          onSelect: onSelectFilter,
        ),
      ),
    );
  }
}
