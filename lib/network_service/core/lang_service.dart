import 'dart:convert';
import 'package:bookapp_customer/app/localization/arabic_tr.dart';
import 'package:get/get.dart';
import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LangService {
  LangService._();

  // Endpoint centralized in Urls
  static const _cachePrefix = 'i18n_cache_';

  static final Map<String, Map<String, String>> _maps = {};

  static Map<String, String> mapOf(String languageCode) {
    return _maps[languageCode] ?? const {};
  }

  static Future<void> ensureLoaded(String languageCode) async {
    final code = _normalize(languageCode);

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_cachePrefix$code');
    if (cached != null && cached.isNotEmpty) {
      try {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        _maps[code] = data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
        _injectIntoGetX(code, _maps[code]!);
      } catch (_) {}
    }

    try {
      final remote = await _fetchFromNetwork(code);
      if (remote != null) {
        _maps[code] = remote;
        await prefs.setString('$_cachePrefix$code', jsonEncode(remote));
        _injectIntoGetX(code, remote);
      }
    } catch (_) {}

    if ((_maps[code] == null || _maps[code]!.isEmpty) && code == 'ar') {
      _maps[code] = Map<String, String>.from(ArabicTr);
      _injectIntoGetX(code, _maps[code]!);
    }
  }

  static Future<Map<String, String>?> _fetchFromNetwork(
    String languageCode,
  ) async {
  final uri = Uri.parse(Urls.getLangUrl(languageCode));
  final headers = HttpHeadersHelper.base();
  final res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final Map<String, dynamic> rawMap = decoded is Map<String, dynamic>
          ? (decoded['data'] is Map<String, dynamic>
                ? decoded['data']
                : decoded)
          : <String, dynamic>{};

      return rawMap.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }
    return null;
  }

  static String _normalize(String languageCode) {
    if (languageCode.isEmpty) return 'en';
    return languageCode.split('_').first.split('-').first.toLowerCase();
  }

  static void _injectIntoGetX(String shortCode, Map<String, String> map) {
    final normalized = _normalize(shortCode);
    Get.addTranslations({normalized: map});
  }
}
