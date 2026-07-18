import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/z_button.dart';
import '../../../injection_container.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/drivers_list_cubit.dart';
import 'widgets/drivers_table_card.dart';

/// Drivers list. Provides its own cubit and loads on first build.
class DriversListView extends StatelessWidget {
  const DriversListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriversListCubit>()..load(),
      child: const _DriversListBody(),
    );
  }
}

class _DriversListBody extends StatelessWidget {
  const _DriversListBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DriversListCubit>();

    return AdminPage(
      title: 'Drivers',
      child: BlocBuilder<DriversListCubit, DriversListState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(total: state.total),
              const SizedBox(height: AppSpacing.xl),
              DriversTableCard(
                state: state,
                onSelectFilter: cubit.selectFilter,
                onRetry: cubit.load,
                onPrev: cubit.prevPage,
                onNext: cubit.nextPage,
                onRowTap: (d) =>
                    context.go(AppRoutes.driverDetailFor(d.id)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Drivers',
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontSize: 26, letterSpacing: -0.65)),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text('$total',
                      style: AppTypography.mono(
                          size: 14, color: t.text, weight: FontWeight.w600)),
                  const SizedBox(width: 5),
                  Text('drivers in this view',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: t.text2, fontSize: 14.5)),
                ],
              ),
            ],
          ),
        ),
        // No driver-invite endpoint exists — inert with an explanation.
        const Tooltip(
          message: 'Inviting drivers is not available yet — no backend '
              'endpoint.',
          child: ZButton(
            label: 'Invite driver',
            icon: Icons.add,
            size: ZButtonSize.small,
          ),
        ),
      ],
    );
  }
}
