import 'package:bookapp_customer/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextNButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const TextNButtonWidget({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.tr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),

        // "See All" gradient text button
        TextButton(
          onPressed: onTap,
          child: Text(
            'View All'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              foreground: Paint()
                ..shader =  LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
        ),
      ],
    );
  }
}
