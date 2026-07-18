import 'package:flutter/material.dart';

import 'app_dimens.dart';
import 'app_palette.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Builds Material themes whose every colour originates from [AppTokens],
/// so light/dark stay in lockstep with the design file.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppPalette.light, Brightness.light);
  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppTokens t, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: t.accent,
      onPrimary: Colors.white,
      secondary: t.accentText,
      onSecondary: Colors.white,
      error: t.danger,
      onError: Colors.white,
      surface: t.surface,
      onSurface: t.text,
    );

    final textTheme = AppTypography.textTheme(t.text, t.text2);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.bg,
      canvasColor: t.surface,
      dividerColor: t.border,
      hoverColor: t.hover,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[t],
      dividerTheme: DividerThemeData(color: t.border, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: t.text2, size: AppSizes.iconMd),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.toastBg,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: t.toastText),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(t.text3.withValues(alpha: 0.45)),
        radius: const Radius.circular(AppRadii.pill),
        thickness: const WidgetStatePropertyAll(8),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
