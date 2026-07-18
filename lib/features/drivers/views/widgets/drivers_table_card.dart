import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/z_badge.dart';
import '../../../../core/widgets/z_empty_state.dart';
import '../../../../core/widgets/z_skeleton.dart';
import '../../../../core/widgets/z_table.dart';
import '../../cubit/drivers_list_cubit.dart';
import '../../data/models/driver_model.dart';
import 'driver_avatar.dart';
import 'driver_filter_tabs.dart';
import 'drivers_pager.dart';
import 'tier_badge.dart';

/// The drivers card: filter tabs + (disabled) search on top, the responsive
/// table, and the pager. Pure layout — all state comes from [DriversListCubit].
class DriversTableCard extends StatelessWidget {
  const DriversTableCard({
    super.key,
    required this.state,
    required this.onSelectFilter,
    required this.onRowTap,
    required this.onPrev,
    required this.onNext,
    required this.onRetry,
  });

  final DriversListState state;
  final ValueChanged<DriverFilter> onSelectFilter;
  final ValueChanged<DriverModel> onRowTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  static const _columns = [
    ZColumn('Driver', minWidth: 220, flex: 3),
    ZColumn('Status', minWidth: 110, flex: 2),
    ZColumn('Rating', minWidth: 90, flex: 1, priority: 2),
    ZColumn('Tier', minWidth: 110, flex: 1, priority: 1),
    ZColumn('Trips', minWidth: 80, flex: 1, priority: 2),
    ZColumn('Vehicle', minWidth: 150, flex: 2, priority: 3),
    ZColumn('Joined', minWidth: 120, flex: 1, priority: 1),
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
            DriversPager(
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
        child: ZErrorState(message: state.error ?? 'Failed to load drivers.',
            onRetry: onRetry),
      );
    }
    if (state.isEmpty) {
      return const SizedBox(
        height: 320,
        child: ZEmptyState(
          title: 'No drivers here',
          message: 'No drivers match this filter.',
          icon: Icons.inbox_outlined,
        ),
      );
    }
    return ZTable(
      columns: _columns,
      onRowTap: (i) => onRowTap(state.drivers[i]),
      rows: [for (final d in state.drivers) _row(context, d)],
    );
  }

  List<Widget> _row(BuildContext context, DriverModel d) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return [
      Row(
        children: [
          DriverAvatar(name: d.fullName, initials: d.initials,
              photoUrl: d.profilePhoto, size: 38),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium),
                Text(d.phone,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.mono(size: 12.5, color: t.text3)),
              ],
            ),
          ),
        ],
      ),
      Align(
          alignment: Alignment.centerLeft,
          child: ZBadge.forStatus(d.status.name)),
      RatingCell(rating: d.rating),
      Align(alignment: Alignment.centerLeft, child: TierBadge(tier: d.tier)),
      Text('${d.totalTrips}', style: AppTypography.mono(size: 13)),
      Text(d.vehicle.display,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
      Text(_joined(d.joinedAt),
          style: theme.textTheme.bodySmall?.copyWith(color: t.text2)),
    ];
  }

  String _joined(DateTime? d) {
    if (d == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

/// Filter tabs + a disabled search field (no backend search endpoint yet).
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.state, required this.onSelectFilter});

  final DriversListState state;
  final ValueChanged<DriverFilter> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DriverFilterTabs(
              current: state.filter,
              countFor: state.countFor,
              onSelect: onSelectFilter,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const _DisabledSearch(),
        ],
      ),
    );
  }
}

class _DisabledSearch extends StatelessWidget {
  const _DisabledSearch();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Tooltip(
      message: 'Search is not available yet — the backend has no driver '
          'search endpoint.',
      child: Opacity(
        opacity: 0.55,
        child: Container(
          width: 200,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: t.searchBg,
            border: Border.all(color: t.border),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 15, color: t.text3),
              const SizedBox(width: AppSpacing.sm),
              Text('Search drivers…',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: t.text3)),
            ],
          ),
        ),
      ),
    );
  }
}
