import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_button.dart';
import '../../../../core/widgets/z_text_field.dart';
import '../../cubit/auth_cubit.dart';
import 'login_error_banner.dart';
import 'remember_me_checkbox.dart';

/// The sign-in form. Dumb by design: it owns only the field controllers and
/// delegates every decision to [AuthCubit].
///
/// Spacing is the design's, to the pixel: 6 / 30 / 7 / 18 / 7 / 14 / 24 / 22.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;

  // zfade .5s ease both — fade in with an 8px rise.
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fade.dispose();
    super.dispose();
  }

  void _submit() =>
      context.read<AuthCubit>().login(_email.text, _password.text);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    final curve = CurvedAnimation(parent: _fade, curve: Curves.easeOut);

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06), // ≈8px at this height
          end: Offset.zero,
        ).animate(curve),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final busy = state.isSubmitting;

            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to the operator console.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: t.text2),
                  ),
                  const SizedBox(height: 30),

                  if (state.error != null) ...[
                    LoginErrorBanner(message: state.error!),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  ZTextField(
                    label: 'Email address',
                    controller: _email,
                    icon: Icons.mail_outline,
                    enabled: !busy,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 18),

                  ZTextField(
                    label: 'Password',
                    controller: _password,
                    icon: Icons.lock_outline,
                    obscure: true,
                    enabled: !busy,
                    hint: '••••••••',
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RememberMeCheckbox(
                        value: _remember,
                        onChanged: busy
                            ? null
                            : (v) => setState(() => _remember = v),
                      ),
                      _ForgotPasswordLink(enabled: !busy),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ZButton(
                    label: 'Sign in to console',
                    onPressed: _submit,
                    loading: busy,
                    expand: true,
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Protected area · Single operator access',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: t.text3),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The design shows this link, but the backend has no admin password-reset
/// flow (`/api/auth/forgot-password` is rider/driver only). Rendered per the
/// design, but it explains itself rather than pretending to work.
class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Tooltip(
      message: 'No admin password-reset endpoint exists yet — '
          'contact the backend owner to reset it.',
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            'Forgot password?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.accentText,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
