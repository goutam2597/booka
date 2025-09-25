import 'package:bookapp_customer/features/services/data/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services/data/models/services_filter.dart';
import 'package:bookapp_customer/features/services/data/utils/num_parsers.dart';
import 'package:bookapp_customer/network_service/core/services_network_service.dart';

class ServicesProvider extends ChangeNotifier {
  final ServicesNetworkService _servicesApi = ServicesNetworkService();
  final int _loadBatchSize;

  ServicesProvider({int loadBatchSize = 10}) : _loadBatchSize = loadBatchSize;

  // ----- Backing lists
  List<ServicesModel> _all = [];
  List<ServicesModel> _displayed = [];
  List<ServicesModel> _searchResults = [];

  // Full, unfiltered categories from API (data.categories)
  List<CategoryModel> _allCategories = [];

  // ----- State
  bool _isLoading = false;
  bool _isSearchMode = false;
  ServicesFilter _filter = ServicesFilter.empty;

  // Single source of truth for the current query (used by all search bars)
  String _query = '';
  String get query => _query;

  // ----- Getters
  bool get isLoading => _isLoading;
  List<ServicesModel> get displayed => _displayed;
  ServicesFilter get filter => _filter;
  List<CategoryModel> get allCategories => _allCategories;

  /// Names prepared for the dialog chips (sorted + "All" first)
  List<String> get allCategoryNames {
    final names = _allCategories.map((c) => c.name).toSet().toList()..sort();
    return ['All', ...names];
  }

  /// Count of items in the active (search + filter) pool
  int get totalCount {
    final base = _activeBase();
    return _applyFilters(base).length;
  }

  /// Optional: direct access to featured from the current displayed pool
  List<ServicesModel> get featured =>
      _displayed.where((e) => e.isFeatured).toList();

  // ---------------------------
  // INIT & REFRESH
  // ---------------------------
  Future<void> init({bool forceRefresh = false}) async {
    if (_all.isNotEmpty && _allCategories.isNotEmpty && !forceRefresh) return;
    _reset();
    await _fetch(initialLoad: true);
  }

  Future<void> refresh() async {
    _reset();
    await _fetch(initialLoad: true);
  }

  /// Re-fetch services root on language change
  Future<void> onLanguageChanged() async {
    await refresh();
  }

  // ---------------------------
  // LOAD MORE (paginate active pool)
  // ---------------------------
  Future<void> loadMore() async {
    if (_isLoading) return;

    final fullActive = _applyFilters(_activeBase());
    final current = _displayed.length;
    if (current >= fullActive.length) return;

    _isLoading = true;
    notifyListeners();
    try {
      final next = fullActive.skip(current).take(_loadBatchSize).toList();
      _displayed = [..._displayed, ...next];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------
  // SEARCH (single source of truth)
  // ---------------------------
  void search(String keyword) {
    _query = keyword;
    final q = keyword.toLowerCase().trim();

    if (q.isEmpty) {
      _isSearchMode = false;
      _searchResults.clear();
      _repageFromScratch();
      return;
    }

    _isSearchMode = true;
    _searchResults = _all.where((s) {
      final name = s.name.toLowerCase();
      final address = (s.address ?? '').toLowerCase();
      final categories = (s.categoryName).toLowerCase();
      final rating = (s.averageRating ?? '').toLowerCase();
      final country = (s.vendor?.country ?? '').toLowerCase();
      return name.contains(q) ||
          address.contains(q) ||
          categories.contains(q) ||
          rating.contains(q) ||
          country.contains(q);
    }).toList();

    _repageFromScratch();
  }

  void clearSearch() {
    _query = '';
    _isSearchMode = false;
    _searchResults.clear();
    _repageFromScratch();
  }

  // ---------------------------
  // FILTER
  // ---------------------------
  void applyFilter(ServicesFilter newFilter) {
    _filter = newFilter;
    _repageFromScratch();
  }

  void clearFilter() {
    _filter = ServicesFilter.empty;
    _repageFromScratch();
  }

  // ---------------------------
  // INTERNALS
  // ---------------------------
  Future<void> _fetch({required bool initialLoad}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final root = await _servicesApi.getServicesRoot();
      final data = (root['data'] as Map<String, dynamic>? ?? {});

      final cats = (data['categories'] as List? ?? []);
      _allCategories = cats
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();

      final featured = (data['featuredServices'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ServicesModel.fromFeaturedJson)
          .toList();

      final services = (data['services'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ServicesModel.fromJson)
          .toList();

      _all = [...featured, ...services];

      if (initialLoad) {
        _isSearchMode = false;
        _searchResults.clear();
      }

      _repageFromScratch();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _reset() {
    _all = [];
    _displayed = [];
    _searchResults = [];
    _allCategories = [];
    _isSearchMode = false;
    _isLoading = false;
    _filter = ServicesFilter.empty;
    _query = '';
  }

  List<ServicesModel> _activeBase() => _isSearchMode ? _searchResults : _all;

  void _repageFromScratch() {
    final fullActive = _applyFilters(_activeBase());
    _displayed = fullActive.take(_loadBatchSize).toList();
    notifyListeners();
  }

  List<ServicesModel> _applyFilters(List<ServicesModel> list) {
    Iterable<ServicesModel> out = list;

    if (_filter.category != null && _filter.category!.isNotEmpty) {
      out = out.where((s) => s.categoryName == _filter.category);
    }

    if (_filter.minRating != null) {
      out = out.where(
        (s) => parseRating(s.averageRating).round() >= _filter.minRating!,
      );
    }

    if (_filter.minPrice != null) {
      out = out.where((s) => parsePrice(s.price) >= _filter.minPrice!);
    }
    if (_filter.maxPrice != null) {
      out = out.where((s) => parsePrice(s.price) <= _filter.maxPrice!);
    }

    final listOut = out.toList();

    // Sorting
    switch (_filter.sort) {
      case ServicesSort.priceLowToHigh:
        listOut.sort(
          (a, b) => parsePrice(a.price).compareTo(parsePrice(b.price)),
        );
        break;
      case ServicesSort.priceHighToLow:
        listOut.sort(
          (a, b) => parsePrice(b.price).compareTo(parsePrice(a.price)),
        );
        break;
      case ServicesSort.ratingHighToLow:
        listOut.sort(
          (a, b) => parseRating(
            b.averageRating,
          ).compareTo(parseRating(a.averageRating)),
        );
        break;
      case ServicesSort.newest:
        listOut.sort((a, b) => b.id.compareTo(a.id));
        break;
      case ServicesSort.relevance:
        listOut.sort((a, b) {
          if (a.isFeatured == b.isFeatured) return 0;
          return a.isFeatured ? -1 : 1;
        });
        break;
    }

    return listOut;
  }
}
