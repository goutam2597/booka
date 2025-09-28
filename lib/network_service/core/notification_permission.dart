
import 'package:bookapp_customer/utils/shared_prefs_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bookapp_customer/utils/permissions_handler.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionManager {
  static Future<bool> areNotificationsEnabled() async {
    try {
      // First honor the app-level toggle
      final appOn = await SharedPrefsManager.getNotificationsEnabled();
      if (!appOn) return false;

      try {
        final permStatus = await PermissionsHandler().statusAppNotification();
        return permStatus.isGranted;
      } catch (_) {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final granted = await PermissionsHandler().requestAppNotification();
      if (!granted) return false;
      // Extra FCM call to ensure token provisioning on iOS/Android
      try {
        await FirebaseMessaging.instance.getToken();
      } catch (_) {}
      return true;
    } catch (_) {
      return false;
    }
  }
}
