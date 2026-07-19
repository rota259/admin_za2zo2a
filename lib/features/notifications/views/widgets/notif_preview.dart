import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../cubit/notif_compose_cubit.dart';

/// A phone-style live preview of the notification as riders/drivers will see it.
class NotifPreview extends StatelessWidget {
  const NotifPreview({super.key, required this.state});

  final NotifComposeState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final tone = _tone(t, state.type);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(state.type.icon, size: 19, color: tone),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Za2zo2a', style: theme.textTheme.labelLarge),
                    const Spacer(),
                    Text('now',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: t.text3, letterSpacing: 0)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  state.title.trim().isEmpty
                      ? 'Your notification title'
                      : state.title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  state.body.trim().isEmpty
                      ? 'Your message body appears here as riders and drivers '
                          'will see it on their device.'
                      : state.body,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: t.text2, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _tone(AppTokens t, NotifKind kind) => switch (kind) {
        NotifKind.info => t.info,
        NotifKind.promo => t.accent,
        NotifKind.warning => t.warning,
      };
}
