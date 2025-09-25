import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';

class SignUpSuccess extends StatelessWidget {
  const SignUpSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, size: 120, color: AppColors.primaryColor),
                const SizedBox(height: 16),
                Text('Account Created!', style: AppTextStyles.headingLarge),
                const SizedBox(height: 8),
                Text(
                  'Your account has been created successfully.',
                  style: AppTextStyles.bodyLargeGrey,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              left: 60,
              right: 60,
              child: SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Get.offAllNamed(
                    AppRoutes.login,
                    arguments: {'redirectToHome': true},
                  ),
                  child: const Text('Go to Login'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
