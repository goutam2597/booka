import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Holds payload if the app was launched by tapping a notification
  static String? _pendingLaunchPayload;
  static void setPendingLaunchPayload(String? payload) {
    _pendingLaunchPayload = payload;
  }

  static String? takePendingLaunchPayload() {
    final p = _pendingLaunchPayload;
    _pendingLaunchPayload = null;
    return p;
  }

  static Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Ensure Android notification channel exists (Android 8+)
      if (Platform.isAndroid) {
        final android = notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await android?.createNotificationChannel(
          const AndroidNotificationChannel(
            'push_channel',
            'Push Notifications',
            description: 'Channel for push notifications',
            importance: Importance.max,
          ),
        );
      }
    } catch (_) {
      // Swallow init errors to avoid crash when permissions are revoked
    }
  }

  static Future<void> showNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'push_channel',
          'Push Notifications',
          channelDescription: 'Channel for push notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (_) {
      // Ignore show errors if notifications are blocked at OS level
    }
  }

  static void _handleNotificationTap(String? payload) {
    void safeTo(String route, {Object? arguments}) {
      try { Get.toNamed(route, arguments: arguments); } catch (_) {}
    }
    if (payload == null || payload.trim().isEmpty) {
      safeTo(AppRoutes.notifications);
      return;
    }
    try {
      final map = jsonDecode(payload);
      if (map is Map<String, dynamic>) {
        final screen = map['screen'] as String?;
        if (screen != null && screen.isNotEmpty) {
          final args = map['args'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(map['args'])
              : (map['id'] != null ? {'id': map['id']} : null);
          safeTo(screen, arguments: args);
          return;
        }
      }
      // Fallback
      safeTo(AppRoutes.notifications);
    } catch (_) {
      safeTo(AppRoutes.notifications);
    }
  }

  // Public bridge to trigger navigation from app code
  static void handleTapPayload(String? payload) =>
      _handleNotificationTap(payload);
}

// Must be top-level
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  LocalNotificationService.setPendingLaunchPayload(response.payload);
}
