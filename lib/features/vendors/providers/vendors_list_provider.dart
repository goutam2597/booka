import 'package:flutter/foundation.dart';

import 'package:bookapp_customer/features/vendors/models/vendor_model.dart';
import 'package:bookapp_customer/network_service/core/vendor_network_service.dart';

class VendorsListProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<VendorModel> _all = [];
  String _query = '';

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  List<VendorModel> get all => _all;

  List<VendorModel> get filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((v) {
      final name = v.username.toLowerCase();
      final country = v.country.toLowerCase();
      final rating = v.avgRating.toLowerCase();
      return name.contains(q) || country.contains(q) || rating.contains(q);
    }).toList();
  }

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await VendorNetworkService.getVendorList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> onLanguageChanged() async {
    await fetch();
  }
}

