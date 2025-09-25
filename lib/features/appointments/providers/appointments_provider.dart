import 'dart:async';

import 'package:bookapp_customer/features/appointments/models/appointment_model.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_model.dart';
import 'package:bookapp_customer/network_service/core/appointments_service.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:bookapp_customer/network_service/core/vendor_network_service.dart';
import 'package:flutter/cupertino.dart';

class AppointmentsProvider extends ChangeNotifier {
  List<VendorModel> _vendors = [];
  List<AppointmentModel> _appointments = [];

  bool _loadingVendors = false;
  bool _loadingAppointments = false;
  String? _errorMessage;

  Timer? _pollingTimer;

  // Public getters
  List<VendorModel> get vendors => _vendors;
  List<AppointmentModel> get appointments => _appointments;

  bool get loadingVendors => _loadingVendors;
  bool get loadingAppointments => _loadingAppointments;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => AuthAndNetworkService.isLoggedIn.value;
  bool get isEmpty => _appointments.isEmpty;

  AppointmentsProvider() {
    AuthAndNetworkService.isLoggedIn.addListener(_onLoginChanged);
    _bootIfLoggedIn();
  }

  void _onLoginChanged() {
    if (!isLoggedIn) {
      _stopPolling();
      _vendors = [];
      _appointments = [];
      notifyListeners();
    } else {
      _bootIfLoggedIn();
    }
  }

  Future<void> _bootIfLoggedIn() async {
    if (!isLoggedIn) return;
    await refreshVendors();
    await refreshAppointments();
    _startPolling();
  }

  Future<void> refreshVendors() async {
    if (!isLoggedIn) return;
    _loadingVendors = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vendors = await VendorNetworkService.getVendorList();
    } catch (e) {
      _errorMessage = 'Failed to load vendors';
      _vendors = [];
    } finally {
      _loadingVendors = false;
      notifyListeners();
    }
  }

  Future<void> refreshAppointments() async {
    if (!isLoggedIn) return;
    _loadingAppointments = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await AppointmentsService.getAppointments();
    } catch (e) {
      _errorMessage = 'Failed to load appointments';
      _appointments = [];
    } finally {
      _loadingAppointments = false;
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      refreshAppointments();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> onLanguageChanged() async {
    if (!isLoggedIn) return;
    _stopPolling();
    await refreshVendors();
    await refreshAppointments();
    _startPolling();
  }

  String _adminNameFromVendors() {
    if (_vendors.isEmpty) return 'Admin';

    VendorModel? adminVendor;
    try {
      adminVendor = _vendors.firstWhere(
        (v) => (v.username).trim().toLowerCase() == 'admin',
      );
    } catch (_) {
      adminVendor = null;
    }

    String fromAdmin(VendorModel v) {
      final parts = <String>[
        (v.admin?.firstName ?? '').trim(),
        (v.admin?.lastName ?? '').trim(),
      ].where((p) => p.isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.join(' ');
      final u = (v.admin?.username ?? '').trim();
      if (u.isNotEmpty) return u;
      return 'Admin';
    }

    if (adminVendor != null) {
      return fromAdmin(adminVendor);
    }

    for (final v in _vendors) {
      final label = fromAdmin(v);
      if (label != 'Admin') return label;
    }

    return 'Admin';
  }

  String vendorNameById(String vendorId) {
    final idStr = vendorId.trim();

    // Special-case: vendorId == '0' means platform/admin bookings
    if (idStr == '0') {
      return _adminNameFromVendors();
    }

    if (_vendors.isEmpty) {
      // No data yet; return a sensible fallback
      return 'Vendor #$idStr';
    }

    VendorModel? v;
    try {
      v = _vendors.firstWhere((e) => e.id.toString() == idStr);
    } catch (_) {
      v = null;
    }

    if (v != null) {
      final label = v.labelPreferUsername.trim();
      if (label.isNotEmpty) return label;

      final adminUname = (v.admin?.username ?? '').trim();
      if (adminUname.isNotEmpty) return adminUname;
    }

    return 'Vendor #$idStr';
  }

  @override
  void dispose() {
    _stopPolling();
    AuthAndNetworkService.isLoggedIn.removeListener(_onLoginChanged);
    super.dispose();
  }
}
