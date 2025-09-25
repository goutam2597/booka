import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/features/auth/providers/forgot_password_provider.dart';
import 'package:bookapp_customer/features/auth/ui/screens/otp_screen.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/form_header_text_widget.dart';
import 'package:bookapp_customer/network_service/core/forget_pass_network_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EmailScreen extends StatelessWidget {
  const EmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordProvider(ForgetPassNetworkService()),
      child: Consumer<ForgotPasswordProvider>(
        builder: (context, p, _) {
          void toast(String msg, {bool success = false}) {
            CustomSnackBar.show(
              context,
              msg,
              title: success ? 'Success' : 'Error',
            );
          }

          Future<void> send() async {
            FocusScope.of(context).unfocus();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CustomCPI()),
            );
            final msg = await p.sendOtp();
            await Future.delayed(const Duration(milliseconds: 400));
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            if (msg != null && p.error == null && context.mounted) {
              toast(msg, success: true);
              Get.to(() => OtpScreen(email: p.emailController.text.trim()));
            } else if (p.error != null) {
              toast(p.error!);
            }
          }

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
                          Text(
                            'Reset Password'.tr,
                            style: AppTextStyles.headingMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter the account that you want to reset the password'
                                .tr,
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 32),
                          FormHeaderTextWidget(
                            text: '${'Email'.tr}*',
                            fontSize: 16,
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: p.emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              hintText: 'Enter Email'.tr,
                            ),
                            onSubmitted: (_) => p.loading ? null : send(),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: p.loading ? null : send,
                            child: Text(
                              p.loading ? 'Sending…'.tr : 'Send OTP'.tr,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (p.error != null)
                            Center(
                              child: Text(
                                p.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
