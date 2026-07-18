import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';

/// A single nav row.
///
/// Active state is the design's: solid `--accent` fill, white label, and a
/// crimson glow (`0 6px 16px -8px rgba(232,25,75,.6)`) — not a soft tint.
///
/// A null [onTap] renders the item dimmed and inert — used for sections whose
/// backend endpoints don't exist yet, so nothing links to a fake screen.
class SidebarNavTile extends StatefulWidget {
  const SidebarNavTile({
    super.key,
    required this.item,
    required this.collapsed,
    required this.selected,
    this.badge = 0,
    this.onTap,
  });

  final NavItem item;
  final bool collapsed;
  final bool selected;

  /// Live count. Zero hides the badge, matching the design's falsy check.
  final int badge;
  final VoidCallback? onTap;

  @override
  State<SidebarNavTile> createState() => _SidebarNavTileState();
}

class _SidebarNavTileState extends State<SidebarNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final disabled = widget.onTap == null;
    final active = widget.selected;

    final fg = disabled
        ? t.text3
        : active
            ? Colors.white
            : t.text2;

    final background = active
        ? t.accent
        : (_hovered && !disabled ? t.hover : Colors.transparent);

    // One shared duration/curve so the pill's background, glow, icon tint and
    // label weight all ease together on selection instead of snapping.
    const animDuration = Duration(milliseconds: 220);
    const animCurve = Curves.easeOut;

    Widget tile = AnimatedContainer(
      duration: animDuration,
      curve: animCurve,
      padding: EdgeInsets.symmetric(
        horizontal: widget.collapsed ? 0 : 11,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
        boxShadow: active
            ? [
                BoxShadow(
                  color: t.accent.withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: -8,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: widget.collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          TweenAnimationBuilder<Color?>(
            duration: animDuration,
            curve: animCurve,
            tween: ColorTween(end: fg),
            builder: (context, color, _) =>
                Icon(widget.item.icon, size: 19, color: color),
          ),
          if (!widget.collapsed) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: animDuration,
                curve: animCurve,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: fg,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  widget.item.label,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ),
            if (disabled)
              Icon(Icons.lock_outline, size: 13, color: t.text3)
            else if (widget.badge > 0)
              _NavBadge(count: widget.badge, active: active),
          ],
        ],
      ),
    );

    if (disabled) tile = Opacity(opacity: 0.55, child: tile);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Tooltip(
        message: disabled
            ? '${widget.item.label} — no backend endpoint yet'
            : (widget.collapsed
                ? '${widget.item.label}${widget.badge > 0 ? ' (${widget.badge})' : ''}'
                : ''),
        waitDuration: const Duration(milliseconds: 400),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor:
              disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: tile,
          ),
        ),
      ),
    );
  }
}

/// Count pill. Inverts to translucent-white on an active (crimson) row.
class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.count, required this.active});

  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? Colors.white.withValues(alpha: 0.22) : t.accentSoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: active ? Colors.white : t.accentText,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
      ),
    );
  }
}
