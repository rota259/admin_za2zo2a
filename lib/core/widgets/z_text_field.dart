import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';

/// Labelled text input matching the design: 46px tall, 12px radius, optional
/// leading icon, accent focus ring.
class ZTextField extends StatelessWidget {
  const ZTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.obscure = false,
    this.enabled = true,
    this.autofocus = false,
    this.onSubmitted,
    this.keyboardType,
    this.trailing,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: c, width: w),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: AppSizes.inputHeight,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            enabled: enabled,
            autofocus: autofocus,
            onSubmitted: onSubmitted,
            keyboardType: keyboardType,
            style: theme.textTheme.bodyLarge,
            cursorColor: t.accent,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(color: t.text3),
              filled: true,
              fillColor: t.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              prefixIcon: icon == null
                  ? null
                  : Icon(icon, size: 17, color: t.text3),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: AppSizes.inputHeight,
              ),
              suffixIcon: trailing,
              enabledBorder: border(t.border),
              disabledBorder: border(t.border),
              focusedBorder: border(t.accent, 1.5),
              border: border(t.border),
            ),
          ),
        ),
      ],
    );
  }
}
