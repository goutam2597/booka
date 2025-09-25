import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_details_model.dart';

/// UI-only provider for vendor details screen (selected category index + derived lists).
class VendorDetailsUiProvider extends ChangeNotifier {
  int _selectedCategoryIndex = 0;
  List<String> _categories = const ['All'];
  bool _hydrated = false;

  int get selectedCategoryIndex => _selectedCategoryIndex;
  List<String> get categories => _categories;
  bool get didHydrate => _hydrated;

  void hydrateFrom(VendorDetailsModel details) {
    if (_hydrated) return; // prevent repeated hydration & build-phase churn
    final cats = details.services.map((e) => e.categoryName).toSet().toList()
      ..sort();
    _categories = ['All', ...cats];
    if (_selectedCategoryIndex >= _categories.length) {
      _selectedCategoryIndex = 0;
    }
    _hydrated = true;
    notifyListeners();
  }

  void setSelected(int i) {
    if (i == _selectedCategoryIndex) return;
    _selectedCategoryIndex = i;
    notifyListeners();
  }
}