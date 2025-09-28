import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/providers/session_provider.dart';
import 'package:bookapp_customer/features/auth/providers/login_provider.dart';
import 'package:bookapp_customer/features/auth/ui/screens/email_screen.dart';
import 'package:bookapp_customer/features/auth/ui/screens/signup_screen.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/form_header_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.redirectToHome = false});

  final bool redirectToHome;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginProvider>(
      create: (ctx) => LoginProvider(sessionProvider: ctx.read<SessionProvider>()),
      child: Consumer2<SessionProvider, LoginProvider>(
      builder: (context, session, login, _) {
        Future<void> doLogin() async {
          FocusScope.of(context).unfocus();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CustomCPI()),
          );
          final success = await login.submit();
          await Future.delayed(const Duration(milliseconds: 600));
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (success) {
            if (redirectToHome) {
              Get.offAllNamed(AppRoutes.bottomNav);
            } else {
              Get.back(result: true);
            }
          }
        }

        // If coming from a reset-success path with redirect flag, show a one-time banner.
        final showResetInfo = redirectToHome &&
            (login.emailController.text.isEmpty && login.passwordController.text.isEmpty);

        return Scaffold(
          body: Column(
            children: [
              const CustomAppBar(title: '', showSkip: true),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 150),
                        if (showResetInfo) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade400),
                            ),
                            child: Text(
                              'Password reset successfully. Please login with your new password.'.tr,
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Center(
                          child: Text(
                            'Login'.tr,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.colorText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        FormHeaderTextWidget(text: '${'Username'.tr} *'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: login.emailController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            hintText: 'Username'.tr,
                          ),
                        ),

                        const SizedBox(height: 16),

                        FormHeaderTextWidget(text: '${'Password'.tr} *'),
                        const SizedBox(height: 4),
                        TextField(
                          obscureText: login.obscurePassword,
                          controller: login.passwordController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) =>
                              login.isLoading ? null : doLogin(),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            hintText: 'Password'.tr,
                            suffixIcon: IconButton(
                              onPressed: login.togglePasswordVisibility,
                              icon: Icon(
                                login.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: login.isLoading ? null : doLogin,
                          child: Text(
                            login.isLoading ? 'Logging in…' : 'Login'.tr,
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (login.errorMessage != null)
                          Center(
                            child: Text(
                              login.errorMessage!.tr,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        TextButton(
                          onPressed: () {
                            Get.to(() => const EmailScreen());
                          },
                          child: Row(
                            children: [
                              Text('Lost your password'.tr),
                              _qmVisibility(context, AppColors.primaryColor),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account".tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            _qmVisibility(context, Colors.grey.shade600),
                            TextButton(
                              onPressed: () {
                                Get.to(() => const SignupScreen());
                              },
                              child: Row(children: [Text('Signup'.tr)]),
                            ),
                          ],
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
