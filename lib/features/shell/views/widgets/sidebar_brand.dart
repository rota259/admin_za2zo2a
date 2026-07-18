import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';

/// Brand lockup at the top of the rail.
///
/// Per the design: a 34×34 gradient mark (`150deg, #e8194b → #a30d31`) with a
/// crimson drop shadow, 64px tall row, and **no bottom border** — the rail's
/// only rule sits above the Collapse group.
class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key, required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return SizedBox(
      height: AppSizes.topBarHeight,
      child: Row(
        mainAxisAlignment:
            collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.5, -1),
                end: Alignment(0.5, 1),
                colors: [AppTokens.brand, Color(0xFFA30D31)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: t.accent.withValues(alpha: 0.55),
                  blurRadius: 12,
                  spreadRadius: -3,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              color: Colors.white,
              size: 19,
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Za2zo2a',
                    style: theme.textTheme.titleLarge?.copyWith(
                      height: 1,
                      letterSpacing: -0.32, // -.02em × 16px
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Operator Console',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: t.text3,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
