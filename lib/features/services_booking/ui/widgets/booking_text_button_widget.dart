import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable text button for booking navigation (Next/Previous Step)
/// Can show icon left or right. All colors and font weights customizable.
class BookingTextButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData icon;
  final bool iconRight;
  final Color? textColor;
  final Color? iconColor;
  final FontWeight? fontWeight;

  const BookingTextButtonWidget({
    super.key,
    required this.onTap,
    required this.text,
    required this.icon,
    this.iconRight = false,
    this.textColor,
    this.iconColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle buttonTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: textColor ?? Colors.grey.shade600,
    );

    // Compose button with icon on the left or right
    return TextButton(
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: iconRight
            ? [
                Text(text.tr, style: buttonTextStyle),
                const SizedBox(width: 4),
                Icon(icon, color: iconColor ?? Colors.grey.shade600, size: 22),
              ]
            : [
                Icon(icon, color: iconColor ?? Colors.grey.shade600, size: 22),
                const SizedBox(width: 4),
                Text(text.tr, style: buttonTextStyle),
              ],
      ),
    );
  }
}
