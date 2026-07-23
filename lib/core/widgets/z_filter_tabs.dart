import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';

/// Generic labelled-count filter row, shared across the drivers/riders/trips
/// list toolbars.
class ZFilterTabs<T> extends StatelessWidget {
  const ZFilterTabs({
    super.key,
    required this.values,
    required this.current,
    required this.labelFor,
    required this.countFor,
    required this.onSelect,
    this.showCount = true,
  });

  final List<T> values;
  final T current;
  final String Function(T) labelFor;
  final int Function(T) countFor;
  final ValueChanged<T> onSelect;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final v in values)
          _Tab(
            label: labelFor(v),
            count: showCount ? countFor(v) : null,
            selected: v == current,
            onTap: () => onSelect(v),
          ),
      ],
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final selected = widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? t.accentSoft
                : (_hovered ? t.hover : Colors.transparent),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: selected ? t.accentText : t.text2,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              if (widget.count != null) ...[
                const SizedBox(width: 6),
                Text(
                  '${widget.count}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: selected ? t.accentText : t.text3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
