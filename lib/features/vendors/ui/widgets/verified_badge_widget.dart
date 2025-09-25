
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';

class VerifiedBadge extends StatelessWidget {
  final bool isVerified;
  const VerifiedBadge({super.key, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Verified User'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.verified, size: 18, color: Colors.blue),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Non Verified'.tr,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.cancel, size: 18, color: Colors.red),
      ],
    );
  }
}
