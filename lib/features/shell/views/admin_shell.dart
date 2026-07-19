import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/cursor_glow.dart';
import '../cubit/shell_cubit.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_top_bar.dart';

/// Persistent chrome around every authenticated screen: sidebar + top bar,
/// with the routed page in a bounded content area.
///
/// The breadcrumb, page padding, max-width and scrolling live in [AdminPage]
/// (per screen) rather than here, so this content slot stays bounded — which
/// is what lets go_router's route navigator run the fade/slide page
/// transition between screens.
///
/// Three responsive tiers:
///   • ≥1100px  — full rail, collapsible by choice
///   • 820-1100 — rail force-collapsed to icons
///   • <820px   — rail leaves the layout, opens as a drawer
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  /// The routed page (go_router's ShellRoute navigator).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final location = GoRouterState.of(context).uri.path;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < AppSizes.compactBreakpoint;
        final forceCollapsed = width < AppSizes.tabletBreakpoint;
        final userCollapsed = context.watch<ShellCubit>().state;
        final collapsed = forceCollapsed || userCollapsed;

        final scaffoldKey = GlobalKey<ScaffoldState>();

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: t.bg,
          drawer: isCompact
              ? Drawer(
                  backgroundColor: t.sidebar,
                  width: AppSizes.sidebarWidth,
                  child: AppSidebar(
                    collapsed: false,
                    currentPath: location,
                    showToggle: false,
                    onToggle: () {},
                    onNavigate: (path) {
                      Navigator.of(context).pop();
                      context.go(path);
                    },
                  ),
                )
              : null,
          body: Row(
            children: [
              if (!isCompact)
                AppSidebar(
                  collapsed: collapsed,
                  currentPath: location,
                  // At tablet width the rail is pinned collapsed, so the
                  // manual toggle would be a no-op — hide it.
                  showToggle: !forceCollapsed,
                  onToggle: () => context.read<ShellCubit>().toggle(),
                  onNavigate: (path) => context.go(path),
                ),
              Expanded(
                child: Column(
                  children: [
                    AppTopBar(
                      onMenu: isCompact
                          ? () => scaffoldKey.currentState?.openDrawer()
                          : null,
                    ),
                    // Site-wide ambient glow that trails the cursor behind
                    // every screen's content. Kept very low-opacity so tables
                    // and forms stay perfectly readable.
                    Expanded(
                      child: CursorGlow(
                        color: t.accent,
                        opacity: 0.10,
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
