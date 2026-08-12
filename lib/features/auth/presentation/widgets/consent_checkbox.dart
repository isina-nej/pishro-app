import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';

/// FORM/CHECKBOX · CONSENT — «هیچ‌کدام پیش‌فرض تیک‌خورده نیست».
///
/// Three states in the deck: unchecked, checked, and «الزامی — تأیید نشده»
/// (required but still unticked after a submit attempt), which is drawn in the
/// danger tone.
class ConsentCheckbox extends StatelessWidget {
  const ConsentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.showRequired = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  /// Marks the row as an unmet requirement after a blocked submit.
  final bool showRequired;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final missing = showRequired && !value;

    return Semantics(
      checked: value,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Container(
          constraints: const BoxConstraints(minHeight: Layout.minTapTarget),
          padding: const EdgeInsets.symmetric(vertical: Space.s1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: value ? c.actionPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.xs),
                  border: Border.all(
                    color: value
                        ? c.actionPrimary
                        : (missing ? c.danger : c.actionDisabled),
                    width: 1.5,
                  ),
                ),
                child: value
                    ? Icon(Icons.check_rounded, size: 14, color: c.onAction)
                    : null,
              ),
              const SizedBox(width: Space.s2 + 2),
              Expanded(
                child: Text(
                  label,
                  style: context.text.caption.copyWith(
                    color: missing ? c.danger : c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
