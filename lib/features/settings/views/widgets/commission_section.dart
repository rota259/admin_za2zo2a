import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_button.dart';
import '../../../../core/widgets/z_card.dart';
import '../../../../core/widgets/z_empty_state.dart';
import '../../../../core/widgets/z_reason_dialog.dart';
import '../../../../core/widgets/z_skeleton.dart';
import '../../cubit/commission_cubit.dart';

/// Commission / platform settings — a single percent field, mirroring the
/// pricing screen's edit-draft-save shape. `GET/PATCH /api/admin/settings`.
class CommissionSection extends StatefulWidget {
  const CommissionSection({super.key});

  @override
  State<CommissionSection> createState() => _CommissionSectionState();
}

class _CommissionSectionState extends State<CommissionSection> {
  final _controller = TextEditingController();
  bool _synced = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CommissionCubit>();
    final t = context.tokens;
    final theme = Theme.of(context);

    return BlocConsumer<CommissionCubit, CommissionState>(
      listener: (context, state) {
        if (state.draft != null && !_synced) {
          _controller.text = state.draft!.commissionRate.toStringAsFixed(1);
          _synced = true;
        }
      },
      builder: (context, state) {
        return switch (state.status) {
          CommissionStatus.loading => const Padding(
              padding: EdgeInsets.only(top: 8),
              child: ZSkeletonList(rows: 3),
            ),
          CommissionStatus.error => SizedBox(
              height: 240,
              child: ZErrorState(
                message: state.error ?? 'Failed to load settings.',
                onRetry: cubit.load,
              ),
            ),
          CommissionStatus.ready => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ZCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commission', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Percent of every trip fare the platform keeps. Applies '
                      'immediately once saved.',
                      style:
                          theme.textTheme.bodySmall?.copyWith(color: t.text2),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      style: theme.textTheme.bodyLarge,
                      cursorColor: t.accent,
                      onChanged: (v) => cubit.setRate(double.tryParse(v) ?? 0),
                      decoration: InputDecoration(
                        suffixText: '%',
                        filled: true,
                        fillColor: t.surface2,
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        enabledBorder: _border(t.border),
                        focusedBorder: _border(t.accent, 1.5),
                        border: _border(t.border),
                      ),
                    ),
                    if (state.validationError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(state.validationError!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: t.danger)),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        if (state.isDirty)
                          ZButton(
                            label: 'Reset',
                            variant: ZButtonVariant.ghost,
                            size: ZButtonSize.small,
                            onPressed: () {
                              cubit.reset();
                              _controller.text =
                                  state.original!.commissionRate.toStringAsFixed(1);
                            },
                          ),
                        const Spacer(),
                        ZButton(
                          label: 'Save',
                          size: ZButtonSize.small,
                          loading: state.saving,
                          onPressed: state.canSave
                              ? () => _confirmSave(context, cubit)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        };
      },
    );
  }

  Future<void> _confirmSave(BuildContext context, CommissionCubit cubit) async {
    final ok = await ZReasonDialog.show(
      context,
      icon: Icons.percent,
      title: 'Update the commission rate?',
      body: 'This changes the platform\'s cut of every trip fare immediately.',
      confirmLabel: 'Save',
    );
    if (ok != null) cubit.save();
  }

  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: c, width: w),
      );
}
