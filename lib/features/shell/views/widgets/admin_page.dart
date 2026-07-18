import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import 'breadcrumbs.dart';

/// Standard content scaffold for every routed screen inside the shell:
/// the `Za2zo2a / <title>` breadcrumb, the 1360px max-width, page padding, and
/// its own scroll view.
///
/// Scrolling lives here (per page) rather than in the shell so the shell's
/// route navigator stays bounded — which is what lets go_router run the
/// fade/slide page transition between screens.
class AdminPage extends StatelessWidget {
  const AdminPage({
    super.key,
    required this.title,
    required this.child,
    this.parent,
  });

  /// Current page label for the breadcrumb ("Overview", "Drivers", …).
  final String title;

  /// Optional parent crumb for detail screens ("Drivers" → "Driver detail").
  final String? parent;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter, 20, AppSpacing.pageGutter, 0),
                child: Breadcrumbs(title: title, parent: parent),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter, 14, AppSpacing.pageGutter, 44),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
