import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/z_badge.dart';
import '../../../core/widgets/z_empty_state.dart';
import '../../../core/widgets/z_skeleton.dart';
import '../../../injection_container.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/notif_compose_cubit.dart';
import 'widgets/notif_compose_card.dart';
import 'widgets/notif_preview.dart';

/// Notifications — compose and broadcast push notifications, plus the sent
/// history. Both `POST` and `GET /api/admin/notifications` are live.
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotifComposeCubit>()..loadHistory(),
      child: const _NotificationsBody(),
    );
  }
}

class _NotificationsBody extends StatefulWidget {
  const _NotificationsBody();

  @override
  State<_NotificationsBody> createState() => _NotificationsBodyState();
}

class _NotificationsBodyState extends State<_NotificationsBody> {
  final _bodyController = TextEditingController();
  SendStatus _lastToasted = SendStatus.idle;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotifComposeCubit>();
    final theme = Theme.of(context);
    final t = context.tokens;

    return AdminPage(
      title: 'Notifications',
      child: BlocConsumer<NotifComposeCubit, NotifComposeState>(
        listenWhen: (p, c) => p.sendStatus != c.sendStatus,
        listener: (context, state) {
          if (state.sendStatus == _lastToasted) return;
          _lastToasted = state.sendStatus;
          if (state.sendStatus == SendStatus.sent) {
            _bodyController.clear();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: const Text('Notification sent'),
                backgroundColor: t.toastBg,
                behavior: SnackBarBehavior.floating,
              ));
          } else if (state.sendStatus == SendStatus.error) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.sendError ?? 'Failed to send.'),
                backgroundColor: t.danger,
                behavior: SnackBarBehavior.floating,
              ));
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications',
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontSize: 26, letterSpacing: -0.65)),
              const SizedBox(height: AppSpacing.xs),
              Text('Compose and broadcast push notifications.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: t.text2, fontSize: 14.5)),
              const SizedBox(height: AppSpacing.xl),
              LayoutBuilder(
                builder: (context, c) {
                  final compose = NotifComposeCard(
                    state: state,
                    cubit: cubit,
                    bodyController: _bodyController,
                  );
                  final side = _SideColumn(state: state, cubit: cubit);

                  if (c.maxWidth < 900) {
                    return Column(
                      children: [
                        compose,
                        const SizedBox(height: AppSpacing.lg),
                        side,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: compose),
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(width: 360, child: side),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn({required this.state, required this.cubit});

  final NotifComposeState state;
  final NotifComposeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(text.toUpperCase(),
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: t.text3, letterSpacing: 0.5)),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label('Live preview'),
        NotifPreview(state: state),
        const SizedBox(height: AppSpacing.xl),
        label('Recent'),
        _RecentHistory(state: state, cubit: cubit),
      ],
    );
  }
}

class _RecentHistory extends StatelessWidget {
  const _RecentHistory({required this.state, required this.cubit});

  final NotifComposeState state;
  final NotifComposeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    if (state.historyStatus == HistoryStatus.loading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: const ZSkeletonList(rows: 3),
      );
    }
    if (state.historyStatus == HistoryStatus.error) {
      return SizedBox(
        height: 200,
        child: ZErrorState(
          message: state.historyError ?? 'Failed to load history.',
          onRetry: cubit.loadHistory,
        ),
      );
    }
    if (state.history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: const Column(
          children: [
            ZEmptyState(
              title: 'No history yet',
              message: 'Sent notifications will appear here.',
              icon: Icons.history,
            ),
          ],
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
          for (final c in state.history)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: t.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.title,
                            style: theme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis),
                      ),
                      ZBadge(label: c.targetLabel, tone: ZBadgeTone.info),
                    ],
                  ),
                  if (c.body != null && c.body!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(c.body!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: t.text2)),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${c.recipientCount} recipients · ${_when(c.createdAt)}',
                    style:
                        theme.textTheme.labelSmall?.copyWith(color: t.text3),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _when(DateTime? d) {
    if (d == null) return '—';
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}
