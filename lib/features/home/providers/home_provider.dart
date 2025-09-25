import 'package:bookapp_customer/features/home/data/models/home_models.dart';
import 'package:bookapp_customer/features/services/data/models/category_model.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_model.dart';
import 'package:bookapp_customer/network_service/core/home_network_service.dart';
import 'package:flutter/cupertino.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(this._service);
  final HomeNetworkService _service;

  bool _isLoading = false;
  String? _error;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Data Service
  List<ServicesModel> _services = [];
  List<ServicesModel> _featuredServices = [];
  List<CategoryModel> _categories = [];
  List<VendorModel> _featuredVendors = [];
  SectionContent? _sections;

  List<ServicesModel> get services => _services;
  List<ServicesModel> get featuredServices => _featuredServices;
  List<CategoryModel> get categories => _categories;
  List<VendorModel> get featuredVendors => _featuredVendors;
  SectionContent? get sections => _sections;

  // Ui States

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  List<ServicesModel> get popularServices {
    if (_selectedCategory == 'All') return _services;
    return _services.where((s) => s.categoryName == _selectedCategory).toList();
  }

  Future<void> fetchInitial() async {
    _setLoading(true);
    _error = null;
    try {
      final home = await _service.getHome();
      _applyHome(home);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    try {
      final home = await _service.getHome();
      _applyHome(home, keepSelectedCategory: true);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void selectCategory(String categoryName) {
    if (_selectedCategory == categoryName) return;
    _selectedCategory = categoryName;
    notifyListeners();
  }

  void _applyHome(HomeResponse data, {bool keepSelectedCategory = false}) {
    _services = data.latestServices;
    _featuredServices = data.featuredServices;
    _categories = data.categories;
    _featuredVendors = data.featuredVendors;
    _sections = data.sectionContent;

    if (!keepSelectedCategory) {
      _selectedCategory = 'All';
    }
    notifyListeners();
  }

  /// Re-fetch home data (used when language changes)
  Future<void> onLanguageChanged() async {
    await fetchInitial();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
