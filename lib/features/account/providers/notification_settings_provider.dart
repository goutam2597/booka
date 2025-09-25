import "package:bookapp_customer/network_service/core/notification_permission.dart";
import "package:bookapp_customer/utils/shared_prefs_manager.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";

class NotificationSettingsProvider extends ChangeNotifier {
  bool _appEnabled = true;
  bool _osAuthorized = false;
  bool _busy = false;

  bool get appEnabled => _appEnabled;
  bool get osAuthorized => _osAuthorized;
  bool get busy => _busy;

  Future<void> bootstrap() async {
    _busy = true;
    notifyListeners();
    try {
      _appEnabled = await SharedPrefsManager.getNotificationsEnabled();
      _osAuthorized = await NotificationPermissionManager.areNotificationsEnabled();

      try {
        await FirebaseMessaging.instance.setAutoInitEnabled(_appEnabled);
      } catch (_) {}
      try {
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: _appEnabled,
          badge: _appEnabled,
          sound: _appEnabled,
        );
      } catch (_) {}
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> turnOn() async {
    _busy = true;
    notifyListeners();
    try {
      final granted = await NotificationPermissionManager.requestPermission();
      if (!granted) {
        _appEnabled = false;
        _osAuthorized = false;
        await SharedPrefsManager.setNotificationsEnabled(false);
        return false;
      }
      _appEnabled = true;
      _osAuthorized = true;
      await SharedPrefsManager.setNotificationsEnabled(true);
      try {
        await FirebaseMessaging.instance.setAutoInitEnabled(true);
      } catch (_) {}
      try {
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (_) {}
      try {
        await FirebaseMessaging.instance.getToken();
      } catch (_) {}
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> turnOff() async {
    _busy = true;
    notifyListeners();
    try {
      _appEnabled = false;
      await SharedPrefsManager.setNotificationsEnabled(false);
      try {
        await FirebaseMessaging.instance.setAutoInitEnabled(false);
      } catch (_) {}
      try {
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
      } catch (_) {}
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> syncFromOS() async {
    _busy = true;
    notifyListeners();
    try {
      _osAuthorized = await NotificationPermissionManager.areNotificationsEnabled();
      if (!_osAuthorized) {
        _appEnabled = false;
        await SharedPrefsManager.setNotificationsEnabled(false);
        try { await FirebaseMessaging.instance.setAutoInitEnabled(false); } catch (_) {}
        try {
          await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );
        } catch (_) {}
      }
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
