import 'package:flutter/material.dart';

import '../../../../core/network/media_url.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';

/// A labelled square photo cell ("On file" / "Submitted"). The submitted side
/// is [highlight]ed with an accent border. Falls back to a person placeholder
/// when there is no image on file.
class SelfiePhoto extends StatelessWidget {
  const SelfiePhoto({
    super.key,
    required this.label,
    required this.url,
    required this.highlight,
  });

  final String label;
  final String? url;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: t.text3, letterSpacing: 0.4)),
        const SizedBox(height: 5),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: t.surface2,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border:
                  highlight ? Border.all(color: t.accent, width: 1.5) : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: (url != null && url!.isNotEmpty)
                ? Image.network(mediaUrl(url)!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(t))
                : _placeholder(t),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(AppTokens t) =>
      Center(child: Icon(Icons.person_outline, size: 26, color: t.text3));
}

/// The card's soft/filled action button (Reject / Match).
class SelfieActionButton extends StatelessWidget {
  const SelfieActionButton({
    super.key,
    required this.label,
    required this.tone,
    required this.filled,
    required this.enabled,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color tone;
  final bool filled;
  final bool enabled;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : tone;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: filled ? tone : tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: fg),
                  const SizedBox(width: 5),
                ],
                Text(label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: fg,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
