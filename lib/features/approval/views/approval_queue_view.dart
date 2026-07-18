import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/z_empty_state.dart';
import '../../../core/widgets/z_skeleton.dart';
import '../../../injection_container.dart';
import '../../shell/cubit/nav_counts_cubit.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/approval_cubit.dart';
import 'widgets/approval_card.dart';

/// Driver approval queue — the drivers with un-approved documents, each with
/// inline review and an "approve driver" action.
class ApprovalQueueView extends StatelessWidget {
  const ApprovalQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ApprovalCubit(sl())..load(),
      child: const _ApprovalBody(),
    );
  }
}

class _ApprovalBody extends StatefulWidget {
  const _ApprovalBody();

  @override
  State<_ApprovalBody> createState() => _ApprovalBodyState();
}

class _ApprovalBodyState extends State<_ApprovalBody> {
  @override
  void initState() {
    super.initState();
    context.read<ApprovalCubit>().results.listen((r) {
      if (!mounted) return;
      final t = context.tokens;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(r.message),
          backgroundColor: r.isError ? t.danger : t.toastBg,
          behavior: SnackBarBehavior.floating,
        ));
      // A queue change moves the sidebar badge — keep it truthful.
      if (!r.isError) context.read<NavCountsCubit>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApprovalCubit>();
    final theme = Theme.of(context);
    final t = context.tokens;

    return AdminPage(
      title: 'Approval Queue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Approval queue',
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontSize: 26, letterSpacing: -0.65)),
          const SizedBox(height: AppSpacing.xs),
          Text('Review documents and activate new drivers.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: t.text2, fontSize: 14.5)),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<ApprovalCubit, ApprovalState>(
            builder: (context, state) {
              return switch (state.status) {
                QueueStatus.loading => const _LoadingCards(),
                QueueStatus.error => SizedBox(
                    height: 300,
                    child: ZErrorState(
                      message: state.error ?? 'Failed to load the queue.',
                      onRetry: cubit.load,
                    ),
                  ),
                QueueStatus.ready when state.isEmpty => const _AllCaughtUp(),
                QueueStatus.ready => Column(
                    children: [
                      for (final d in state.drivers) ...[
                        ApprovalCard(driver: d, state: state, cubit: cubit),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ],
                  ),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.border),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: const ZSkeletonList(rows: 3),
        ),
      ),
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 320,
      child: ZEmptyState(
        title: 'All caught up',
        message: 'No drivers are waiting for approval.',
        icon: Icons.done_all,
      ),
    );
  }
}
