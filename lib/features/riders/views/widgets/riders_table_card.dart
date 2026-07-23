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
import '../../../drivers/views/widgets/driver_avatar.dart';
import '../../cubit/riders_list_cubit.dart';
import '../../data/models/rider_model.dart';

/// The riders card: filter tabs + (disabled) search on top, the responsive
/// table, and the pager. Pure layout — all state comes from [RidersListCubit].
class RidersTableCard extends StatelessWidget {
  const RidersTableCard({
    super.key,
    required this.state,
    required this.onSelectFilter,
    required this.onRowTap,
    required this.onPrev,
    required this.onNext,
    required this.onRetry,
  });

  final RidersListState state;
  final ValueChanged<RiderFilter> onSelectFilter;
  final ValueChanged<RiderModel> onRowTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  static const _columns = [
    ZColumn('Rider', minWidth: 220, flex: 3),
    ZColumn('Status', minWidth: 110, flex: 2),
    ZColumn('Rating', minWidth: 90, flex: 1, priority: 2),
    ZColumn('Verified', minWidth: 100, flex: 1, priority: 1),
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
            message: state.error ?? 'Failed to load riders.',
            onRetry: onRetry),
      );
    }
    if (state.isEmpty) {
      return const SizedBox(
        height: 320,
        child: ZEmptyState(
          title: 'No riders here',
          message: 'No riders match this filter.',
          icon: Icons.inbox_outlined,
        ),
      );
    }
    return ZTable(
      columns: _columns,
      onRowTap: (i) => onRowTap(state.riders[i]),
      rows: [for (final r in state.riders) _row(context, r)],
    );
  }

  List<Widget> _row(BuildContext context, RiderModel r) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return [
      Row(
        children: [
          DriverAvatar(name: r.fullName, initials: r.initials,
              photoUrl: r.profilePhoto, size: 38),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(r.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium),
                Text(r.phone,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.mono(size: 12.5, color: t.text3)),
              ],
            ),
          ),
        ],
      ),
      Align(
          alignment: Alignment.centerLeft,
          child: ZBadge.forStatus(r.isActive ? 'active' : 'blocked')),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 15, color: t.warning),
          const SizedBox(width: 3),
          Text(r.rating.toStringAsFixed(1),
              style: AppTypography.mono(size: 13, weight: FontWeight.w600)),
        ],
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: r.isVerified
            ? const ZBadge(label: 'Verified', tone: ZBadgeTone.success)
            : ZBadge(label: 'Unverified', tone: ZBadgeTone.neutral),
      ),
      Text(_joined(r.createdAt),
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

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.state, required this.onSelectFilter});

  final RidersListState state;
  final ValueChanged<RiderFilter> onSelectFilter;

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
            child: ZFilterTabs<RiderFilter>(
              values: RiderFilter.values,
              current: state.filter,
              labelFor: (f) => f.label,
              countFor: state.countFor,
              onSelect: onSelectFilter,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _DisabledSearch(t: t),
        ],
      ),
    );
  }
}

class _DisabledSearch extends StatelessWidget {
  const _DisabledSearch({required this.t});
  final AppTokens t;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Search is not available yet — the backend has no rider '
          'search endpoint (query params exist per the spec but aren\'t '
          'wired to a UI field yet).',
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
              Text('Search riders…',
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
