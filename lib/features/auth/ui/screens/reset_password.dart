import 'package:bookapp_customer/features/auth/ui/screens/password_change.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatelessWidget {
  final String email;
  final String code;
  const ResetPassword({super.key, required this.email, required this.code});

  @override
  Widget build(BuildContext context) {
    return ResetPasswordScreen(
      flow: PasswordChangeFlow.reset,
      email: email,
      code: code,
    );
  }
}
