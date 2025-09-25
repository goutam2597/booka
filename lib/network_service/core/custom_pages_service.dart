import 'dart:convert';
import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:http/http.dart' as http;
import 'package:bookapp_customer/utils/offline_cache.dart';

class CustomPagesService {
  static Future<List<Map<String, dynamic>>> fetchPages() async {
    try {
      final res = await http.get(
        Uri.parse(Urls.customPagesUrl),
        headers: HttpHeadersHelper.base(),
      );
      if (res.statusCode >= 300) {
        final cached = await OfflineCache.getJson('custom_pages');
        if (cached != null) {
          final list = (cached['data'] as List?) ?? const [];
          return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
        }
        return const [];
      }
      final js = jsonDecode(res.body) as Map<String, dynamic>;
      await OfflineCache.putJson('custom_pages', js);
      final list = (js['data'] as List?) ?? const [];
      return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    } catch (_) {
      final cached = await OfflineCache.getJson('custom_pages');
      if (cached != null) {
        final list = (cached['data'] as List?) ?? const [];
        return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
      }
      return const [];
    }
  }


  static Map<String, dynamic>? pickPage(
    List<Map<String, dynamic>> pages, {
    required String targetTitleContains,
    String languageId = '20',
  }) {
    for (final p in pages) {
      final contents = (p['content'] as List?) ?? const [];
      for (final c in contents) {
        final m = (c as Map).cast<String, dynamic>();
        final title = (m['title']?.toString() ?? '').toLowerCase();
        if (title.contains(targetTitleContains.toLowerCase())) {
          return m;
        }
      }
    }
    return null;
  }
}
