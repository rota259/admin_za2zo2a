import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/z_button.dart';
import '../../cubit/pricing_cubit.dart';

/// The sticky footer bar: dirty / validation status on the left, Reset and
/// "Save & confirm" on the right.
class PricingSaveBar extends StatelessWidget {
  const PricingSaveBar({
    super.key,
    required this.state,
    required this.onReset,
    required this.onSave,
  });

  final PricingState state;
  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: t.shadowMd,
      ),
      child: Row(
        children: [
          Expanded(child: _status(context)),
          const SizedBox(width: AppSpacing.md),
          ZButton(
            label: 'Reset',
            variant: ZButtonVariant.secondary,
            size: ZButtonSize.small,
            onPressed: state.isDirty && !state.saving ? onReset : null,
          ),
          const SizedBox(width: AppSpacing.md),
          ZButton(
            label: 'Save & confirm',
            icon: Icons.verified_user_outlined,
            size: ZButtonSize.small,
            loading: state.saving,
            onPressed: state.canSave ? onSave : null,
          ),
        ],
      ),
    );
  }

  Widget _status(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    final invalid = state.validationError;
    if (invalid != null) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: t.danger),
          const SizedBox(width: 7),
          Flexible(
            child: Text(invalid,
                style: theme.textTheme.bodyMedium?.copyWith(color: t.danger)),
          ),
        ],
      );
    }

    if (state.isDirty) {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: t.warning, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text('Unsaved changes',
              style: theme.textTheme.titleSmall?.copyWith(color: t.warning)),
        ],
      );
    }

    final base = state.original?.baseFare ?? 0;
    return Row(
      children: [
        Text('Live base fare: ',
            style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
        Text('E£${_fmt(base)}',
            style: AppTypography.mono(size: 14, weight: FontWeight.w600)
                .copyWith(color: t.text)),
      ],
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}
