import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_badge.dart';
import '../../../../core/widgets/z_button.dart';
import '../../../../core/widgets/z_card.dart';
import '../../../../core/widgets/z_empty_state.dart';
import '../../../../core/widgets/z_filter_tabs.dart';
import '../../../../core/widgets/z_skeleton.dart';
import '../../cubit/support_tickets_cubit.dart';
import '../../data/models/support_ticket.dart';

/// Support tickets — admin-facing read + triage. `GET/PATCH
/// /api/admin/support-tickets`, `POST .../replies`. Ticket creation is a
/// rider/driver-app concern, out of scope here.
class SupportTicketsSection extends StatelessWidget {
  const SupportTicketsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SupportTicketsCubit>();
    final theme = Theme.of(context);

    return BlocBuilder<SupportTicketsCubit, SupportTicketsState>(
      builder: (context, state) {
        if (state.selected != null) {
          return _TicketDetail(state: state, cubit: cubit);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Support tickets', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ZFilterTabs<TicketFilter>(
              values: TicketFilter.values,
              current: state.filter,
              labelFor: (f) => f.label,
              countFor: (_) => 0,
              showCount: false,
              onSelect: cubit.selectFilter,
            ),
            const SizedBox(height: AppSpacing.lg),
            _list(context, state, cubit),
          ],
        );
      },
    );
  }

  Widget _list(
      BuildContext context, SupportTicketsState state, SupportTicketsCubit cubit) {
    if (state.status == TicketsStatus.loading) {
      return const ZSkeletonList(rows: 5);
    }
    if (state.status == TicketsStatus.error) {
      return SizedBox(
        height: 220,
        child: ZErrorState(
            message: state.error ?? 'Failed to load tickets.',
            onRetry: cubit.load),
      );
    }
    if (state.isEmpty) {
      return const SizedBox(
        height: 220,
        child: ZEmptyState(
          title: 'No tickets',
          message: 'Nothing matches this filter.',
          icon: Icons.support_agent_outlined,
        ),
      );
    }
    return Column(
      children: [
        for (final ticket in state.tickets)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _TicketRow(ticket: ticket, onTap: () => cubit.open(ticket)),
          ),
      ],
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket, required this.onTap});
  final SupportTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return ZCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.subject, style: theme.textTheme.titleMedium),
                const SizedBox(height: 3),
                Text('${ticket.userName} · ${ticket.userRole}',
                    style: theme.textTheme.bodySmall?.copyWith(color: t.text2)),
              ],
            ),
          ),
          ZBadge.forStatus(ticket.priority == 'high' ? 'pending_review' : ticket.status),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right, color: t.text3, size: 18),
        ],
      ),
    );
  }
}

class _TicketDetail extends StatefulWidget {
  const _TicketDetail({required this.state, required this.cubit});
  final SupportTicketsState state;
  final SupportTicketsCubit cubit;

  @override
  State<_TicketDetail> createState() => _TicketDetailState();
}

class _TicketDetailState extends State<_TicketDetail> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final ticket = widget.state.selected!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZButton(
          label: 'Back to tickets',
          icon: Icons.arrow_back,
          variant: ZButtonVariant.ghost,
          size: ZButtonSize.small,
          onPressed: widget.cubit.closeDetail,
        ),
        const SizedBox(height: AppSpacing.md),
        ZCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(ticket.subject,
                        style: theme.textTheme.titleLarge),
                  ),
                  ZBadge.forStatus(ticket.status),
                ],
              ),
              const SizedBox(height: 4),
              Text('${ticket.userName} · ${ticket.userRole}',
                  style: theme.textTheme.bodySmall?.copyWith(color: t.text2)),
              if (ticket.message != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: t.surface2,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(ticket.message!, style: theme.textTheme.bodyMedium),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final s in ['open', 'pending', 'closed'])
                    if (s != ticket.status)
                      ZButton(
                        label: 'Mark ${s}',
                        variant: ZButtonVariant.secondary,
                        size: ZButtonSize.small,
                        loading: widget.state.busy,
                        onPressed: widget.state.busy
                            ? null
                            : () => widget.cubit.updateStatus(s),
                      ),
                ],
              ),
              if (ticket.replies.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Replies', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                for (final r in ticket.replies)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: t.surface2,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.body, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(r.byName ?? 'Admin',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: t.text3)),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _replyController,
                minLines: 2,
                maxLines: 4,
                style: theme.textTheme.bodyMedium,
                cursorColor: t.accent,
                decoration: InputDecoration(
                  hintText: 'Write a reply…',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(color: t.text3),
                  filled: true,
                  fillColor: t.surface2,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide(color: t.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide(color: t.accent, width: 1.5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: ZButton(
                  label: 'Send reply',
                  icon: Icons.send,
                  size: ZButtonSize.small,
                  loading: widget.state.busy,
                  onPressed: widget.state.busy
                      ? null
                      : () {
                          widget.cubit.reply(_replyController.text);
                          _replyController.clear();
                        },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
