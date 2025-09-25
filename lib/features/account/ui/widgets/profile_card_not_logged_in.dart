import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileCardNotLoggedIn extends StatelessWidget {
  const ProfileCardNotLoggedIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Hello, Welcome to BookApp'.tr,
              style: AppTextStyles.bodyLargeGrey,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.login),
                        child: Text(
                          'Login'.tr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: AppColors.primaryColor,
                            width: 1,
                          ),
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.signup),
                        child: Text(
                          'Signup'.tr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
