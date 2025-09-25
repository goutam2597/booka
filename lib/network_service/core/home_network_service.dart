import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/features/home/data/models/home_models.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:bookapp_customer/utils/offline_cache.dart';

class HomeNetworkService {
  Future<HomeResponse> getHome() async {
    try {
      final headers = HttpHeadersHelper.base();
      final resp = await http.get(Uri.parse(Urls.homeUrl), headers: headers);
      if (resp.statusCode != 200) {
        // Try offline cache
        final cached = await OfflineCache.getJson('home');
        if (cached != null) return HomeResponse.fromJson(cached);
        throw Exception('Failed to load home data: ${resp.statusCode}');
      }
      final decoded = jsonDecode(resp.body);
      final Map<String, dynamic> data =
          decoded is Map<String, dynamic>
              ? (decoded['data'] is Map<String, dynamic>
                  ? decoded['data']
                  : decoded)
              : <String, dynamic>{};
      // Save to offline cache
      await OfflineCache.putJson('home', data);
      return HomeResponse.fromJson(data);
    } catch (_) {
      // Network error: fallback
      final cached = await OfflineCache.getJson('home');
      if (cached != null) return HomeResponse.fromJson(cached);
      rethrow;
    }
  }
}
