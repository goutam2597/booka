import 'dart:convert';
import 'dart:typed_data';
import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:http/http.dart' as http;
import 'package:bookapp_customer/utils/shared_prefs_manager.dart';
import 'package:bookapp_customer/utils/branding_cache.dart';
import 'package:bookapp_customer/utils/offline_cache.dart';

class BasicService {
  BasicService._();

  // Simple in-memory caches for frequently used values
  static String? _stripeKeyCache;
  static String? _razorpayKeyCache;

  static Future<Map<String, dynamic>?> fetchBasic() async {
    try {
      final res = await http.get(
        Uri.parse(Urls.getBasicUrl),
        headers: HttpHeadersHelper.base(),
      );
      if (res.statusCode != 200) {
        // Fallback to cache when server non-200
        return await OfflineCache.getJson('basic');
      }
      final js = jsonDecode(res.body);
      if (js is Map<String, dynamic>) {
        // Save to offline cache for later use
        await OfflineCache.putJson('basic', js);
        return js;
      }
    } catch (_) {
      // On any exception, try offline cache
      return await OfflineCache.getJson('basic');
    }
    return await OfflineCache.getJson('basic');
  }

  // ───── Gateway keys (from get-basic) ─────
  static Future<String?> getStripePublishableKey() async {
    if (_stripeKeyCache != null && _stripeKeyCache!.isNotEmpty) {
      return _stripeKeyCache;
    }
    try {
      final js = await fetchBasic();
      final key = js?['data']?['stripe_public_key']?.toString();
      if (key != null && key.isNotEmpty) {
        _stripeKeyCache = key;
        return key;
      }
    } catch (_) {}
    return null;
  }

  static Future<String?> getRazorpayKey() async {
    if (_razorpayKeyCache != null && _razorpayKeyCache!.isNotEmpty) {
      return _razorpayKeyCache;
    }
    try {
      final js = await fetchBasic();
      final key = js?['data']?['razorpayInfo']?['key']?.toString();
      if (key != null && key.isNotEmpty) {
        _razorpayKeyCache = key;
        return key;
      }
    } catch (_) {}
    return null;
  }

  // ───── App favicon helpers (moved from CustomCPI) ─────
  static Future<String?> getFaviconUrl() async {
    try {
      final js = await fetchBasic();
      final url = js?['data']?['basic_data']?['mobile_favicon'] as String?;
      if (url != null && url.isNotEmpty) return url;
    } catch (_) {}
    return null;
  }

  static Future<Uint8List?> getCachedFaviconBytes() async {
    try {
      // First: in-memory cache
      final mem = BrandingCache.getBytes('favicon');
      if (mem != null && mem.isNotEmpty) return mem;
      final b64 = await SharedPrefsManager.getMobileFaviconB64();
      if (b64 != null && b64.isNotEmpty) {
        final bytes = base64Decode(b64);
        BrandingCache.set(
          'favicon',
          (await SharedPrefsManager.getMobileFaviconUrl()) ?? '',
          bytes,
        );
        return bytes;
      }
      // Migration: read legacy keys if present and migrate
      final legacyB64 = await SharedPrefsManager.getString('app_logo_base64');
      if (legacyB64 != null && legacyB64.isNotEmpty) {
        final bytes = base64Decode(legacyB64);
        await SharedPrefsManager.setMobileFaviconB64(legacyB64);
        final legacyUrl = await SharedPrefsManager.getString('app_logo_url');
        if (legacyUrl != null && legacyUrl.isNotEmpty) {
          await SharedPrefsManager.setMobileFaviconUrl(legacyUrl);
        }
        BrandingCache.set('favicon', legacyUrl ?? '', bytes);
        return bytes;
      }
    } catch (_) {}
    return null;
  }

