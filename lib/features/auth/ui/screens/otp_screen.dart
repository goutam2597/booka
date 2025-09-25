import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/features/auth/ui/screens/reset_password.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatelessWidget {
  final String email;
  OtpScreen({super.key, required this.email});

  final TextEditingController _otpController = TextEditingController();

  Future<void> _goToReset(BuildContext context, String code) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CustomCPI()),
    );
    await Future.delayed(const Duration(milliseconds: 600));
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      Get.to(() => ResetPassword(email: email, code: code.trim()));
    }
  }

  void _toast(BuildContext context, String msg, {bool success = false}) {
    CustomSnackBar.show(context, msg, title: success ? 'Success' : 'Error');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final resending = auth.resendingOtp;
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Forget Password'),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 150),
                    Text('Enter OTP'.tr, style: AppTextStyles.headingMedium),
                    const SizedBox(height: 8),
                    Text(
                      'A 6 Digit OTP has been sent to your email address'.tr,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Pinput(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        length: 6,
                        controller: _otpController,
                        autofocus: true,
                        defaultPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        onCompleted: (code) async {
                          if (code.trim().isEmpty) {
                            _toast(context, 'Please enter the OTP');
                            return;
                          }
                          FocusScope.of(context).unfocus();
                          await _goToReset(context, code);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: resending
                          ? null
                          : () async {
                              try {
                                final msg = await auth.sendOtp(
                                  email,
                                  isResend: true,
                                );
                                if (!context.mounted) return;
                                _toast(context, msg, success: true);
                              } catch (e) {
                                _toast(context, e.toString());
                              }
                            },
                      child: Text(resending ? 'Sending…'.tr : 'Resend OTP'.tr),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
