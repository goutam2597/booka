import 'dart:convert';

import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/features/account/models/dashboard_model.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:http/http.dart' as http;
import 'package:bookapp_customer/utils/offline_cache.dart';

class DashboardNetworkService {
  static String? _getDashboardTitle;

  static void clearCache() {
    _getDashboardTitle = null;
  }

  static Future<DashboardModel> getDashboardData() async {
    final uid = AuthAndNetworkService.user?.id;
    final cacheKey = uid != null ? 'dashboard_$uid' : 'dashboard_guest';
    try {
      final response = await http.get(
        Uri.parse(Urls.dashboardUrl),
        headers: AuthAndNetworkService.getHeaders(),
      );
      if (response.statusCode == 401) {
        await AuthAndNetworkService.logOut();
        throw Exception('Unauthorized');
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        await OfflineCache.putJson(cacheKey, decoded);
        final data = decoded['data'];
        return DashboardModel.fromJson(data);
      }
      // Non-2xx -> try cache
      final cached = await OfflineCache.getJson(cacheKey);
      if (cached != null) {
        final data = cached['data'];
        return DashboardModel.fromJson(data);
      }
      throw Exception('Failed to load dashboard: ${response.statusCode}');
    } catch (_) {
      final cached = await OfflineCache.getJson(cacheKey);
      if (cached != null) {
        final data = cached['data'];
        return DashboardModel.fromJson(data);
      }
      rethrow;
    }
  }

  static Future<String> getDashboardTitle() async {
    final title = _getDashboardTitle?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    await getDashboardData();
    return _getDashboardTitle?.trim() ?? '';
  }
}
