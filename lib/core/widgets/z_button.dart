import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';

enum ZButtonVariant { primary, secondary, ghost, danger }

enum ZButtonSize { regular, small }

/// The console's button.
///
/// Primary carries the design's accent glow (`0 8px 20px -6px rgba(232,25,75,.5)`)
/// and lifts 1px on hover. Every colour and metric comes from the theme.
class ZButton extends StatefulWidget {
  const ZButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ZButtonVariant.primary,
    this.size = ZButtonSize.regular,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ZButtonVariant variant;
  final ZButtonSize size;
  final IconData? icon;
  final bool loading;

  /// Stretch to the parent's width (used by the login form).
  final bool expand;

  @override
  State<ZButton> createState() => _ZButtonState();
}

class _ZButtonState extends State<ZButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final height = widget.size == ZButtonSize.regular
        ? AppSizes.buttonHeight
        : AppSizes.buttonHeightSm;
    final radius =
        widget.size == ZButtonSize.regular ? AppRadii.md : AppRadii.sm;

    final fg = _foreground(t);
    final bg = _background(t);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Listener(
        onPointerDown:
            _enabled ? (_) => setState(() => _pressed = true) : null,
        onPointerUp:
            _enabled ? (_) => setState(() => _pressed = false) : null,
        onPointerCancel:
            _enabled ? (_) => setState(() => _pressed = false) : null,
        child: AnimatedScale(
          // A small dip on press for tactile feedback.
          scale: _pressed && _enabled ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: Opacity(
            opacity: _enabled ? 1 : 0.55,
            child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          // Hover lifts the button 1px, per the design's translateY(-1px).
          transform: Matrix4.translationValues(
            0,
            _hovered && _enabled ? -1 : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: _glow(t),
          ),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            child: InkWell(
              onTap: _enabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(radius),
              hoverColor: widget.variant == ZButtonVariant.primary
                  ? Colors.white.withValues(alpha: 0.08)
                  : t.hover,
              child: Container(
                height: height,
                width: widget.expand ? double.infinity : null,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.size == ZButtonSize.regular
                      ? AppSpacing.xl
                      : AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: widget.variant == ZButtonVariant.secondary
                      ? Border.all(color: t.border)
                      : null,
                ),
                child: Row(
                  mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.loading)
                      SizedBox(
                        width: AppSizes.iconSm,
                        height: AppSizes.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(fg),
                        ),
                      )
                    else if (widget.icon != null) ...[
                      Icon(widget.icon, size: AppSizes.iconSm, color: fg),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    if (!widget.loading)
                      Text(
                        widget.label,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: fg, fontSize: 15),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }

  /// `box-shadow: 0 8px 20px -6px rgba(232,25,75,.5)` — accent variants carry
  /// it at rest and it blooms on hover; secondary/ghost pick up a soft accent
  /// glow only under the cursor, matching the card hover treatment.
  List<BoxShadow>? _glow(AppTokens t) {
    if (!_enabled) return null;
    final hovered = _hovered;
    switch (widget.variant) {
      case ZButtonVariant.primary:
      case ZButtonVariant.danger:
        final color =
            widget.variant == ZButtonVariant.primary ? t.accent : t.danger;
        return [
          BoxShadow(
            color: color.withValues(alpha: hovered ? 0.62 : 0.5),
            blurRadius: hovered ? 30 : 20,
            spreadRadius: hovered ? -3 : -6,
            offset: const Offset(0, 8),
          ),
        ];
      case ZButtonVariant.secondary:
      case ZButtonVariant.ghost:
        if (!hovered) return null;
        return [
          BoxShadow(
            color: t.accent.withValues(alpha: 0.16),
            blurRadius: 22,
            spreadRadius: -6,
            offset: const Offset(0, 6),
          ),
        ];
    }
  }

  Color _background(AppTokens t) => switch (widget.variant) {
        ZButtonVariant.primary => t.accent,
        ZButtonVariant.secondary => t.surface,
        ZButtonVariant.ghost => Colors.transparent,
        ZButtonVariant.danger => t.danger,
      };

  Color _foreground(AppTokens t) => switch (widget.variant) {
        ZButtonVariant.primary => Colors.white,
        ZButtonVariant.secondary => t.text,
        ZButtonVariant.ghost => t.accentText,
        ZButtonVariant.danger => Colors.white,
      };
}
