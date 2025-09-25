import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:bookapp_customer/network_service/core/profile_network_service.dart';
import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/features/account/models/user_model.dart';

class SessionProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  SessionProvider() {
    _loadSession();
  }

  // GETTERS
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;

  /// Load saved session on startup
  Future<void> _loadSession() async {
    _token = AuthAndNetworkService.token;
    _user = await AuthAndNetworkService.getUserFromStorage();
    notifyListeners();
  }

  /// LOGIN
  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final error = await AuthAndNetworkService.login(username, password);

    if (error == null) {
      _token = AuthAndNetworkService.token;
      _user = AuthAndNetworkService.user;
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
    return error;
  }

  /// LOGOUT
  Future<void> logout() async {
    await AuthAndNetworkService.logOut();
    _token = null;
    _user = null;
    notifyListeners();
  }

  /// Refresh profile data from API
  Future<void> refreshProfile() async {
    final response = await ProfileNetworkService.getProfile();
    if (response['success'] == true) {
      final data = response['data'];
      _user = UserModel.fromJson(data);
      await AuthAndNetworkService.saveUserToStorage(_user!);
      notifyListeners();
    }
  }
}
