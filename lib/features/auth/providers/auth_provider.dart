import 'dart:async';
import 'package:bookapp_customer/network_service/core/forget_pass_network_service.dart';
import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:bookapp_customer/network_service/core/dashboard_network_service.dart';
import 'package:bookapp_customer/features/account/models/dashboard_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _loggedIn = AuthAndNetworkService.isLoggedIn.value;
    AuthAndNetworkService.isLoggedIn.addListener(_onLoginToggle);
    if (_loggedIn) {
      _loadDashboard();
    }
  }

  bool _loggedIn = false;
  bool get isLoggedIn => _loggedIn;

  DashboardModel? _dashboard;
  DashboardModel? get dashboard => _dashboard;

  bool _loadingDashboard = false;
  bool get loadingDashboard => _loadingDashboard;

  int _avatarVersion = 0; // for cache-busting avatars
  int get avatarVersion => _avatarVersion;
  void bumpAvatarVersion() {
    _avatarVersion++;
    notifyListeners();
  }

  void _onLoginToggle() {
    final v = AuthAndNetworkService.isLoggedIn.value;
    if (v != _loggedIn) {
      _loggedIn = v;
      if (_loggedIn) {
        _loadDashboard();
      } else {
        _dashboard = null;
      }
      notifyListeners();
    }
  }

  Future<void> _loadDashboard() async {
    if (_loadingDashboard) return;
    _loadingDashboard = true;
    notifyListeners();
    try {
      _dashboard = await DashboardNetworkService.getDashboardData();
    } catch (_) {
      _dashboard = null;
    } finally {
      _loadingDashboard = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() => _loadDashboard();

  Future<void> refreshSession() async {
    if (!_loggedIn && AuthAndNetworkService.isLoggedIn.value) {
      _onLoginToggle();
    }
    if (_loggedIn) {
      await _loadDashboard();
    }
  }

  Future<void> logout() async {
    await AuthAndNetworkService.logOut();
  }

  final ForgetPassNetworkService _service;

  bool _sendingOtp = false;
  bool _resendingOtp = false;
  bool _resetting = false;

  bool get sendingOtp => _sendingOtp;
  bool get resendingOtp => _resendingOtp;
  bool get resetting => _resetting;

  /// Send OTP to email
  Future<String> sendOtp(String email, {bool isResend = false}) async {
    if (isResend) {
      _resendingOtp = true;
    } else {
      _sendingOtp = true;
    }
    notifyListeners();
    try {
      final msg = await _service.sendOtp(email: email);
      return msg;
    } finally {
      if (isResend) {
        _resendingOtp = false;
      } else {
        _sendingOtp = false;
      }
      notifyListeners();
    }
  }

  /// Reset password
  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _resetting = true;
    notifyListeners();
    try {
      final msg = await _service.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return msg;
    } finally {
      _resetting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    AuthAndNetworkService.isLoggedIn.removeListener(_onLoginToggle);
    super.dispose();
  }
}
