import 'package:bookapp_customer/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A reusable form header text widget with consistent styling.
class FormHeaderTextWidget extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;

  const FormHeaderTextWidget({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.colorText,
      ),
    );
  }
}
