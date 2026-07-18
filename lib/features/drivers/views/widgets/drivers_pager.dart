import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';

/// Prev / next pager with a "Page X of Y · N total" readout. Hidden when there
/// is only one page.
class DriversPager extends StatelessWidget {
  const DriversPager({
    super.key,
    required this.page,
    required this.pages,
    required this.total,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
  });

  final int page;
  final int pages;
  final int total;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (pages <= 1) return const SizedBox.shrink();
    final t = context.tokens;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Text(
            'Page $page of $pages · $total total',
            style: theme.textTheme.bodySmall?.copyWith(color: t.text3),
          ),
          const Spacer(),
          _PageButton(
            icon: Icons.chevron_left,
            enabled: hasPrev,
            onTap: onPrev,
          ),
          const SizedBox(width: AppSpacing.sm),
          _PageButton(
            icon: Icons.chevron_right,
            enabled: hasNext,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          hoverColor: t.hover,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, size: AppSizes.iconMd, color: t.text2),
          ),
        ),
      ),
    );
  }
}
