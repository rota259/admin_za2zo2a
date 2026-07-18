import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_button.dart';

/// Dashboard page head: time-based greeting + actions, per the design.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.adminName});

  final String? adminName;

  /// Clock behind the greeting. Overridable so golden tests get a stable
  /// wording instead of drifting with the wall clock.
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()}, ${_firstName(adminName)}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 26,
                  letterSpacing: -0.65, // -.025em × 26px
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Here's what's happening across Za2zo2a today.",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: t.text2, fontSize: 14.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        // Export has no backend endpoint — inert with an explanation rather
        // than a button that silently does nothing.
        const Tooltip(
          message: 'Export is not available yet — the backend has no export '
              'endpoint.',
          child: ZButton(
            label: 'Export',
            icon: Icons.download_outlined,
            variant: ZButtonVariant.ghost,
            size: ZButtonSize.small,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        ZButton(
          label: 'Adjust pricing',
          icon: Icons.tune_outlined,
          size: ZButtonSize.small,
          onPressed: () => context.go(AppRoutes.pricing),
        ),
      ],
    );
  }

  /// The design greets by first name; derive it from the real account.
  String _firstName(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'there';
    return n.split(RegExp(r'\s+')).first;
  }

  String _greeting() {
    final h = clock().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }
}
