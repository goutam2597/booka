import 'package:flutter/widgets.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';

class BookingLoginProvider extends ChangeNotifier {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? error;
  bool isPasswordVisible = false;

  Future<bool> login() async {
    error = null;
    final user = usernameController.text.trim();
    final pass = passwordController.text.trim();
    if (user.isEmpty || pass.isEmpty) {
      error = 'Please enter both username and password';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    final errorMessage = await AuthAndNetworkService.login(user, pass);
    if (errorMessage != null) {
      error = errorMessage;
      isLoading = false;
      notifyListeners();
      return false;
    }
    isLoading = false;
    notifyListeners();
    return true;
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
