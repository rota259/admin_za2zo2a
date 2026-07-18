import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

/// The top bar's 40×40 bordered icon button (radius 11), per the design —
/// used by the theme toggle and the notification bell.
///
/// [unreadDot] paints the design's 7×7 accent dot with a 2px surface ring.
class TopBarIconButton extends StatefulWidget {
  const TopBarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.unreadDot = false,
  });

  final IconData icon;
  final String tooltip;

  /// Null renders the button dimmed and inert.
  final VoidCallback? onTap;
  final bool unreadDot;

  @override
  State<TopBarIconButton> createState() => _TopBarIconButtonState();
}

class _TopBarIconButtonState extends State<TopBarIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final disabled = widget.onTap == null;

    return Tooltip(
      message: widget.tooltip,
      child: Opacity(
        opacity: disabled ? 0.6 : 1,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor:
              disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _hovered && !disabled ? t.hover : Colors.transparent,
                border: Border.all(color: t.border),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(widget.icon, size: 18, color: t.text2)),
                  if (widget.unreadDot)
                    Positioned(
                      top: 8,
                      right: 9,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: t.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
