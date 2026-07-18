import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/z_button.dart';
import '../../../core/widgets/z_empty_state.dart';
import '../../../core/widgets/z_skeleton.dart';
import '../../../injection_container.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/driver_detail_cubit.dart';
import '../data/repos/drivers_repo.dart';
import 'widgets/driver_documents_card.dart';
import 'widgets/driver_profile_card.dart';
import 'widgets/driver_side_cards.dart';

/// Driver detail. Owns a [DriverDetailCubit] scoped to [driverId] and toasts
/// the outcome of each review action.
class DriverDetailView extends StatelessWidget {
  const DriverDetailView({super.key, required this.driverId});

  final String driverId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverDetailCubit(sl<DriversRepo>(), driverId)..load(),
      child: const _DriverDetailBody(),
    );
  }
}

class _DriverDetailBody extends StatefulWidget {
  const _DriverDetailBody();

  @override
  State<_DriverDetailBody> createState() => _DriverDetailBodyState();
}

class _DriverDetailBodyState extends State<_DriverDetailBody> {
  @override
  void initState() {
    super.initState();
    // Toast every completed action once.
    context.read<DriverDetailCubit>().results.listen((r) {
      if (!mounted) return;
      final t = context.tokens;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(r.message),
          backgroundColor: r.isError ? t.danger : t.toastBg,
          behavior: SnackBarBehavior.floating,
        ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DriverDetailCubit>();

    return AdminPage(
      title: 'Driver detail',
      parent: 'Drivers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZButton(
            label: 'Back to drivers',
            icon: Icons.arrow_back,
            variant: ZButtonVariant.ghost,
            size: ZButtonSize.small,
            onPressed: () => context.go(AppRoutes.drivers),
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocBuilder<DriverDetailCubit, DriverDetailState>(
            builder: (context, state) {
              return switch (state.status) {
                DetailStatus.loading => const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: ZSkeletonList(rows: 6),
                  ),
                DetailStatus.error => SizedBox(
                    height: 320,
                    child: ZErrorState(
                      message: state.error ?? 'Failed to load driver.',
                      onRetry: cubit.load,
                    ),
                  ),
                DetailStatus.ready =>
                  _Content(state: state, cubit: cubit),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.cubit});

  final DriverDetailState state;
  final DriverDetailCubit cubit;

  @override
  Widget build(BuildContext context) {
    final driver = state.driver!;

    final left = Column(
      children: [
        DriverProfileCard(driver: driver),
        const SizedBox(height: AppSpacing.lg),
        DriverDocumentsCard(driver: driver, state: state, cubit: cubit),
      ],
    );
    final right =
        DriverSideCards(driver: driver, state: state, cubit: cubit);

    return LayoutBuilder(
      builder: (context, c) {
        // Stack the side column under the main content on narrow widths.
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
            SizedBox(width: 340, child: right),
          ],
        );
      },
    );
  }
}
