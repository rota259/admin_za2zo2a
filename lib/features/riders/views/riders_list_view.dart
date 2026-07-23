import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../injection_container.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/riders_list_cubit.dart';
import 'widgets/riders_table_card.dart';

/// Riders list. Provides its own cubit and loads on first build.
class RidersListView extends StatelessWidget {
  const RidersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RidersListCubit>()..load(),
      child: const _RidersListBody(),
    );
  }
}

class _RidersListBody extends StatelessWidget {
  const _RidersListBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RidersListCubit>();

    return AdminPage(
      title: 'Riders',
      child: BlocBuilder<RidersListCubit, RidersListState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(total: state.total),
              const SizedBox(height: AppSpacing.xl),
              RidersTableCard(
                state: state,
                onSelectFilter: cubit.selectFilter,
                onRetry: cubit.load,
                onPrev: cubit.prevPage,
                onNext: cubit.nextPage,
                onRowTap: (r) => context.go(AppRoutes.riderDetailFor(r.id)),
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
              Text('Riders',
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontSize: 26, letterSpacing: -0.65)),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text('$total',
                      style: AppTypography.mono(
                          size: 14, color: t.text, weight: FontWeight.w600)),
                  const SizedBox(width: 5),
                  Text('riders in this view',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: t.text2, fontSize: 14.5)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
