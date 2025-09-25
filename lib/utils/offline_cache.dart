import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineCache {
  OfflineCache._();

  static String _dataKey(String key) => 'cache_$key:data';
  static String _timeKey(String key) => 'cache_$key:ts';

  /// Save any JSON-encodable map to cache with current timestamp
  static Future<void> putJson(String key, Map<String, dynamic> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dataKey(key), jsonEncode(value));
      await prefs.setInt(_timeKey(key), DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Read cached json map; returns null if absent or invalid
  static Future<Map<String, dynamic>?> getJson(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_dataKey(key));
      if (s == null || s.isEmpty) return null;
      final decoded = jsonDecode(s);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  /// When you need the timestamp alongside the value
  static Future<({Map<String, dynamic>? data, DateTime? savedAt})> getJsonWithTs(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? data;
    DateTime? ts;
    try {
      final s = prefs.getString(_dataKey(key));
      if (s != null && s.isNotEmpty) {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) data = decoded;
      }
    } catch (_) {}
    try {
      final t = prefs.getInt(_timeKey(key));
      if (t != null) ts = DateTime.fromMillisecondsSinceEpoch(t);
    } catch (_) {}
    return (data: data, savedAt: ts);
  }

  static Future<void> clear(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dataKey(key));
      await prefs.remove(_timeKey(key));
    } catch (_) {}
  }
}
