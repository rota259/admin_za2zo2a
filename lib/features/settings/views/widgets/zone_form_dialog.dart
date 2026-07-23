import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_button.dart';

/// Create-zone form: name, comma-separated areas, surge multiplier.
class ZoneFormDialog extends StatefulWidget {
  const ZoneFormDialog({super.key});

  static Future<(String, List<String>, double)?> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const ZoneFormDialog(),
    );
  }

  @override
  State<ZoneFormDialog> createState() => _ZoneFormDialogState();
}

class _ZoneFormDialogState extends State<ZoneFormDialog> {
  final _nameController = TextEditingController();
  final _areasController = TextEditingController();
  final _surgeController = TextEditingController(text: '1.0');
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _areasController.dispose();
    _surgeController.dispose();
    super.dispose();
  }

  void _confirm() {
    final name = _nameController.text.trim();
    final surge = double.tryParse(_surgeController.text.trim());
    if (name.isEmpty) {
      setState(() => _error = 'Zone name is required.');
      return;
    }
    if (surge == null || surge < 1) {
      setState(() => _error = 'Surge multiplier must be at least 1.');
      return;
    }
    final areas = _areasController.text
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();
    Navigator.of(context).pop((name, areas, surge));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: c, width: w),
        );

    InputDecoration deco(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: t.text3),
          filled: true,
          fillColor: t.surface2,
          contentPadding: const EdgeInsets.all(AppSpacing.md),
          enabledBorder: border(t.border),
          focusedBorder: border(t.accent, 1.5),
          border: border(t.border),
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
              Text('New service zone', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              Text('Name', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: deco('e.g. Central Cairo')),
              const SizedBox(height: AppSpacing.md),
              Text('Areas', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                  controller: _areasController,
                  decoration: deco('Downtown, Zamalek, Garden City (comma-separated)')),
              const SizedBox(height: AppSpacing.md),
              Text('Surge multiplier', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                  controller: _surgeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: deco('1.0')),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!,
                    style: theme.textTheme.bodySmall?.copyWith(color: t.danger)),
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
                      label: 'Create zone',
                      size: ZButtonSize.small,
                      onPressed: _confirm),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
