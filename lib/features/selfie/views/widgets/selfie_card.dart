import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_card.dart';
import '../../../../core/widgets/z_reason_dialog.dart';
import '../../cubit/selfie_cubit.dart';
import '../../data/models/selfie_check.dart';
import 'selfie_card_parts.dart';

/// One selfie check: the reference photo on file next to the submitted selfie,
/// with approve ("Match") / reject actions. No match score is shown — the
/// backend does no face-matching, so the admin decides by eye.
class SelfieCard extends StatelessWidget {
  const SelfieCard({
    super.key,
    required this.check,
    required this.busy,
    required this.anyBusy,
    required this.cubit,
  });

  final SelfieCheck check;
  final bool busy;
  final bool anyBusy;
  final SelfieCubit cubit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(check.driverName, style: theme.textTheme.titleLarge),
          Text(_when(check.submittedAt),
              style: theme.textTheme.bodySmall?.copyWith(color: t.text3)),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelfiePhoto(
                  label: 'On file',
                  url: check.profilePhoto,
                  highlight: false,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SelfiePhoto(
                  label: 'Submitted',
                  url: check.photoUrl,
                  highlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (busy)
            SizedBox(
              height: 38,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(t.accent)),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SelfieActionButton(
                    label: 'Reject',
                    tone: t.danger,
                    filled: false,
                    enabled: !anyBusy,
                    onTap: () => _reject(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SelfieActionButton(
                    label: 'Match',
                    icon: Icons.check,
                    tone: t.green,
                    filled: true,
                    enabled: !anyBusy,
                    onTap: () => cubit.review(check, true),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final reason = await ZReasonDialog.show(
      context,
      icon: Icons.cancel_outlined,
      title: 'Reject this selfie?',
      body: 'The driver will be asked to retake it. A reason is required and '
          'recorded.',
      confirmLabel: 'Reject selfie',
      requireReason: true,
      reasonHint: "Why doesn't it match?",
      danger: true,
    );
    if (reason != null) cubit.review(check, false, reason: reason);
  }

  String _when(DateTime? d) {
    if (d == null) return 'Submitted recently';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return 'Submitted ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Submitted ${diff.inHours}h ago';
    return 'Submitted ${diff.inDays}d ago';
  }
}
