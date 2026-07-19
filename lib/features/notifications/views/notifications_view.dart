import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/notif_compose_cubit.dart';
import 'widgets/notif_compose_card.dart';
import 'widgets/notif_preview.dart';

/// Notifications — compose and (once wired) broadcast push notifications.
///
/// The compose form is fully live; sending and the "Recent" history are
/// present-but-inert until the backend exposes send + history endpoints (see
/// docs/integration-spec.md).
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotifComposeCubit(),
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
      child: Column(
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
          BlocBuilder<NotifComposeCubit, NotifComposeState>(
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, c) {
                  final compose = NotifComposeCard(
                    state: state,
                    cubit: cubit,
                    bodyController: _bodyController,
                  );
                  final side = _SideColumn(state: state);

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
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn({required this.state});

  final NotifComposeState state;

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
        _RecentPlaceholder(),
      ],
    );
  }
}

/// The sent-history list is pending its backend endpoint — an honest empty
/// slot rather than fabricated rows.
class _RecentPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 22, color: t.text3),
          const SizedBox(height: AppSpacing.sm),
          Text('No history yet',
              style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            'Sent notifications will appear here once the send/history '
            'endpoints are wired.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: t.text3),
          ),
        ],
      ),
    );
  }
}
