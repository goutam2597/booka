
import 'package:flutter/material.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';

class SignupProvider extends ChangeNotifier {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  String? error;
  Map<String, dynamic>? lastResponse;

  void togglePassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  bool validateBasic() {
    error = null;
    if (usernameController.text.trim().isEmpty) {
      error = 'Enter your username';
    } else if (!emailController.text.contains('@')) {
      error = 'Invalid email';
    } else if (passwordController.text.length < 6) {
      error = 'Input minimum 6 characters';
    } else if (confirmPasswordController.text != passwordController.text) {
      error = 'Passwords do not match';
    }
    if (error != null) notifyListeners();
    return error == null;
  }

  Future<Map<String, dynamic>> submit() async {
    if (!validateBasic()) return {'success': false, 'message': error};
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final resp = await AuthAndNetworkService.signUp(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        passwordConfirmation: confirmPasswordController.text.trim(),
      );
      lastResponse = resp;
      if (resp['success'] != true) {
        error = (resp['message'] ?? 'Signup failed').toString();
      }
      return resp;
    } catch (e) {
      error = e.toString();
      return {'success': false, 'message': error};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
