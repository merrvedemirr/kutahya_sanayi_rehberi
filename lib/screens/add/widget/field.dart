import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';

class Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final bool? requireds;
  final TextInputType keyboard;
  final int maxLines;

  const Field({
    super.key,
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.requireds,
    required this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelUppercase.copyWith(fontSize: 10)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(hintText: hint),
          validator: requireds ?? false
              ? (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bu alan zorunlu' : null
              : null,
        ),
      ],
    );
  }
}
