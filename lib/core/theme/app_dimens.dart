/// Spacing, radii and fixed sizes measured off the design file.
/// No widget should carry a bare numeric padding or radius — pull it from here.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// `--pad` at Comfortable density — the standard card padding.
  static const double cardPad = 20;

  /// `--rpad` at Comfortable density — table row padding.
  static const double rowPadV = 14;
  static const double rowPadH = 16;

  /// Horizontal gutter for the shell's breadcrumb and page body.
  static const double pageGutter = 32;
}

/// Corner radii. The design runs a soft 9/12/16 scale with 20px+ for pills.
class AppRadii {
  const AppRadii._();

  /// Small tags.
  static const double xs = 6;

  /// Icon wraps, compact buttons.
  static const double sm = 9;

  /// Inputs, buttons.
  static const double md = 12;

  /// Cards, panels.
  static const double lg = 16;

  /// Fully-rounded pills and badges.
  static const double pill = 999;
}

/// Fixed control sizes from the design.
class AppSizes {
  const AppSizes._();

  static const double inputHeight = 46;
  static const double buttonHeight = 48;
  static const double buttonHeightSm = 34;

  static const double sidebarWidth = 248;
  static const double sidebarCollapsedWidth = 76;
  static const double topBarHeight = 64;

  /// The design caps page content at 1360px.
  static const double contentMaxWidth = 1360;

  static const double iconSm = 16;
  static const double iconMd = 18;
  static const double iconLg = 22;

  /// Below this width the sidebar auto-collapses to icons-only.
  static const double tabletBreakpoint = 1100;

  /// Below this width the sidebar leaves the layout and opens as a drawer.
  static const double compactBreakpoint = 820;
}
