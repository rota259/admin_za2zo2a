import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_badge.dart';
import '../../../../core/widgets/z_empty_state.dart';
import '../../../../core/widgets/z_pager.dart';
import '../../../../core/widgets/z_skeleton.dart';
import '../../cubit/audit_cubit.dart';

/// Read-only admin audit log, per §4.4 — every block/approve/document-review/
/// pricing/override/notify/settings/zone mutation is instrumented here on the
/// backend side; the console only reads it.
class AuditSection extends StatelessWidget {
  const AuditSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuditCubit>();
    final t = context.tokens;
    final theme = Theme.of(context);

    return BlocBuilder<AuditCubit, AuditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audit log', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text('Every administrative action, newest first.',
                style: theme.textTheme.bodySmall?.copyWith(color: t.text2)),
            const SizedBox(height: AppSpacing.lg),
            _body(context, state, cubit),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, AuditState state, AuditCubit cubit) {
    final t = context.tokens;
    if (state.status == AuditStatus.loading) {
      return const ZSkeletonList(rows: 6);
    }
    if (state.status == AuditStatus.error) {
      return SizedBox(
        height: 220,
        child: ZErrorState(
            message: state.error ?? 'Failed to load the audit log.',
            onRetry: cubit.load),
      );
    }
    if (state.isEmpty) {
      return const SizedBox(
        height: 220,
        child: ZEmptyState(
          title: 'No activity yet',
          message: 'Admin actions will be recorded here.',
          icon: Icons.receipt_long_outlined,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final e in state.entries)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: t.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZBadge(label: e.type, tone: ZBadgeTone.neutral),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.action, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 3),
                        Text('${e.actorName} · ${_when(e.createdAt)}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: t.text3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ZPager(
            page: state.page,
            pages: state.pages,
            total: state.total,
            hasPrev: state.hasPrev,
            hasNext: state.hasNext,
            onPrev: cubit.prevPage,
            onNext: cubit.nextPage,
          ),
        ],
      ),
    );
  }

  String _when(DateTime? d) {
    if (d == null) return '—';
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
