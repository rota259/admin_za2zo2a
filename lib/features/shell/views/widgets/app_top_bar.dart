import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/cubit/auth_cubit.dart';
import 'admin_menu.dart';
import 'top_bar_icon_button.dart';
import 'top_bar_search.dart';

/// Top bar: search · spacer · theme toggle · bell · divider · profile.
///
/// Breadcrumbs deliberately live in the scroll area below, not here — that's
/// where the design puts them.
///
/// Background is `--surface-alpha` over a 10px backdrop blur, so content
/// scrolling underneath frosts rather than disappears.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, this.onMenu});

  /// Non-null only below the compact breakpoint, where the rail is a drawer.
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final mode = context.watch<ThemeCubit>().state;
    final isDark = mode == ThemeMode.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: AppSizes.topBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          decoration: BoxDecoration(
            color: t.surfaceAlpha,
            border: Border(bottom: BorderSide(color: t.border)),
          ),
          child: Row(
            children: [
              if (onMenu != null) ...[
                TopBarIconButton(
                  icon: Icons.menu,
                  tooltip: 'Open navigation',
                  onTap: onMenu,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              const Flexible(child: TopBarSearch()),
              const Spacer(),
              const SizedBox(width: AppSpacing.lg),
              TopBarIconButton(
                icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                tooltip: isDark ? 'Switch to light' : 'Switch to dark',
                onTap: () => context.read<ThemeCubit>().toggle(),
              ),
              const SizedBox(width: AppSpacing.md),
              const TopBarIconButton(
                icon: Icons.notifications_none,
                tooltip: 'Notifications are not available yet — the backend '
                    'has no admin notification feed.',
                unreadDot: false,
              ),
              const SizedBox(width: AppSpacing.lg),
              _Divider(color: t.border),
              const SizedBox(width: AppSpacing.lg),
              BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (a, b) => a.admin != b.admin,
                builder: (context, state) {
                  final admin = state.admin;
                  if (admin == null) return const SizedBox.shrink();
                  return AdminMenu(admin: admin);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1px × 26px rule between the icon buttons and the profile block.
class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 26, color: color);
}
