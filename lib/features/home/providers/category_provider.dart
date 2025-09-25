import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/network_service/core/services_network_service.dart';


class CategoryProvider extends ChangeNotifier {
  final Map<String, List<ServicesModel>> _cache = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _error = {};

  List<ServicesModel>? get(String categoryName) => _cache[categoryName];
  bool loading(String categoryName) => _loading[categoryName] == true;
  String? error(String categoryName) => _error[categoryName];


  Future<void> fetch(String categoryName, {bool force = false}) async {
    if (!force && _cache.containsKey(categoryName) && _error[categoryName] == null) return;

    _loading[categoryName] = true;
    _error[categoryName] = null;
    notifyListeners();

    try {
      final all = await ServicesNetworkService().getServices();
      final filtered = all.allServices
          .where((s) => s.categoryName == categoryName)
          .toList();

      _cache[categoryName] = filtered;
    } catch (e) {
      _error[categoryName] = 'Failed to load services';
      _cache.remove(categoryName);
    } finally {
      _loading[categoryName] = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String categoryName) => fetch(categoryName, force: true);

  void invalidate(String categoryName) {
    _cache.remove(categoryName);
    _error.remove(categoryName);
    notifyListeners();
  }

  /// Clear all cached categories and errors (useful on language change)
  void invalidateAll() {
    _cache.clear();
    _error.clear();
    notifyListeners();
  }
}
