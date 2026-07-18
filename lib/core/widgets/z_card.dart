import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';

/// The design's surface primitive: `--surface` fill, 1px `--border`,
/// 16px radius, `--shadow-sm`, `--pad` padding.
class ZCard extends StatelessWidget {
  const ZCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: t.shadowSm,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        hoverColor: t.hover,
        child: content,
      ),
    );
  }
}

/// Section heading used above cards and tables.
class ZSectionHeader extends StatelessWidget {
  const ZSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
