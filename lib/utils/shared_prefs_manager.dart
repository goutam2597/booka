import 'dart:convert';

import 'package:bookapp_customer/features/home/data/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin SharedPrefsManager {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _key = "notifications";
  static const String _notifEnabledKey = 'notifications_enabled';
  // Cached assets keys
  static const String _mobileAppLogoBytesKey = 'mobile_app_logo_base64';
  static const String _mobileAppLogoUrlKey = 'mobile_app_logo_url';
  static const String _mobileFaviconBytesKey = 'mobile_favicon_base64';
  static const String _mobileFaviconUrlKey = 'mobile_favicon_url';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Save user model as JSON string
  static Future<void> saveUser(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonString);
  }

  /// Get user JSON string
  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Save all notifications list
  static Future<void> saveNotifications(
    List<NotificationModel> notifications,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = notifications.map((n) => n.toMap()).toList();
    await prefs.setString(_key, jsonEncode(jsonData));
  }

  /// Load notifications list
  static Future<List<NotificationModel>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => NotificationModel.fromMap(e)).toList();
    }
    return [];
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead(
    List<NotificationModel> notifications,
  ) async {
    for (var n in notifications) {
      n.isRead = true;
    }
    await saveNotifications(notifications);
  }

  // --------------------
  // Notification toggle
  // --------------------
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifEnabledKey) ?? true; // default ON
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifEnabledKey, value);
  }

  // --------------------
  // Generic helpers used across app
  // --------------------
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<bool> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, value);
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  // --------------------
  // Mobile App Logo cache helpers
  // --------------------
  static Future<String?> getMobileAppLogoB64() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileAppLogoBytesKey);
  }

  static Future<bool> setMobileAppLogoB64(String b64) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_mobileAppLogoBytesKey, b64);
  }

  static Future<String?> getMobileAppLogoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileAppLogoUrlKey);
  }

  static Future<bool> setMobileAppLogoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_mobileAppLogoUrlKey, url);
  }

  // --------------------
  // Mobile App Favicon cache helpers
  // --------------------
  static Future<String?> getMobileFaviconB64() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileFaviconBytesKey);
  }

  static Future<bool> setMobileFaviconB64(String b64) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_mobileFaviconBytesKey, b64);
  }

  static Future<String?> getMobileFaviconUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileFaviconUrlKey);
  }

  static Future<bool> setMobileFaviconUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_mobileFaviconUrlKey, url);
  }
}
