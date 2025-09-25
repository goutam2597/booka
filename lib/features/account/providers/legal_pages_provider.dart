import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/network_service/core/custom_pages_service.dart';

/// Manages loading and caching of legal custom pages (Terms & Conditions, Privacy Policy)
/// per active language.
class LegalPagesProvider extends ChangeNotifier {
  LegalPagesProvider({required String languageCode})
    : _languageCode = languageCode;

  String _languageCode;
  String get languageCode => _languageCode;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  final Map<String, String> _pages = {};
  String? get termsHtml => _pages['terms'];
  String? get privacyHtml => _pages['privacy'];

  List<Map<String, dynamic>>? _raw;

  void onLanguageChanged(String code) {
    if (code == _languageCode) return;
    _languageCode = code;
    _pages.clear();
    _raw = null;
    _error = null;
    notifyListeners();
  }

  /// Ensure the given key is loaded: key must be 'terms' or 'privacy'.
  Future<void> ensureLoaded(String key) async {
    assert(key == 'terms' || key == 'privacy');
    if (_pages.containsKey(key) && (_pages[key]?.isNotEmpty ?? false)) {
      return;
    }
    await _loadInternal(key);
  }

  Future<void> refresh(String key) async {
    assert(key == 'terms' || key == 'privacy');
    await _loadInternal(key, force: true);
  }

  Future<void> _loadInternal(String key, {bool force = false}) async {
    if (_loading) return;
    // If already cached and not forced, exit to prevent flicker
    if (!force && (_pages[key]?.isNotEmpty ?? false)) {
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (force) _raw = null; // force refetch of the list
      _raw ??= await CustomPagesService.fetchPages();
      // Determine matching string(s)
      final matches = key == 'privacy'
          ? const ['privacy', 'policy']
          : const ['terms', 'condition'];
      Map<String, dynamic>? page;
      for (final m in matches) {
        page = CustomPagesService.pickPage(_raw!, targetTitleContains: m);
        if (page != null) break;
      }
      final html = (page?['content']?.toString().trim().isNotEmpty ?? false)
          ? page!['content']!.toString()
          : (page?['description']?.toString() ?? '').trim();
      _pages[key] = html;
    } catch (e) {
      _error = 'Failed to load content';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
