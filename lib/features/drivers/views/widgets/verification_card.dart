import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_badge.dart';
import '../../../../core/widgets/z_button.dart';
import '../../../../core/widgets/z_card.dart';
import '../../data/models/driver_verification.dart';

/// Selfie-verification status on the driver detail: when the driver was last
/// verified and its outcome, plus a "Request re-verification" action.
///
/// The last-verified data is real (from the detail endpoint's `latestSelfie`).
/// The request button is present-but-inert until the backend exposes a
/// "request selfie" endpoint and the driver-side submit route is mounted — see
/// docs/integration-spec.md. It never silently does nothing: the tooltip says so.
class VerificationCard extends StatelessWidget {
  const VerificationCard({super.key, required this.verification});

  final DriverVerification? verification;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final v = verification;

    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 16, color: t.text2),
              const SizedBox(width: 7),
              Text('Selfie verification', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (v == null)
            _line(context, 'Last verified', 'No selfie on record')
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text('Last verified',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: t.text2)),
                ),
                ZBadge.forStatus(v.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              v.lastCheckedAt != null
                  ? _formatDateTime(v.lastCheckedAt!)
                  : '—',
              style: theme.textTheme.titleMedium,
            ),
            if (v.status == 'rejected' && v.rejectionReason != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(v.rejectionReason!,
                  style: theme.textTheme.bodySmall?.copyWith(color: t.danger)),
            ],
          ],
          const SizedBox(height: AppSpacing.lg),
          const Tooltip(
            message: 'Requesting a selfie is not available yet — the backend '
                'needs a "request verification" endpoint (see the integration '
                'spec).',
            child: ZButton(
              label: 'Request re-verification',
              icon: Icons.camera_alt_outlined,
              variant: ZButtonVariant.secondary,
              size: ZButtonSize.small,
              expand: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value) {
    final t = context.tokens;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: t.text2)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }

  String _formatDateTime(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $h:$m $ampm';
  }
}
