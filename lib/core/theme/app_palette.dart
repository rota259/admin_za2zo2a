import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// The two concrete token sets, lifted verbatim from the design file's
/// `themeVars()`. Kept apart from [AppTokens] so the class stays about
/// behaviour and this file stays a flat, reviewable table of values.
class AppPalette {
  const AppPalette._();

  static const AppTokens light = AppTokens(
    accent: AppTokens.brand,
    accentText: Color(0xFFC40F3F),
    accentSoft: Color(0x14E8194B), // rgba(232,25,75,.08)
    bg: Color(0xFFF6F6F4),
    surface: Color(0xFFFFFFFF),
    surfaceAlpha: Color(0xCCFFFFFF), // rgba(255,255,255,.8)
    surface2: Color(0xFFF3F3F1),
    sidebar: Color(0xFFFBFBFA),
    border: Color(0xFFEBEAE7),
    hover: Color(0x0A141419), // rgba(20,20,25,.038)
    searchBg: Color(0xFFF3F3F1),
    text: Color(0xFF1B1B1D),
    text2: Color(0xFF67676D),
    text3: Color(0xFF9A9AA0),
    green: Color(0xFF16A34A),
    greenText: Color(0xFF15803D),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
    info: Color(0xFF2563EB),
    toastBg: Color(0xFF1B1B1D),
    toastText: Color(0xFFFFFFFF),
    skeletonBase: Color(0xFFEEEEEC),
    skeletonHighlight: Color(0xFFF6F6F4),
    shadowSm: [
      BoxShadow(color: Color(0x0D14141E), blurRadius: 2, offset: Offset(0, 1)),
    ],
    shadowMd: [
      BoxShadow(
        color: Color(0x1A14141E),
        blurRadius: 20,
        spreadRadius: -6,
        offset: Offset(0, 6),
      ),
    ],
    shadowLg: [
      BoxShadow(
        color: Color(0x3814141E),
        blurRadius: 60,
        spreadRadius: -16,
        offset: Offset(0, 24),
      ),
    ],
  );

  static const AppTokens dark = AppTokens(
    accent: AppTokens.brand,
    accentText: Color(0xFFFF6F8F),
    accentSoft: Color(0x2EE8194B), // rgba(232,25,75,.18)
    bg: Color(0xFF0D0D10),
    surface: Color(0xFF17171B),
    surfaceAlpha: Color(0xD117171B), // rgba(23,23,27,.82)
    surface2: Color(0xFF1F1F24),
    sidebar: Color(0xFF111114),
    border: Color(0xFF2A2A30),
    hover: Color(0x0DFFFFFF), // rgba(255,255,255,.05)
    searchBg: Color(0xFF1F1F24),
    text: Color(0xFFF2F2F3),
    text2: Color(0xFFA1A1AA),
    text3: Color(0xFF71717A),
    green: Color(0xFF22C55E),
    greenText: Color(0xFF4ADE80),
    warning: Color(0xFFD97706),
    danger: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    toastBg: Color(0xFF26262C),
    toastText: Color(0xFFF2F2F3),
    skeletonBase: Color(0xFF1F1F24),
    skeletonHighlight: Color(0xFF26262C),
    shadowSm: [
      BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x73000000), blurRadius: 14, offset: Offset(0, 4)),
    ],
    shadowLg: [
      BoxShadow(
        color: Color(0xA6000000),
        blurRadius: 44,
        spreadRadius: -12,
        offset: Offset(0, 18),
      ),
    ],
  );
}
