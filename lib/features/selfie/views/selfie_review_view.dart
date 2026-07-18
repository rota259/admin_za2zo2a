import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/z_empty_state.dart';
import '../../../core/widgets/z_skeleton.dart';
import '../../../injection_container.dart';
import '../../shell/cubit/nav_counts_cubit.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/selfie_cubit.dart';
import 'widgets/selfie_card.dart';

/// Selfie verification review — compare each pending selfie against the
/// driver's profile photo and approve or reject.
class SelfieReviewView extends StatelessWidget {
  const SelfieReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SelfieCubit(sl())..load(),
      child: const _SelfieBody(),
    );
  }
}

class _SelfieBody extends StatefulWidget {
  const _SelfieBody();

  @override
  State<_SelfieBody> createState() => _SelfieBodyState();
}

class _SelfieBodyState extends State<_SelfieBody> {
  @override
  void initState() {
    super.initState();
    context.read<SelfieCubit>().results.listen((r) {
      if (!mounted) return;
      final t = context.tokens;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(r.message),
          backgroundColor: r.isError ? t.danger : t.toastBg,
          behavior: SnackBarBehavior.floating,
        ));
      if (!r.isError) context.read<NavCountsCubit>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SelfieCubit>();
    final theme = Theme.of(context);
    final t = context.tokens;

    return AdminPage(
      title: 'Selfie Review',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selfie verification',
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontSize: 26, letterSpacing: -0.65)),
          const SizedBox(height: AppSpacing.xs),
          Text("Compare each periodic selfie against the driver's profile "
              'photo.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: t.text2, fontSize: 14.5)),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<SelfieCubit, SelfieState>(
            builder: (context, state) {
              return switch (state.status) {
                SelfieStatus.loading => const _LoadingGrid(),
                SelfieStatus.error => SizedBox(
                    height: 300,
                    child: ZErrorState(
                      message: state.error ?? 'Failed to load selfies.',
                      onRetry: cubit.load,
                    ),
                  ),
                SelfieStatus.ready when state.isEmpty => const _NoPending(),
                SelfieStatus.ready => _Grid(state: state, cubit: cubit),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.state, required this.cubit});

  final SelfieState state;
  final SelfieCubit cubit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth < 560 ? 1 : (c.maxWidth < 900 ? 2 : 3);
        // The card's square photos make its height scale with the cell width,
        // so derive the row extent from the photo size rather than fixing it.
        final cellWidth =
            (c.maxWidth - AppSpacing.lg * (cols - 1)) / cols;
        final photoWidth = (cellWidth - AppSpacing.cardPad * 2 - AppSpacing.sm) / 2;
        // header + photo (square) + label + buttons + padding, with a buffer.
        final extent = photoWidth + 168;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.checks.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            mainAxisExtent: extent,
          ),
          itemBuilder: (context, i) {
            final check = state.checks[i];
            return SelfieCard(
              check: check,
              busy: state.busyId == check.id,
              anyBusy: state.busyId != null,
              cubit: cubit,
            );
          },
        );
      },
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 8),
        child: ZSkeletonList(rows: 4),
      );
}

class _NoPending extends StatelessWidget {
  const _NoPending();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 320,
        child: ZEmptyState(
          title: 'No pending checks',
          message: 'Every selfie verification has been reviewed.',
          icon: Icons.face_retouching_natural_outlined,
        ),
      );
}
