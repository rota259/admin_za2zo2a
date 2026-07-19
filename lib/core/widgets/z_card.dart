import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';
import '../util/ambient_motion.dart';

/// The design's surface primitive: `--surface` fill, 1px `--border`,
/// 16px radius, `--shadow-sm`, `--pad` padding.
///
/// Lights up on hover — the border warms to the accent and a soft accent glow
/// eases in — so cards feel alive under the cursor. Disable per-card with
/// [hoverGlow] (e.g. the danger-zone card, which has its own red styling).
class ZCard extends StatefulWidget {
  const ZCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.hoverGlow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool hoverGlow;

  @override
  State<ZCard> createState() => _ZCardState();
}

class _ZCardState extends State<ZCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final glow = widget.hoverGlow && AmbientMotion.enabled && _hovered;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(
          color: glow ? t.accent.withValues(alpha: 0.45) : t.border,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: glow
            ? [
                ...t.shadowSm,
                BoxShadow(
                  color: t.accent.withValues(alpha: 0.14),
                  blurRadius: 26,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
              ]
            : t.shadowSm,
      ),
      child: widget.child,
    );

    final card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: content,
    );

    if (widget.onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        hoverColor: t.hover,
        child: card,
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
