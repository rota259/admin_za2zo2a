import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';
import 'z_button.dart';

/// The design's empty state — soft accent icon tile, title, subtitle.
/// (See the "All caught up" panel on the approval queue.)
class ZEmptyState extends StatelessWidget {
  const ZEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.check,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: t.accentSoft,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Icon(icon, color: t.accent, size: 26),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: theme.textTheme.headlineSmall),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: t.text2),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ZButton(
                label: actionLabel!,
                onPressed: onAction,
                size: ZButtonSize.small,
                variant: ZButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Failure state with retry. Pairs with [ApiError] from the network layer.
class ZErrorState extends StatelessWidget {
  const ZErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: t.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: t.danger, size: 26),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Something went wrong', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: t.text2),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ZButton(
                label: 'Try again',
                onPressed: onRetry,
                size: ZButtonSize.small,
                variant: ZButtonVariant.secondary,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
