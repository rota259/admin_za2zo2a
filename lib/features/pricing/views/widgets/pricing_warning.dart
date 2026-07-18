import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';

/// The amber "these changes apply live" banner above the pricing form.
class PricingWarning extends StatelessWidget {
  const PricingWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: t.warning.withValues(alpha: 0.1),
        border: Border.all(color: t.warning.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: t.warning),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: t.text2, height: 1.5),
                children: [
                  TextSpan(
                    text: 'These changes apply live. ',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: t.text, height: 1.5),
                  ),
                  const TextSpan(
                    text: 'Any edit you confirm updates fares instantly for '
                        'all riders and drivers. Changes are recorded in the '
                        'audit log.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
