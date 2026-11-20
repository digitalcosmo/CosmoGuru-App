import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'stroke_icon.dart';
import 'tokens.dart';

/// Labelled text input in the site's form style (14px radius field).
class LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final String? trailing;
  final VoidCallback? onTap;
  final String? hint;
  final String? error;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final TextCapitalization capitalization;

  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.trailing,
    this.onTap,
    this.hint,
    this.error,
    this.maxLines = 1,
    this.keyboardType,
    this.autofillHints,
    this.capitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: T.cap),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: BoxConstraints(minHeight: maxLines > 1 ? 120 : 54),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
          alignment: maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hasError ? AppColors.red : AppColors.lineStrong, width: hasError ? 1.6 : 1),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  onTap: onTap,
                  maxLines: maxLines,
                  minLines: maxLines > 1 ? 4 : 1,
                  keyboardType: keyboardType,
                  autofillHints: autofillHints,
                  textCapitalization: capitalization,
                  textAlignVertical: TextAlignVertical.center,
                  style: T.body,
                  cursorColor: AppColors.red,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: T.body.copyWith(color: AppColors.tx3),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    filled: false,
                  ),
                ),
              ),
              if (trailing != null) StrokeIcon(trailing!, color: AppColors.red, size: 18),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(error!, style: T.small.copyWith(color: AppColors.red, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}
