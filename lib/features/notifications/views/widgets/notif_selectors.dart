import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../cubit/notif_compose_cubit.dart';

/// The audience picker — a grid of target options.
class NotifAudienceGrid extends StatelessWidget {
  const NotifAudienceGrid({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final NotifTarget current;
  final ValueChanged<NotifTarget> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth < 380 ? 1 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: NotifTarget.values.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            mainAxisExtent: 56,
          ),
          itemBuilder: (context, i) {
            final target = NotifTarget.values[i];
            return _AudienceTile(
              target: target,
              selected: target == current,
              onTap: () => onSelect(target),
            );
          },
        );
      },
    );
  }
}

class _AudienceTile extends StatelessWidget {
  const _AudienceTile({
    required this.target,
    required this.selected,
    required this.onTap,
  });

  final NotifTarget target;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Material(
      color: selected ? t.accentSoft : t.surface2,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
                color: selected ? t.accent : Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(target.icon,
                  size: 18, color: selected ? t.accentText : t.text2),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  target.label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: selected ? t.accentText : t.text,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The notification-type segmented control (Info / Promo / Warning).
class NotifTypeSegments extends StatelessWidget {
  const NotifTypeSegments({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final NotifKind current;
  final ValueChanged<NotifKind> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final kind in NotifKind.values)
            InkWell(
              onTap: () => onSelect(kind),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                color: kind == current ? t.accent : Colors.transparent,
                child: Text(
                  kind.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: kind == current ? Colors.white : t.text2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
