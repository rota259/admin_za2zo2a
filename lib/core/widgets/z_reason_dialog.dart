import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';
import 'z_button.dart';

/// A confirm dialog with an optional (usually required) reason field.
///
/// Used for the actions the backend won't accept without a reason — rejecting
/// a document, blocking a driver — and for plain confirms (no reason).
/// Returns the entered reason on confirm, or null on cancel. For no-reason
/// confirms it returns an empty string on confirm.
class ZReasonDialog extends StatefulWidget {
  const ZReasonDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.requireReason = false,
    this.reasonHint,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String confirmLabel;
  final bool requireReason;
  final String? reasonHint;
  final bool danger;

  static Future<String?> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
    required String confirmLabel,
    bool requireReason = false,
    String? reasonHint,
    bool danger = false,
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => ZReasonDialog(
        icon: icon,
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        requireReason: requireReason,
        reasonHint: reasonHint,
        danger: danger,
      ),
    );
  }

  @override
  State<ZReasonDialog> createState() => _ZReasonDialogState();
}

class _ZReasonDialogState extends State<ZReasonDialog> {
  final _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final reason = _controller.text.trim();
    if (widget.requireReason && reason.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);
    final tint = widget.danger ? t.danger : t.accent;

    return Dialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(color: t.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(widget.icon, color: tint, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(widget.title,
                        style: theme.textTheme.headlineSmall),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.body,
                style: theme.textTheme.bodyMedium?.copyWith(color: t.text2),
              ),
              if (widget.requireReason || widget.reasonHint != null) ...[
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: 2,
                  maxLines: 4,
                  style: theme.textTheme.bodyMedium,
                  cursorColor: t.accent,
                  onChanged: (_) {
                    if (_showError) setState(() => _showError = false);
                  },
                  decoration: InputDecoration(
                    hintText: widget.reasonHint ?? 'Reason…',
                    hintStyle:
                        theme.textTheme.bodyMedium?.copyWith(color: t.text3),
                    filled: true,
                    fillColor: t.surface2,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    enabledBorder: _border(
                        _showError ? t.danger : t.border),
                    focusedBorder: _border(
                        _showError ? t.danger : t.accent, 1.5),
                    border: _border(t.border),
                  ),
                ),
                if (_showError) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('A reason is required.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: t.danger)),
                ],
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ZButton(
                    label: 'Cancel',
                    variant: ZButtonVariant.secondary,
                    size: ZButtonSize.small,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ZButton(
                    label: widget.confirmLabel,
                    size: ZButtonSize.small,
                    variant: widget.danger
                        ? ZButtonVariant.danger
                        : ZButtonVariant.primary,
                    onPressed: _confirm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: c, width: w),
      );
}
