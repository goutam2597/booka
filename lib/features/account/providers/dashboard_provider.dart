import 'package:bookapp_customer/features/account/models/dashboard_model.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:bookapp_customer/network_service/core/dashboard_network_service.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardModel? _dashboard;
  bool _isLoading = false;
  String? _error;
  String get _pageTitle => '';

  DashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => AuthAndNetworkService.isLoggedIn.value;

  DashboardProvider() {
    AuthAndNetworkService.isLoggedIn.addListener(_onLoginChanged);
    if (isLoggedIn) fetchDashboard();
  }

  void _onLoginChanged() {
    if (isLoggedIn) {
      fetchDashboard();
    } else {
      _dashboard = null;
      notifyListeners();
    }
  }

  String get pageTitle {
    if (_pageTitle.trim().isNotEmpty) return _pageTitle.trim();
    if (_pageTitle.isNotEmpty) {
      final title = _dashboard?.pageTitle.trim();
      if (title!.isNotEmpty) return title;
    }
    return '';
  }

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _dashboard = await DashboardNetworkService.getDashboardData();
    } catch (e) {
      _error = 'Failed to fetch dashboard data';
      _dashboard = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchDashboard();

  Future<void> onLanguageChanged() async {
    if (isLoggedIn) {
      await fetchDashboard();
    }
  }

  @override
  void dispose() {
    AuthAndNetworkService.isLoggedIn.removeListener(_onLoginChanged);
    super.dispose();
  }
}
