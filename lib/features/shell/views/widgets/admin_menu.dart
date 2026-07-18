import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/data/models/admin_model.dart';

/// Profile block: 34×34 gradient avatar + name + role + chevron, with the
/// design's three-item menu.
///
/// Shows the REAL signed-in admin from GET /api/admin/auth/me. The design's
/// static "Owner · Admin" subtitle is rendered from the account's actual role.
class AdminMenu extends StatelessWidget {
  const AdminMenu({super.key, required this.admin});

  final AdminModel admin;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 52),
      color: t.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: BorderSide(color: t.border),
      ),
      constraints: const BoxConstraints(minWidth: 210, maxWidth: 210),
      onSelected: (v) {
        if (v == 'logout') context.read<AuthCubit>().logout();
      },
      itemBuilder: (context) => [
        _item(context, 'settings', 'Account settings', Icons.manage_accounts_outlined,
            enabled: false),
        _item(context, 'activity', 'Activity log', Icons.receipt_long_outlined,
            enabled: false),
        _item(context, 'logout', 'Sign out', Icons.logout,
            color: t.accentText),
      ],
      child: _ProfileTrigger(admin: admin, theme: theme, t: t),
    );
  }

  /// Settings and Activity log have no backend endpoints yet, so they're
  /// present-but-inert with an explanatory tooltip rather than dead links.
  PopupMenuItem<String> _item(
    BuildContext context,
    String value,
    String label,
    IconData icon, {
    bool enabled = true,
    Color? color,
  }) {
    final t = context.tokens;
    final fg = color ?? (enabled ? t.text2 : t.text3);
    return PopupMenuItem<String>(
      value: value,
      enabled: enabled,
      height: 38,
      child: Tooltip(
        message: enabled ? '' : '$label — no backend endpoint yet',
        child: Row(
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: fg, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTrigger extends StatefulWidget {
  const _ProfileTrigger({
    required this.admin,
    required this.theme,
    required this.t,
  });

  final AdminModel admin;
  final ThemeData theme;
  final AppTokens t;

  @override
  State<_ProfileTrigger> createState() => _ProfileTriggerState();
}

class _ProfileTriggerState extends State<_ProfileTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final admin = widget.admin;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: _hovered ? t.hover : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // linear-gradient(140deg, #334155, #1e293b)
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(-0.64, -1),
                  end: Alignment(0.64, 1),
                  colors: [Color(0xFF334155), Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                admin.initials,
                style: widget.theme.textTheme.labelLarge
                    ?.copyWith(color: Colors.white, fontSize: 13),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.name,
                  style: widget.theme.textTheme.labelLarge
                      ?.copyWith(fontSize: 13.5, height: 1.15),
                ),
                Text(
                  _roleLabel(admin.role),
                  style: widget.theme.textTheme.labelSmall?.copyWith(
                    color: t.text3,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    height: 1.15,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.expand_more, size: 15, color: t.text3),
          ],
        ),
      ),
    );
  }

  /// The console has a single owner account; the design labels it
  /// "Owner · Admin". Derived from the real role rather than hardcoded.
  String _roleLabel(String? role) =>
      role == 'admin' ? 'Owner · Admin' : (role ?? '—');
}
