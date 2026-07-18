import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';

/// Inline failure message above the form — carries the backend's own text
/// ("Invalid credentials", "Access denied — admin only", rate-limit notice).
class LoginErrorBanner extends StatelessWidget {
  const LoginErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: t.danger.withValues(alpha: 0.1),
        border: Border.all(color: t.danger.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: AppSizes.iconSm, color: t.danger),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: t.danger),
            ),
          ),
        ],
      ),
    );
  }
}
