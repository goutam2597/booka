import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/auth/providers/signup_provider.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/form_header_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: Consumer<SignupProvider>(
        builder: (context, p, _) {
          Future<void> doSignup() async {
            final resp = await p.submit();
            if (resp['success'] == true && context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text('Please verify your email'),
                  content: Text(resp['message'] ?? 'Verification email sent'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.signupSuccess);
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }

          return Scaffold(
            body: Column(
              children: [
                CustomAppBar(title: ''),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          Center(
                            child: Text(
                              'Signup'.tr,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.colorText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          FormHeaderTextWidget(text: '${'Username'.tr}*'),
                          const SizedBox(height: 4),
                          TextField(
                            controller: p.usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'Username'.tr,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FormHeaderTextWidget(text: '${'Email'.tr}*'),
                          const SizedBox(height: 4),
                          TextField(
                            controller: p.emailController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: '${'Enter Email'.tr}*',
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FormHeaderTextWidget(text: '${'Password'.tr}*'),
                          const SizedBox(height: 4),
                          TextField(
                            obscureText: !p.showPassword,
                            controller: p.passwordController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: '${'Enter Password'.tr}*',
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              suffixIcon: IconButton(
                                onPressed: p.togglePassword,
                                icon: Icon(
                                  p.showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FormHeaderTextWidget(
                              text: '${'Confirm Password'.tr}*'),
                          const SizedBox(height: 4),
                          TextField(
                            obscureText: !p.showPassword,
                            controller: p.confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: '${'Confirm Password'.tr}*',
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              suffixIcon: IconButton(
                                onPressed: p.togglePassword,
                                icon: Icon(
                                  p.showPassword
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: p.isLoading ? null : doSignup,
                            child: Text('Signup'.tr),
                          ),
                          SizedBox(height: 8),
                          if (p.error != null)
                            Center(
                              child: Text(
                                p.error!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              _qmVisibility(context, Colors.grey.shade600),
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text('Login Now'.tr),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (p.isLoading) const Center(child: CustomCPI()),
              ],
            ),
          );
        },
      ),
    );
  }

  Visibility _qmVisibility(BuildContext context, Color color) {
    return Visibility(
      visible: Directionality.of(context) == TextDirection.ltr,
      child: Text(
        " ?",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
