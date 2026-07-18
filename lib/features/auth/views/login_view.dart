import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import 'widgets/login_brand_panel.dart';
import 'widgets/login_form.dart';

/// Split login screen: crimson brand panel (1.05fr) + form (0.95fr).
///
/// Below the tablet breakpoint the brand panel drops away and the form
/// centres on its own — a 380px form next to a 42px headline doesn't fit.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showBrand = constraints.maxWidth >= AppSizes.tabletBreakpoint;

          if (!showBrand) {
            return const Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.xxxl),
                child: LoginForm(),
              ),
            );
          }

          return Row(
            children: const [
              Expanded(flex: 105, child: LoginBrandPanel()),
              Expanded(
                flex: 95,
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(40),
                    child: LoginForm(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
