import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/form_header_text_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/network_app_logo.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';

enum PasswordChangeFlow { change, reset }

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({
    super.key,
    this.flow = PasswordChangeFlow.change,
    this.email,
    this.code,
  });

  final PasswordChangeFlow flow;
  final String? email;
  final String? code;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _PasswordChangeProvider(flow: flow, email: email, code: code),
      child: Consumer<_PasswordChangeProvider>(
        builder: (context, p, _) {
          Future<void> submit() async {
            final ok = await p.submit(context.read<AuthProvider>());
            if (ok && context.mounted) {
              if (flow == PasswordChangeFlow.change) {
                Navigator.pop(context);
              } else {
                Get.offAllNamed(AppRoutes.resetSuccess);
              }
            }
          }

          return Scaffold(
            body: Stack(
              children: [
                Form(
                  key: p.formKey,
                  child: Column(
                    children: [
                      CustomAppBar(
                        title: p.isChange ? 'Change Password' : 'Reset Password',
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              Align(child: NetworkAppLogo(width: 160, height: 24)),
                              const SizedBox(height: 16),
                              Align(
                                child: Text(
                                  p.isChange
                                      ? 'Change Password'.tr
                                      : 'Create a new password for your account.'.tr,
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (p.isChange) ...[
                                FormHeaderTextWidget(text: 'Current Password'.tr),
                                const SizedBox(height: 4),
                                p.buildField(p.currentPasswordController, 'Current Password'.tr),
                                const SizedBox(height: 16),
                              ],
                              FormHeaderTextWidget(text: 'New Password'.tr),
                              const SizedBox(height: 4),
                              p.buildField(p.newPasswordController, 'New Password'.tr),
                              const SizedBox(height: 16),
                              FormHeaderTextWidget(text: 'Confirm New Password'.tr),
                              const SizedBox(height: 4),
                              p.buildField(p.confirmNewPasswordController, 'Confirm New Password'.tr),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: p.isLoading ? null : submit,
                                child: Text(p.isChange ? 'Submit'.tr : 'Reset Password'.tr),
                              ),
                              if (p.error != null) ...[
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    p.error!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (p.isLoading)
                  Container(
                    color: Colors.white.withAlpha(100),
                    child: const Center(child: CustomCPI()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PasswordChangeProvider extends ChangeNotifier {
  _PasswordChangeProvider({
    required this.flow,
    required this.email,
    required this.code,
  });
  final PasswordChangeFlow flow;
  final String? email;
  final String? code;

  final formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKeyRef => formKey;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;
  String? error;
  bool get isChange => flow == PasswordChangeFlow.change;

  TextFormField buildField(TextEditingController c, String hint) {
    return TextFormField(
      obscureText: !isPasswordVisible,
      controller: c,
      textInputAction: TextInputAction.next,
      validator: (value) => value != null && value.length >= 6
          ? null
          : 'Input minimum 6 characters'.tr,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        suffixIcon: IconButton(
          onPressed: () {
            isPasswordVisible = !isPasswordVisible;
            notifyListeners();
          },
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Future<bool> submit(AuthProvider auth) async {
    if (!formKey.currentState!.validate()) return false;
    error = null;
    isLoading = true;
    notifyListeners();
    try {
      if (isChange) {
        final response = await AuthAndNetworkService.changePassword(
          currentPassword: currentPasswordController.text.trim(),
          newPassword: newPasswordController.text.trim(),
          newPasswordConfirmation: confirmNewPasswordController.text.trim(),
        );
        final success = response['success'] == true || response['status'] == true;
        final message = (response['message'] as String?) ?? 'Unexpected response';
        if (success) {
          CustomSnackBar.show(Get.context!, message);
          return true;
        } else {
          error = message;
          return false;
        }
      } else {
        if (email == null || code == null || email!.isEmpty || code!.isEmpty) {
          error = 'Missing reset credentials'.tr;
          return false;
        }
        final msg = await auth.resetPassword(
          email: email!,
          code: code!,
          newPassword: newPasswordController.text.trim(),
          confirmPassword: confirmNewPasswordController.text.trim(),
        );
        CustomSnackBar.show(Get.context!, msg);
        return true;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }
}
