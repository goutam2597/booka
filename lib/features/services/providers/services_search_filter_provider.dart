import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/features/services/data/models/services_filter.dart';

class ServicesSearchFilterProvider extends ChangeNotifier {
  String? _category;
  String? _ratingKey = 'All';
  double _minPrice = 0;
  double _maxPrice = 100000;
  ServicesSort _sort = ServicesSort.relevance;
  bool _hydrated = false; // prevents duplicate / in-build hydration

  // Getters
  String? get category => _category;
  String? get ratingKey => _ratingKey;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  ServicesSort get sort => _sort;
  bool get didHydrate => _hydrated;

  void setCategory(String? v) {
    _category = (v == null || v == 'All') ? null : v;
    notifyListeners();
  }

  void setRatingKey(String key) {
    _ratingKey = key;
    notifyListeners();
  }

  void setPriceRange(double start, double end) {
    _minPrice = start;
    _maxPrice = end;
    notifyListeners();
  }

  void setSort(ServicesSort s) {
    _sort = s;
    notifyListeners();
  }

  void hydrateFromFilter(ServicesFilter f) {
    if (_hydrated) return; // already hydrated this lifecycle
    _category = f.category;
    _ratingKey = f.minRating?.toString() ?? 'All';
    _minPrice = f.minPrice ?? 0;
    _maxPrice = f.maxPrice ?? 100000;
    _sort = f.sort;
    _hydrated = true;
    notifyListeners();
  }

  ServicesFilter buildFilter() {
    final minR = (_ratingKey == null || _ratingKey == 'All')
        ? null
        : int.tryParse(_ratingKey!);
    return ServicesFilter(
      category: _category,
      minRating: minR,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      sort: _sort,
    );
  }

  void clear() {
    _category = null;
    _ratingKey = 'All';
    _minPrice = 0;
    _maxPrice = 100000;
    _sort = ServicesSort.relevance;
    _hydrated = false;
    notifyListeners();
  }
}
