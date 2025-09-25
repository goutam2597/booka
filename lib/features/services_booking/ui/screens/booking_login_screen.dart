import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/services_booking/providers/booking_login_provider.dart';
import 'package:get/get.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_header_text_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/form_header_text_widget.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';

/// BookingLoginScreen: Used in booking flow for login or guest checkout.
class BookingLoginScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final StaffModel? selectedStaff;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;

  const BookingLoginScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    this.selectedStaff,
    this.selectedDate,
    this.selectedTimeSlot,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingLoginProvider(),
      builder: (context, _) {
        final p = context.watch<BookingLoginProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onBack();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Screen Header
                Center(child: const CustomHeaderTextWidget(text: 'Login')),
                const SizedBox(height: 16),
                // Guest Checkout Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      maximumSize: const Size(304, 44),
                      backgroundColor: Colors.white,
                      textStyle:  TextStyle(color: AppColors.primaryColor),
                    ),
                    onPressed: onNext,
                    child:  Text(
                      'Proceed As Guest Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const FormHeaderTextWidget(text: 'Username*'),
                const SizedBox(height: 4),
                TextField(
                  controller: p.usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    hintText: 'Enter Username',
                  ),
                ),
                SizedBox(height: 16),
                const FormHeaderTextWidget(text: 'Password*'),
                const SizedBox(height: 4),
                TextField(
                  obscureText: !p.isPasswordVisible,
                  controller: p.passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    hintText: 'Enter password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        p.togglePasswordVisibility();
                      },
                      icon: Icon(
                        p.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: p.isLoading
                      ? null
                      : () async {
                          final ok = await p.login();
                          if (ok) onNext();
                        },
                  child: const Text('Login'),
                ),

                SizedBox(height: 8),
                if (p.error != null)
                  Center(
                    child: Text(
                      p.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.signup),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
