import 'package:flutter/widgets.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';

class BillingProvider extends ChangeNotifier {
  BillingProvider({required this.service, required this.readAuth}) {
    _attachAuthListener();
  }

  final ServicesModel service;
  final AuthProvider Function() readAuth;

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final zipCodeController = TextEditingController();
  final countryController = TextEditingController();

  bool loading = true;
  bool _initialPopulationDone = false;
  bool _disposed = false;
  bool _refreshingProfile = false;

  Map<String, String> _lastPopulated = const {};

  void _attachAuthListener() {
    // Delay to ensure AuthProvider available.
    Future.microtask(() {
      if (_disposed) return;
      try {
        readAuth().addListener(_handleAuthChange);
        _handleAuthChange();
      } catch (_) {}
    });
  }

  Future<void> _populateFromStoredUser() async {
    try {
      final user = await AuthAndNetworkService.getUserFromStorage();
      if (user != null) {
        fullNameController.text = user.name;
        phoneController.text = user.phone ?? '';
        emailController.text = user.email;
        addressController.text = user.address ?? '';
        zipCodeController.text = user.zipCode ?? '';
        countryController.text = user.country ?? '';
        _lastPopulated = _currentControllerData();
      }
    } finally {
      loading = false;
      _initialPopulationDone = true;
      if (!_disposed) notifyListeners();
    }
  }

  void _clearFieldsForGuest() {
    fullNameController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    zipCodeController.clear();
    countryController.clear();
  }

  void _handleAuthChange() {
    if (_disposed) return;
    final auth = readAuth();
    final loggedIn = auth.isLoggedIn;
    if (!loggedIn) {
      // Transitioned to logged out: clear any previously populated user data.
      _clearFieldsForGuest();
      loading = false; // ensure UI shows editable empty form
      _initialPopulationDone = true; // avoid repopulation until next login
      notifyListeners();
    } else {
      // Logged in: repopulate only if we haven't populated yet OR form is empty.
      final formEmpty =
          fullNameController.text.isEmpty &&
          emailController.text.isEmpty &&
          phoneController.text.isEmpty;
      if (!_initialPopulationDone || formEmpty) {
        loading = true;
        notifyListeners();
        _populateFromStoredUser();
      } else {
        // Maybe profile updated: attempt soft refresh without overwriting user manual edits
        _maybeRefreshProfile();
      }
    }
  }

  Map<String, String> _currentControllerData() => {
    'fullName': fullNameController.text,
    'phoneNumber': phoneController.text,
    'email': emailController.text,
    'address': addressController.text,
    'zipCode': zipCodeController.text,
    'country': countryController.text,
  };

  Future<void> _maybeRefreshProfile() async {
    if (_refreshingProfile) return;
    _refreshingProfile = true;
    try {
      final user = await AuthAndNetworkService.getUserFromStorage();
      if (user == null) return; // nothing to refresh

      final newData = <String, String>{
        'fullName': user.name,
        'phoneNumber': user.phone ?? '',
        'email': user.email,
        'address': user.address ?? '',
        'zipCode': user.zipCode ?? '',
        'country': user.country ?? '',
      };

      // Determine if any field changed compared to the last populated snapshot.
      bool changed = false;
      newData.forEach((k, v) {
        if (_lastPopulated[k] != v) changed = true;
      });
      if (!changed) return; // no profile change

      // Only update fields the user has NOT modified since last population.
      final current = _currentControllerData();
      bool userEdited = false;
      current.forEach((k, v) {
        final last = _lastPopulated[k];
        if (last != null && last != v) {
          userEdited = true; // user changed at least one field manually
        }
      });

      // Strategy: if user edited anything, do not overwrite their entries; else repopulate.
      if (!userEdited) {
        fullNameController.text = newData['fullName']!;
        phoneController.text = newData['phoneNumber']!;
        emailController.text = newData['email']!;
        addressController.text = newData['address']!;
        zipCodeController.text = newData['zipCode']!;
        countryController.text = newData['country']!;
        _lastPopulated = _currentControllerData();
        if (!_disposed) notifyListeners();
      }
    } catch (_) {
      // swallow silently
    } finally {
      _refreshingProfile = false;
    }
  }

  /// Public API to force clearing when user chooses guest checkout explicitly.
  void markAsGuest() {
    _clearFieldsForGuest();
    notifyListeners();
  }

  int calculateTotalAmount() {
    final priceString = service.price.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(priceString) ?? 0;
  }

  Map<String, String> collectBillingDetails() => {
    'fullName': fullNameController.text,
    'phoneNumber': phoneController.text,
    'email': emailController.text,
    'address': addressController.text,
    'zipCode': zipCodeController.text,
    'country': countryController.text,
  };

  @override
  void dispose() {
    _disposed = true;
    try {
      readAuth().removeListener(_handleAuthChange);
    } catch (_) {}
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    zipCodeController.dispose();
    countryController.dispose();
    super.dispose();
  }
}
