import 'package:flutter/material.dart';

/// Type scale from the design: Hanken Grotesk throughout, JetBrains Mono for
/// numerics (IDs, fares, money) so figures align in tables.
///
/// Both faces are bundled as assets (see pubspec) rather than fetched from
/// Google's CDN at runtime, so the console makes no third-party font request.
class AppTypography {
  const AppTypography._();

  static const String bodyFamily = 'Hanken Grotesk';
  static const String monoFamily = 'JetBrains Mono';

  /// Numeric/monospace face — trip IDs, fares, balances.
  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: monoFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextTheme textTheme(Color text, Color text2) {
    TextStyle base(double size, FontWeight weight, {double? spacing}) =>
        TextStyle(
          fontFamily: bodyFamily,
          fontSize: size,
          fontWeight: weight,
          color: text,
          letterSpacing: spacing,
        );

    return TextTheme(
      // Page / hero headings.
      displaySmall: base(27, FontWeight.w700, spacing: -0.54),
      // Section headings ("Welcome back").
      headlineMedium: base(22, FontWeight.w700, spacing: -0.4),
      headlineSmall: base(17, FontWeight.w700),
      // Card titles.
      titleLarge: base(16, FontWeight.w700),
      titleMedium: base(14, FontWeight.w600),
      // Field labels.
      titleSmall: base(13, FontWeight.w600).copyWith(color: text2),
      // Body copy.
      bodyLarge: base(15, FontWeight.w400),
      bodyMedium: base(14, FontWeight.w400),
      bodySmall: base(13, FontWeight.w400).copyWith(color: text2),
      // Table headers, meta text.
      labelLarge: base(13.5, FontWeight.w600),
      labelMedium: base(12.5, FontWeight.w500).copyWith(color: text2),
      labelSmall: base(11, FontWeight.w700, spacing: 0.4).copyWith(color: text2),
    );
  }
}
