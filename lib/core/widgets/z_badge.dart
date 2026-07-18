import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';

/// Semantic badge tones. These map to the real states the backend returns —
/// driver document status, selfie-check status, user active flag.
enum ZBadgeTone { neutral, success, warning, danger, info, accent }

/// Pill badge: soft tinted background, saturated text, per the design.
class ZBadge extends StatelessWidget {
  const ZBadge({
    super.key,
    required this.label,
    this.tone = ZBadgeTone.neutral,
    this.icon,
  });

  final String label;
  final ZBadgeTone tone;
  final IconData? icon;

  /// Map a backend document/selfie status string to a tone.
  /// Values per `DriverDocumentStatus` and `SelfieCheck.status`.
  factory ZBadge.forStatus(String status) {
    final s = status.toLowerCase();
    return switch (s) {
      'approved' => const ZBadge(label: 'Approved', tone: ZBadgeTone.success),
      'rejected' => const ZBadge(label: 'Rejected', tone: ZBadgeTone.danger),
      'submitted' => const ZBadge(label: 'Submitted', tone: ZBadgeTone.info),
      'pending' => const ZBadge(label: 'Pending', tone: ZBadgeTone.warning),
      'pending_review' =>
        const ZBadge(label: 'Pending review', tone: ZBadgeTone.warning),
      'blocked' => const ZBadge(label: 'Blocked', tone: ZBadgeTone.danger),
      'active' => const ZBadge(label: 'Active', tone: ZBadgeTone.success),
      _ => ZBadge(label: status, tone: ZBadgeTone.neutral),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (fg, bg) = _colors(t);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: fg, letterSpacing: 0.1),
          ),
        ],
      ),
    );
  }

  (Color, Color) _colors(AppTokens t) => switch (tone) {
        ZBadgeTone.success => (t.greenText, t.green.withValues(alpha: 0.12)),
        ZBadgeTone.warning => (t.warning, t.warning.withValues(alpha: 0.12)),
        ZBadgeTone.danger => (t.danger, t.danger.withValues(alpha: 0.12)),
        ZBadgeTone.info => (t.info, t.info.withValues(alpha: 0.12)),
        ZBadgeTone.accent => (t.accentText, t.accentSoft),
        ZBadgeTone.neutral => (t.text2, t.surface2),
      };
}
