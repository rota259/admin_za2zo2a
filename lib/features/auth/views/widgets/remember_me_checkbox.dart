import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';

/// The design's "Remember me" control: an 18×18 accent tile with a white
/// check, 8px gap, 14px `--text-2` label.
///
/// Note on behaviour: the backend issues a fixed 7-day JWT
/// (`JWT_EXPIRES_IN`) with no "short session" variant, so this cannot change
/// token lifetime. It controls whether the session is persisted to storage at
/// all — unchecked means the token lives in memory only and is gone when the
/// tab closes, which is the honest meaning of the control.
class RememberMeCheckbox extends StatelessWidget {
  const RememberMeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = onChanged != null;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: enabled ? () => onChanged!(!value) : null,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: value ? t.accent : Colors.transparent,
                  border: value ? null : Border.all(color: t.border, width: 1.5),
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
                child: value
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Remember me',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: t.text2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
