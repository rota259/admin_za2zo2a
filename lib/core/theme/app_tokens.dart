import 'package:flutter/material.dart';

/// Semantic design tokens, lifted verbatim from the design file's `themeVars()`.
///
/// Material's [ColorScheme] has no home for roles the design leans on heavily
/// (`--surface-2`, `--sidebar`, `--text-2`, `--text-3`, `--accent-soft`), so the
/// full set lives here as a [ThemeExtension]. Read them anywhere via
/// `context.tokens` — never hardcode a colour in a widget.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.accent,
    required this.accentText,
    required this.accentSoft,
    required this.bg,
    required this.surface,
    required this.surfaceAlpha,
    required this.surface2,
    required this.sidebar,
    required this.border,
    required this.hover,
    required this.searchBg,
    required this.text,
    required this.text2,
    required this.text3,
    required this.green,
    required this.greenText,
    required this.warning,
    required this.danger,
    required this.info,
    required this.toastBg,
    required this.toastText,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
  });

  final Color accent;
  final Color accentText;
  final Color accentSoft;

  final Color bg;
  final Color surface;

  /// `--surface-alpha` — translucent surface behind the top bar, which sits
  /// over a 10px backdrop blur.
  final Color surfaceAlpha;

  final Color surface2;
  final Color sidebar;

  final Color border;
  final Color hover;
  final Color searchBg;

  final Color text;
  final Color text2;
  final Color text3;

  final Color green;
  final Color greenText;
  final Color warning;
  final Color danger;
  final Color info;

  final Color toastBg;
  final Color toastText;

  final Color skeletonBase;
  final Color skeletonHighlight;

  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;

  /// Brand crimson. The one constant across both themes.
  static const Color brand = Color(0xFFE8194B);

  @override
  AppTokens copyWith({Color? accent, Color? bg, Color? surface}) => AppTokens(
        accent: accent ?? this.accent,
        accentText: accentText,
        accentSoft: accentSoft,
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surfaceAlpha: surfaceAlpha,
        surface2: surface2,
        sidebar: sidebar,
        border: border,
        hover: hover,
        searchBg: searchBg,
        text: text,
        text2: text2,
        text3: text3,
        green: green,
        greenText: greenText,
        warning: warning,
        danger: danger,
        info: info,
        toastBg: toastBg,
        toastText: toastText,
        skeletonBase: skeletonBase,
        skeletonHighlight: skeletonHighlight,
        shadowSm: shadowSm,
        shadowMd: shadowMd,
        shadowLg: shadowLg,
      );

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      accent: c(accent, other.accent),
      accentText: c(accentText, other.accentText),
      accentSoft: c(accentSoft, other.accentSoft),
      bg: c(bg, other.bg),
      surface: c(surface, other.surface),
      surfaceAlpha: c(surfaceAlpha, other.surfaceAlpha),
      surface2: c(surface2, other.surface2),
      sidebar: c(sidebar, other.sidebar),
      border: c(border, other.border),
      hover: c(hover, other.hover),
      searchBg: c(searchBg, other.searchBg),
      text: c(text, other.text),
      text2: c(text2, other.text2),
      text3: c(text3, other.text3),
      green: c(green, other.green),
      greenText: c(greenText, other.greenText),
      warning: c(warning, other.warning),
      danger: c(danger, other.danger),
      info: c(info, other.info),
      toastBg: c(toastBg, other.toastBg),
      toastText: c(toastText, other.toastText),
      skeletonBase: c(skeletonBase, other.skeletonBase),
      skeletonHighlight: c(skeletonHighlight, other.skeletonHighlight),
      shadowSm: t < 0.5 ? shadowSm : other.shadowSm,
      shadowMd: t < 0.5 ? shadowMd : other.shadowMd,
      shadowLg: t < 0.5 ? shadowLg : other.shadowLg,
    );
  }
}

/// `context.tokens` — the only sanctioned way to reach a colour or shadow.
extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
