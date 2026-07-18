import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../cubit/nav_counts_cubit.dart';
import 'sidebar_brand.dart';
import 'sidebar_nav_tile.dart';

/// Collapsible left rail: `padding: 14px 14px 16px`, no header rule, and a
/// single `border-top` above the Collapse group — per the design.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.collapsed,
    required this.currentPath,
    required this.onNavigate,
    required this.onToggle,
    this.showToggle = true,
  });

  final bool collapsed;
  final String currentPath;
  final ValueChanged<String> onNavigate;
  final VoidCallback onToggle;

  /// Hidden in the drawer, where collapsing makes no sense.
  final bool showToggle;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final counts = context.watch<NavCountsCubit>().state;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: collapsed
          ? AppSizes.sidebarCollapsedWidth
          : AppSizes.sidebarWidth,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: t.sidebar,
        border: Border(right: BorderSide(color: t.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SidebarBrand(collapsed: collapsed),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final item in NavItem.all)
                  SidebarNavTile(
                    item: item,
                    collapsed: collapsed,
                    selected: _isSelected(item.path),
                    badge: counts.forPath(item.path),
                    onTap: item.enabled ? () => onNavigate(item.path) : null,
                  ),
              ],
            ),
          ),
          if (showToggle)
            _CollapseGroup(collapsed: collapsed, onTap: onToggle),
        ],
      ),
    );
  }

  bool _isSelected(String path) {
    if (path == AppRoutes.dashboard) return currentPath == AppRoutes.dashboard;
    return currentPath.startsWith(path);
  }
}

/// The rail's footer: one `border-top`, then the Collapse row.
/// (The design also lists a "Design System" entry here — that's its own
/// component gallery, not a product screen, so it is intentionally absent.)
class _CollapseGroup extends StatefulWidget {
  const _CollapseGroup({required this.collapsed, required this.onTap});

  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_CollapseGroup> createState() => _CollapseGroupState();
}

class _CollapseGroupState extends State<_CollapseGroup> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 11,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _hovered ? t.hover : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                AnimatedRotation(
                  turns: widget.collapsed ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_double_arrow_left,
                    size: 19,
                    color: t.text3,
                  ),
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Collapse',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: t.text3,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
