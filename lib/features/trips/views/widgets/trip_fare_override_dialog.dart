import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_button.dart';

/// Confirm dialog for `PATCH /api/admin/trips/:id/fare` — a new total plus a
/// required reason (both recorded on the trip and in the audit log).
class TripFareOverrideDialog extends StatefulWidget {
  const TripFareOverrideDialog({super.key, required this.currentTotal});

  final double currentTotal;

  /// Returns `(total, reason)` on confirm, or null on cancel.
  static Future<(double, String)?> show(
    BuildContext context, {
    required double currentTotal,
  }) {
    return showDialog<(double, String)?>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => TripFareOverrideDialog(currentTotal: currentTotal),
    );
  }

  @override
  State<TripFareOverrideDialog> createState() =>
      _TripFareOverrideDialogState();
}

class _TripFareOverrideDialogState extends State<TripFareOverrideDialog> {
  late final _totalController =
      TextEditingController(text: widget.currentTotal.toStringAsFixed(2));
  final _reasonController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _totalController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _confirm() {
    final total = double.tryParse(_totalController.text.trim());
    final reason = _reasonController.text.trim();
    if (total == null || total < 0) {
      setState(() => _error = 'Enter a valid, non-negative fare.');
      return;
    }
    if (reason.isEmpty) {
      setState(() => _error = 'A reason is required.');
      return;
    }
    Navigator.of(context).pop((total, reason));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: c, width: w),
        );

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
                      color: t.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(Icons.edit_note, color: t.accent, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text('Override this trip\'s fare?',
                        style: theme.textTheme.headlineSmall),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sets the final fare directly. Recorded on the trip and in '
                'the audit log. Not available for cancelled trips.',
                style: theme.textTheme.bodyMedium?.copyWith(color: t.text2),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('New total', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _totalController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: theme.textTheme.bodyMedium,
                cursorColor: t.accent,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: InputDecoration(
                  prefixText: 'EGP ',
                  filled: true,
                  fillColor: t.surface2,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  enabledBorder: border(t.border),
                  focusedBorder: border(t.accent, 1.5),
                  border: border(t.border),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Reason', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _reasonController,
                minLines: 2,
                maxLines: 4,
                style: theme.textTheme.bodyMedium,
                cursorColor: t.accent,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: InputDecoration(
                  hintText: 'Why is this fare being changed…',
                  hintStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: t.text3),
                  filled: true,
                  fillColor: t.surface2,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  enabledBorder: border(t.border),
                  focusedBorder: border(t.accent, 1.5),
                  border: border(t.border),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: t.danger)),
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
                    label: 'Override fare',
                    size: ZButtonSize.small,
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
}
