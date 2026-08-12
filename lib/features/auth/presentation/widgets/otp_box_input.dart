import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';

/// INPUT/OTP from the Auth deck — 50×58 cells, 9px apart, radius 12, laid out
/// LTR while the surrounding page stays RTL.
///
/// One real [TextField] sits invisibly over the cells instead of one field per
/// digit: paste, autofill («کد کپی‌شده به‌صورت خودکار جای‌گذاری می‌شود») and
/// backspace then behave the way the platform already implements them.
class OtpBoxInput extends StatefulWidget {
  const OtpBoxInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.enabled = true,
    this.hasError = false,
    this.onCompleted,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final int length;

  /// False renders the Expired cell state — dimmed and non-interactive.
  final bool enabled;

  final bool hasError;

  /// Fires once when the last digit lands — the deck auto-verifies on «۶ رقم».
  final ValueChanged<String>? onCompleted;

  final bool autofocus;

  @override
  State<OtpBoxInput> createState() => _OtpBoxInputState();
}

class _OtpBoxInputState extends State<OtpBoxInput> {
  final _focus = FocusNode();
  bool _completedFired = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    // The caret hops to the next empty cell, so focus changes repaint too.
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() {});

  void _onChanged() {
    final code = widget.controller.text;
    if (code.length < widget.length) {
      _completedFired = false;
    } else if (!_completedFired) {
      _completedFired = true;
      widget.onCompleted?.call(code);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;

    return Stack(
      alignment: Alignment.center,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: 9),
                  _Cell(
                    digit: i < code.length ? code[i] : null,
                    focused: _focus.hasFocus && i == code.length,
                    hasError: widget.hasError,
                    enabled: widget.enabled,
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLength: widget.length,
              showCursor: false,
              enableInteractiveSelection: false,
              onTap: () =>
                  widget.controller.selection = TextSelection.collapsed(
                    offset: widget.controller.text.length,
                  ),
              inputFormatters: [_DigitsOnly()],
              decoration: const InputDecoration(
                counterText: '',
                isDense: true,
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.digit,
    required this.focused,
    required this.hasError,
    required this.enabled,
  });

  final String? digit;
  final bool focused;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final border = hasError
        ? c.danger
        : (focused ? c.borderActive : c.borderDefault);

    return Opacity(
      // Expired cells sit at 45% in the deck's cell-state panel.
      opacity: enabled ? 1 : 0.45,
      child: Container(
        width: 50,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hasError
              ? c.danger.withValues(alpha: 0.05)
              : c.surfaceSecondary,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: border),
          boxShadow: focused && !hasError
              ? [
                  BoxShadow(
                    color: c.borderActive.withValues(alpha: 0.12),
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: digit == null
            ? (focused
                  ? Container(
                      width: 2,
                      height: 24,
                      decoration: BoxDecoration(
                        color: c.borderActive,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  : Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: c.actionDisabled,
                        shape: BoxShape.circle,
                      ),
                    ))
            : Text(
                Fmt.fa(digit!),
                style: context.text.numeric.copyWith(
                  fontSize: 22,
                  color: c.textPrimary,
                ),
              ),
      ),
    );
  }
}

/// Persian keyboards emit «۴»; the API and every length check want ASCII.
class _DigitsOnly extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = Fmt.toAscii(newValue.text).replaceAll(RegExp(r'\D'), '');
    if (digits == newValue.text) return newValue;
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
