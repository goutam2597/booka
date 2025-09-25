
import 'package:flutter/material.dart';
import 'package:bookapp_customer/network_service/core/forget_pass_network_service.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  ForgotPasswordProvider(this._service);

  final ForgetPassNetworkService _service;

  final emailController = TextEditingController();
  bool loading = false;
  String? error;
  String? lastMessage;

  Future<String?> sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      error = 'Enter Your Email Address';
      notifyListeners();
      return error;
    }
    loading = true;
    error = null;
    lastMessage = null;
    notifyListeners();
    try {
      final msg = await _service.sendOtp(email: email);
      lastMessage = msg;
      return msg;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
