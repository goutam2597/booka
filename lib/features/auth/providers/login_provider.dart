import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/providers/session_provider.dart';

/// Provider handling the login form state (previously inside a StatefulWidget)
/// Logic sequence preserved: validate -> call login -> error/success callback.
class LoginProvider extends ChangeNotifier {
  final SessionProvider sessionProvider;
  LoginProvider({required this.sessionProvider});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<bool> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    errorMessage = null;
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Please enter email and password';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    try {
      final error = await sessionProvider.login(email, password);
      if (error == null) {
        return true;
      } else {
        errorMessage = error;
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
