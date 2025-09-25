import 'dart:convert';
import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/features/account/models/user_model.dart';
import 'package:bookapp_customer/utils/shared_prefs_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http show post;
import 'package:bookapp_customer/network_service/http_headers.dart';

class AuthAndNetworkService {
  static final AuthAndNetworkService _instance =
      AuthAndNetworkService._internal();
  factory AuthAndNetworkService() => _instance;
  AuthAndNetworkService._internal();

  static String? _token;
  static UserModel? _user;

  /// Get current token
  static String? get token => _token;
  static UserModel? get user => _user;

  /// Notifier to listen for login state changes
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(
    _token != null,
  );

  /// Set token and update login status notifier
  static set token(String? value) {
    _token = value;
    isLoggedIn.value = value != null;
  }

  /// Return headers with authorization if token exists
  static Map<String, String> getHeaders() {
    return HttpHeadersHelper.auth();
  }

  /// Load saved token from shared preferences on app startup
  static Future<void> loadToken() async {
    _token = await SharedPrefsManager.getToken();
    isLoggedIn.value = _token != null;
  }

  /// Clear token and logout user
  static Future<void> logOut() async {
    await SharedPrefsManager.clearToken();
    _token = null;
    _user = null;
    isLoggedIn.value = false;
  }

  static Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(Urls.loginUrl),
      body: {'username': username, 'password': password},
      headers: getHeaders(),
    );

    try {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success' && data['token'] != null) {
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);
        await SharedPrefsManager.saveToken(_token!);
        await saveUserToStorage(_user!);
        isLoggedIn.value = true;
        return null;
      } else {
        return data['message'] ?? 'Login failed';
      }
    } catch (e) {
      debugPrint("Login parse error: $e, body: ${response.body}");
      return "Invalid server response";
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Urls.changePasswordUrl),
        headers: getHeaders(),
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Password change failed $e'};
    }
  }

  static Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Urls.signUpUrl),
        headers: getHeaders(),
        body: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'SignUp failed: $e'};
    }
  }

  static Future<UserModel?> getUserFromStorage() async {
    try {
      final savedUserJson = await SharedPrefsManager.getUser();
      if (savedUserJson != null) {
        _user = UserModel.fromJson(jsonDecode(savedUserJson));
        return _user;
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
    return null;
  }

  static Future<void> saveUserToStorage(UserModel user) async {
    await SharedPrefsManager.saveUser(jsonEncode(user.toJson()));
    _user = user;
  }
}
