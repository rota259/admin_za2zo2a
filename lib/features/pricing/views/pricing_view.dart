import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/z_empty_state.dart';
import '../../../core/widgets/z_reason_dialog.dart';
import '../../../core/widgets/z_skeleton.dart';
import '../../../injection_container.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/pricing_cubit.dart';
import 'widgets/pricing_core_fares.dart';
import 'widgets/pricing_save_bar.dart';
import 'widgets/pricing_tier_editor.dart';
import 'widgets/pricing_warning.dart';

/// Pricing control — edit the platform fares. Every save is confirmed first
/// (it applies live to the rider and driver apps).
class PricingView extends StatelessWidget {
  const PricingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PricingCubit(sl())..load(),
      child: const _PricingBody(),
    );
  }
}

class _PricingBody extends StatefulWidget {
  const _PricingBody();

  @override
  State<_PricingBody> createState() => _PricingBodyState();
}

class _PricingBodyState extends State<_PricingBody> {
  @override
  void initState() {
    super.initState();
    context.read<PricingCubit>().results.listen((r) {
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
    final cubit = context.read<PricingCubit>();
    final theme = Theme.of(context);
    final t = context.tokens;

    return AdminPage(
      title: 'Pricing',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pricing control',
                style: theme.textTheme.displaySmall
                    ?.copyWith(fontSize: 26, letterSpacing: -0.65)),
            const SizedBox(height: AppSpacing.xs),
            Text('Fares that apply to every trip in production.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: t.text2, fontSize: 14.5)),
            const SizedBox(height: AppSpacing.lg),
            BlocBuilder<PricingCubit, PricingState>(
              builder: (context, state) {
                return switch (state.status) {
                  PricingStatus.loading => const _Loading(),
                  PricingStatus.error => SizedBox(
                      height: 280,
                      child: ZErrorState(
                        message: state.error ?? 'Failed to load pricing.',
                        onRetry: cubit.load,
                      ),
                    ),
                  PricingStatus.ready => _Editor(state: state, cubit: cubit),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.state, required this.cubit});

  final PricingState state;
  final PricingCubit cubit;

  @override
  Widget build(BuildContext context) {
    final d = state.draft!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PricingWarning(),
        const SizedBox(height: AppSpacing.lg),
        PricingCoreFares(config: d, cubit: cubit),
        const SizedBox(height: AppSpacing.lg),
        PricingTierEditor(tiers: d.perKmTiers, cubit: cubit),
        const SizedBox(height: AppSpacing.lg),
        PricingSaveBar(
          state: state,
          onReset: cubit.reset,
          onSave: () => _confirmSave(context),
        ),
      ],
    );
  }

  Future<void> _confirmSave(BuildContext context) async {
    final ok = await ZReasonDialog.show(
      context,
      icon: Icons.verified_user_outlined,
      title: 'Apply these fares live?',
      body: 'This updates pricing immediately for every rider and driver on '
          'the platform. Make sure the values are right.',
      confirmLabel: 'Apply live',
    );
    if (ok != null) cubit.save();
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 8),
        child: ZSkeletonList(rows: 6),
      );
}
