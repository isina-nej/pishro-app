import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';

/// INPUT/TEXT from Frame 06 — label above, hint inside, helper or error below.
class PishroTextField extends StatelessWidget {
  const PishroTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.suffix,
    this.keyboardType,
    this.obscure = false,
    this.enabled = true,
    this.maxLength,
    this.onChanged,
    this.textInputAction,
    this.inputFormatters,
    this.autofocus = false,
  });

  /// Phone entry: numeric keyboard, 11 digits, Persian digits normalised to
  /// ASCII on the way out so the API never sees «۰۹۱۲…».
  factory PishroTextField.phone({
    Key? key,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) => PishroTextField(
    key: key,
    label: 'شماره موبایل',
    controller: controller,
    hint: '۰۹۱۲۳۴۵۶۷۸۹',
    errorText: errorText,
    enabled: enabled,
    keyboardType: TextInputType.phone,
    maxLength: 11,
    inputFormatters: [_PersianDigitNormaliser()],
    onChanged: onChanged,
  );

  /// Amount entry with a «تومان» suffix and live thousands grouping.
  factory PishroTextField.amount({
    Key? key,
    required String label,
    TextEditingController? controller,
    String? helper,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) => PishroTextField(
    key: key,
    label: label,
    controller: controller,
    hint: '۱۰۰٬۰۰۰٬۰۰۰',
    helper: helper,
    errorText: errorText,
    suffix: 'تومان',
    keyboardType: TextInputType.number,
    inputFormatters: [_PersianDigitNormaliser()],
    onChanged: onChanged,
  );

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? errorText;
  final String? suffix;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool enabled;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.bodySmall.copyWith(
            color: enabled ? c.textSecondary : c.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Space.s2),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          autofocus: autofocus,
          onChanged: onChanged,
          style: context.text.bodyMedium.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            errorText: null, // rendered below so the layout never jumps
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s3),
                    child: Text(
                      suffix!,
                      style: context.text.bodySmall.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0),
            enabledBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.input),
                    borderSide: BorderSide(color: c.danger),
                  )
                : null,
          ),
        ),
        if (hasError || helper != null) ...[
          const SizedBox(height: Space.s1 + 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasError) ...[
                Icon(Icons.close_rounded, size: 14, color: c.danger),
                const SizedBox(width: Space.s1),
              ],
              Expanded(
                child: Text(
                  hasError ? errorText! : helper!,
                  style: context.text.caption.copyWith(
                    color: hasError ? c.danger : c.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Persian/Arabic-Indic keyboards emit non-ASCII digits. Normalising at the
/// input boundary means every downstream consumer — validators, API bodies —
/// only ever deals with ASCII.
class _PersianDigitNormaliser extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalised = Fmt.toAscii(newValue.text);
    if (normalised == newValue.text) return newValue;
    return TextEditingValue(
      text: normalised,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}
