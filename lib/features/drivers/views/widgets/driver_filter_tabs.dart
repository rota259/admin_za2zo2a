import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../cubit/drivers_list_cubit.dart';

/// The All / Pending / Approved / Blocked filter row, each with its live count.
class DriverFilterTabs extends StatelessWidget {
  const DriverFilterTabs({
    super.key,
    required this.current,
    required this.countFor,
    required this.onSelect,
  });

  final DriverFilter current;
  final int Function(DriverFilter) countFor;
  final ValueChanged<DriverFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final f in DriverFilter.values)
          _Tab(
            label: f.label,
            count: countFor(f),
            selected: f == current,
            onTap: () => onSelect(f),
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
  final int count;
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
              const SizedBox(width: 6),
              Text(
                '${widget.count}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? t.accentText : t.text3,
                  fontFeatures: const [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