  static Future<Uint8List?> ensureFaviconBytesForUrl(String url) async {
    try {
      final savedUrl = await SharedPrefsManager.getMobileFaviconUrl();
      final existingB64 = await SharedPrefsManager.getMobileFaviconB64();
      if (savedUrl == url && existingB64 != null && existingB64.isNotEmpty) {
        final bytes = base64Decode(existingB64);
        BrandingCache.set('favicon', url, bytes);
        return bytes;
      }

      // Migration path: if legacy keys exist, migrate then return
      final legacyB64 = await SharedPrefsManager.getString('app_logo_base64');
      final legacyUrl = await SharedPrefsManager.getString('app_logo_url');
      if (legacyB64 != null && legacyB64.isNotEmpty && legacyUrl == url) {
        await SharedPrefsManager.setMobileFaviconB64(legacyB64);
        await SharedPrefsManager.setMobileFaviconUrl(legacyUrl ?? url);
        final bytes = base64Decode(legacyB64);
        BrandingCache.set('favicon', legacyUrl ?? url, bytes);
        return bytes;
      }

      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
        final b64 = base64Encode(resp.bodyBytes);
        await SharedPrefsManager.setMobileFaviconB64(b64);
        await SharedPrefsManager.setMobileFaviconUrl(url);
        BrandingCache.set('favicon', url, resp.bodyBytes);
        return resp.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  // ───── Mobile App Logo helpers ─────
  static Future<String?> getMobileAppLogoUrl() async {
    try {
      final js = await fetchBasic();
      final url = js?['data']?['basic_data']?['mobile_app_logo'] as String?;
      if (url != null && url.isNotEmpty) return url;
    } catch (_) {}
    return null;
  }

  static Future<Uint8List?> getCachedMobileAppLogoBytes() async {
    try {
      final mem = BrandingCache.getBytes('logo');
      if (mem != null && mem.isNotEmpty) return mem;
      final b64 = await SharedPrefsManager.getMobileAppLogoB64();
      if (b64 != null && b64.isNotEmpty) {
        final bytes = base64Decode(b64);
        BrandingCache.set(
          'logo',
          (await SharedPrefsManager.getMobileAppLogoUrl()) ?? '',
          bytes,
        );
        return bytes;
      }
    } catch (_) {}
    return null;
  }

  static Future<Uint8List?> ensureMobileAppLogoBytesForUrl(String url) async {
    try {
      final savedUrl = await SharedPrefsManager.getMobileAppLogoUrl();
      final existingB64 = await SharedPrefsManager.getMobileAppLogoB64();
      if (savedUrl == url && existingB64 != null && existingB64.isNotEmpty) {
        final bytes = base64Decode(existingB64);
        BrandingCache.set('logo', url, bytes);
        return bytes;
      }

      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
        final b64 = base64Encode(resp.bodyBytes);
        await SharedPrefsManager.setMobileAppLogoB64(b64);
        await SharedPrefsManager.setMobileAppLogoUrl(url);
        BrandingCache.set('logo', url, resp.bodyBytes);
        return resp.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  // ───── Unified branding accessors ─────
  // type: 'logo' or 'favicon'
  static Future<String?> getBrandingUrl(String type) async {
    if (type == 'favicon') return getFaviconUrl();
    return getMobileAppLogoUrl();
  }

  static Future<Uint8List?> getCachedBrandingBytes(String type) async {
    // Always prefer memory first
    final mem = BrandingCache.getBytes(type);
    if (mem != null && mem.isNotEmpty) return mem;
    if (type == 'favicon') return getCachedFaviconBytes();
    return getCachedMobileAppLogoBytes();
  }

  static Future<Uint8List?> ensureBrandingBytesForUrl(
    String type,
    String url,
  ) async {
    if (type == 'favicon') return ensureFaviconBytesForUrl(url);
    return ensureMobileAppLogoBytesForUrl(url);
  }

  // ───── Prewarm both branding assets to avoid first-paint delay ─────
  static Future<void> prewarmBranding({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      final js = await fetchBasic();
      final basic = (js?['data']?['basic_data'] as Map?)
          ?.cast<String, dynamic>();
      final logoUrl = basic?['mobile_app_logo']?.toString();
      final favUrl = basic?['mobile_favicon']?.toString();

      Future<void> warm(String type, String? url) async {
        if (url == null || url.isEmpty) return;
        // If already in memory, skip network
        final mem = BrandingCache.getBytes(type);
        if (mem != null && mem.isNotEmpty) return;
        await ensureBrandingBytesForUrl(type, url);
      }

      final tasks = <Future<Object?>>[
        warm('logo', logoUrl),
        warm('favicon', favUrl),
      ];
      await Future.wait<Object?>(
        tasks,
      ).timeout(timeout, onTimeout: () => const <Object?>[]);
    } catch (_) {}
  }
}
