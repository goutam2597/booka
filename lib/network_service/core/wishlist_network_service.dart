import 'dart:convert';

import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/features/wishlist/data/models/wishlist_model.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:http/http.dart' as http;
import 'package:bookapp_customer/utils/offline_cache.dart';

class WishlistNetworkService {
  static String? _wishlistTitleCache;

  static void clearCache() {
    _wishlistTitleCache = null;
  }

  static Future<String> addToWishlist(int serviceId) async {
    try {
      final response = await http.get(
        Uri.parse(Urls.addToWishlistUrl(serviceId)),
        headers: AuthAndNetworkService.getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Added to wishlist';
      } else if (response.statusCode == 401) {
        await AuthAndNetworkService.logOut();
        return 'Login to add to wishlist';
      } else {
        return 'Error ${response.statusCode}';
      }
    } catch (e) {
      return 'Something went wrong';
    }
  }

  /// Fetch wishlist for logged-in user
  static Future<List<WishlistModel>> getWishList() async {
    final uid = AuthAndNetworkService.user?.id;
    final cacheKey = uid != null ? 'wishlist_$uid' : 'wishlist_guest';

    try {
      final response = await http.get(
        Uri.parse(Urls.wishlistUrl),
        headers: AuthAndNetworkService.getHeaders(),
      );

      if (response.statusCode == 401) {
        await AuthAndNetworkService.logOut();
        clearCache();
        return [];
      }

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          // Cache full payload for offline reuse
          await OfflineCache.putJson(cacheKey, decoded);
          final data = decoded['data'] as Map<String, dynamic>? ?? const {};
          final pageHeading = data['pageHeading'] as Map<String, dynamic>?;
          final String? pageTitle = pageHeading != null
              ? (pageHeading['wishlist_page_title']?.toString())
              : null;

          _wishlistTitleCache = (pageTitle ?? '').trim();

          final List list = data['wishlists'] ?? [];
          return list
              .map((e) => WishlistModel.fromJson(e, pageTitle: pageTitle))
              .toList();
        } catch (_) {
          // parsing failed; try offline cache
          final cached = await OfflineCache.getJson(cacheKey);
          if (cached != null) {
            final data = cached['data'] as Map<String, dynamic>? ?? const {};
            final pageHeading = data['pageHeading'] as Map<String, dynamic>?;
            final String? pageTitle = pageHeading != null
                ? (pageHeading['wishlist_page_title']?.toString())
                : null;
            _wishlistTitleCache = (pageTitle ?? '').trim();
            final List list = data['wishlists'] ?? [];
            return list
                .map((e) => WishlistModel.fromJson(e, pageTitle: pageTitle))
                .toList();
          }
          return [];
        }
      }

      // Non-200: use cache if available
      final cached = await OfflineCache.getJson(cacheKey);
      if (cached != null) {
        final data = cached['data'] as Map<String, dynamic>? ?? const {};
        final pageHeading = data['pageHeading'] as Map<String, dynamic>?;
        final String? pageTitle = pageHeading != null
            ? (pageHeading['wishlist_page_title']?.toString())
            : null;
        _wishlistTitleCache = (pageTitle ?? '').trim();
        final List list = data['wishlists'] ?? [];
        return list
            .map((e) => WishlistModel.fromJson(e, pageTitle: pageTitle))
            .toList();
      }
      return [];
    } catch (_) {
      // Network error: fallback to cache
      final cached = await OfflineCache.getJson(cacheKey);
      if (cached != null) {
        final data = cached['data'] as Map<String, dynamic>? ?? const {};
        final pageHeading = data['pageHeading'] as Map<String, dynamic>?;
        final String? pageTitle = pageHeading != null
            ? (pageHeading['wishlist_page_title']?.toString())
            : null;
        _wishlistTitleCache = (pageTitle ?? '').trim();
        final List list = data['wishlists'] ?? [];
        return list
            .map((e) => WishlistModel.fromJson(e, pageTitle: pageTitle))
            .toList();
      }
      return [];
    }
  }

  static Future<bool> isInWishlist(int serviceId) async {
    try {
      final wishlist = await getWishList();
      return wishlist.any((item) => item.serviceId == serviceId);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeFromWishlist(int serviceId) async {
    final response = await http.get(
      Uri.parse(Urls.removeFromWishlistUrl(serviceId)),
      headers: AuthAndNetworkService.getHeaders(),
    );

    if (response.statusCode == 401) {
      await AuthAndNetworkService.logOut();
      return false;
    }

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      } catch (_) {
        return false;
      }
    }

    return false;
  }

  static Future<String> getWishListTitle() async {
    final cached = _wishlistTitleCache?.trim();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    await getWishList();
    return _wishlistTitleCache?.trim() ?? '';
  }
}
