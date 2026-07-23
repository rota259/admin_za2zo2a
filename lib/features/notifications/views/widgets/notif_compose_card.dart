import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_button.dart';
import '../../../../core/widgets/z_card.dart';
import '../../../../core/widgets/z_reason_dialog.dart';
import '../../../../core/widgets/z_text_field.dart';
import '../../cubit/notif_compose_cubit.dart';
import 'notif_selectors.dart';

/// The compose card: audience picker, type segments, title, body and the
/// (send-ready but currently inert) Send button.
class NotifComposeCard extends StatelessWidget {
  const NotifComposeCard({
    super.key,
    required this.state,
    required this.cubit,
    required this.bodyController,
  });

  final NotifComposeState state;
  final NotifComposeCubit cubit;
  final TextEditingController bodyController;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Audience', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          NotifAudienceGrid(current: state.target, onSelect: cubit.setTarget),
          if (state.target == NotifTarget.single) ...[
            const SizedBox(height: AppSpacing.lg),
            ZTextField(
              label: 'Recipient user ID',
              hint: 'Mongo _id of the rider/driver to notify',
              onChanged: cubit.setUserId,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text('Type', style: theme.textTheme.titleSmall),
          const SizedBox(height: 7),
          NotifTypeSegments(current: state.type, onSelect: cubit.setType),
          const SizedBox(height: AppSpacing.lg),
          ZTextField(
            label: 'Title',
            hint: 'e.g. 20% off your next ride',
            onChanged: cubit.setTitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Message', style: theme.textTheme.titleSmall),
          const SizedBox(height: 7),
          TextField(
            controller: bodyController,
            onChanged: cubit.setBody,
            minLines: 4,
            maxLines: 7,
            style: theme.textTheme.bodyMedium,
            cursorColor: t.accent,
            decoration: InputDecoration(
              hintText: 'Write the notification body…',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: t.text3),
              filled: true,
              fillColor: t.searchBg,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              enabledBorder: _border(t.border),
              focusedBorder: _border(t.accent, 1.5),
              border: _border(t.border),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Targets ${state.target.label.toLowerCase()}',
                  style: theme.textTheme.bodySmall?.copyWith(color: t.text2),
                ),
              ),
              ZButton(
                label: 'Send notification',
                icon: Icons.send,
                size: ZButtonSize.small,
                loading: state.isSending,
                onPressed: state.isValid && !state.isSending
                    ? () => _confirmSend(context)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: c, width: w),
      );

  Future<void> _confirmSend(BuildContext context) async {
    final ok = await ZReasonDialog.show(
      context,
      icon: Icons.send,
      title: 'Send this notification?',
      body: 'It goes out immediately to ${state.target.label.toLowerCase()} '
          'as a push notification and an in-app message.',
      confirmLabel: 'Send',
    );
    if (ok != null) cubit.send();
  }
}
