import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

/// `Za2zo2a / Overview` trail.
///
/// Per the design: 13px, `/` separator at 50% opacity (a literal slash, not a
/// chevron), leading crumbs in `--text-3`, the current page in `--text` at
/// weight 600. Sits in the scroll area, above the page heading.
class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs({super.key, required this.title, this.parent});

  final String title;

  /// Set on detail screens ("Drivers" → "Driver detail").
  final String? parent;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    final crumbs = <String>['Za2zo2a', ?parent, title];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < crumbs.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  '/',
                  style: theme.textTheme.bodySmall?.copyWith(color: t.text3),
                ),
              ),
            ),
          Text(
            crumbs[i],
            style: i == crumbs.length - 1
                ? theme.textTheme.bodySmall
                    ?.copyWith(color: t.text, fontWeight: FontWeight.w600)
                : theme.textTheme.bodySmall?.copyWith(color: t.text3),
          ),
        ],
      ],
    );
  }
}
