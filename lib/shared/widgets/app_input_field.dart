import 'package:flutter/material.dart';
import 'package:happer_app/core/constants/app_colors.dart';
import 'package:happer_app/core/constants/app_dimensions.dart';

class AppInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final int? maxLength;
  final TextAlign textAlign;
  final Color? borderColor;
  final FocusNode? focusNode;

  const AppInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.borderColor,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: borderColor ?? AppColors.border),
        color: AppColors.background,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              maxLength: maxLength,
              textAlign: textAlign,
              style: const TextStyle(fontSize: AppDimensions.fontL),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                counterText: '',
                hintStyle: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.64),
                  fontSize: AppDimensions.fontL,
                ),
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon!,
        ],
      ),
    );
  }
}
