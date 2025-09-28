import 'package:bookapp_customer/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextNButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? actionText;
  final IconData icon;
  final double size;

  const TextNButtonWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.actionText,
    this.icon = Icons.keyboard_arrow_right,
    this.size = 20,
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

        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Text(
                  (actionText ?? 'View All').tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.secondaryColor,
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: size, color: AppColors.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
