import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';

/// A labelled numeric fare input with an optional prefix (E£), suffix (/min, ×)
/// and hint. Reports parsed values via [onChanged], and re-syncs its text when
/// the bound [value] changes externally (e.g. Reset).
class PricingField extends StatefulWidget {
  const PricingField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.prefix,
    this.suffix,
    this.hint,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String? prefix;
  final String? suffix;
  final String? hint;

  @override
  State<PricingField> createState() => _PricingFieldState();
}

class _PricingFieldState extends State<PricingField> {
  late final TextEditingController _controller =
      TextEditingController(text: _fmt(widget.value));
  late double _lastEmitted = widget.value;

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void didUpdateWidget(PricingField old) {
    super.didUpdateWidget(old);
    // External change (Reset / reload) — re-sync, but don't fight live typing.
    if (widget.value != _lastEmitted) {
      _controller.text = _fmt(widget.value);
      _lastEmitted = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    final parsed = double.tryParse(text.trim());
    if (parsed == null) return;
    _lastEmitted = parsed;
    widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: c, width: w),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 7),
        SizedBox(
          height: 44,
          child: TextField(
            controller: _controller,
            onChanged: _onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: AppTypography.mono(size: 15, weight: FontWeight.w600)
                .copyWith(color: t.text),
            cursorColor: t.accent,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: t.searchBg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              prefixIcon: widget.prefix == null ? null : _affix(widget.prefix!, t),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 34, minHeight: 44),
              suffixIcon:
                  widget.suffix == null ? null : _affix(widget.suffix!, t, false),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 40, minHeight: 44),
              enabledBorder: border(t.border),
              focusedBorder: border(t.accent, 1.5),
              border: border(t.border),
            ),
          ),
        ),
        if (widget.hint != null) ...[
          const SizedBox(height: 5),
          Text(widget.hint!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: t.text3, fontSize: 11.5)),
        ],
      ],
    );
  }

  Widget _affix(String text, AppTokens t, [bool leading = true]) => Padding(
        padding: EdgeInsets.only(
            left: leading ? 13 : 0, right: leading ? 0 : 13),
        child: Center(
          widthFactor: 1,
          child: Text(text,
              style: TextStyle(
                  color: t.text3,
                  fontSize: leading ? 14 : 12,
                  fontWeight: leading ? FontWeight.w600 : FontWeight.w400)),
        ),
      );
}
