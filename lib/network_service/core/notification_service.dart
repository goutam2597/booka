import 'dart:convert';

import 'package:bookapp_customer/features/home/data/models/notification_model.dart';
import 'package:bookapp_customer/network_service/core/local_notification_service.dart';
import 'package:bookapp_customer/network_service/core/notification_permission.dart';
import 'package:bookapp_customer/utils/shared_prefs_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  static final Logger _log = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5),
  );

  static List<NotificationModel> notifications = [];

  static String? currentToken;

  Future<void> initNotification() async {
    _log.i('Initializing notifications');
    final enabled = await SharedPrefsManager.getNotificationsEnabled();
    bool osAuthorized = false;
    try {
      osAuthorized = await NotificationPermissionManager.areNotificationsEnabled();
    } catch (_) {}
    final allow = enabled && osAuthorized;
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(allow);
    } catch (e) {
      _log.w('setAutoInitEnabled failed: $e');
    }

    // Request OS permission only if app-level toggle is enabled
    if (allow) {
      try {
        final settings = await _firebaseMessaging.requestPermission();
        _log.i('Permission status: ${settings.authorizationStatus}');
      } catch (e) {
        _log.w('requestPermission failed: $e');
      }
      try {
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        _log.w('setForegroundNotificationPresentationOptions failed: $e');
      }
    }

    String? token;
    if (allow) {
      try { token = await _firebaseMessaging.getToken(); } catch (e) {
        _log.w('getToken failed: $e');
      }
    }
    currentToken = token;
    if (token != null) {
      _log.i("FCM Token: $token");
    }
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      try {
        currentToken = newToken;
        _log.i("FCM Token refreshed: $newToken");
      } catch (e) {
        _log.w('onTokenRefresh handler error: $e');
      }
    }, onError: (e) {
      _log.w('onTokenRefresh stream error: $e');
    });

    await LocalNotificationService.initialize();

    notifications = await SharedPrefsManager.loadNotifications();
    _log.i('Loaded ${notifications.length} saved notifications');

    _log.i('Attaching onMessage and onMessageOpenedApp listeners');
    FirebaseMessaging.onMessage.listen((msg) async {
      try {
        _log.d('onMessage: id=${msg.messageId} from=${msg.from} sent=${msg.sentTime}');
        _log.d('onMessage: notificationTitle=${msg.notification?.title} notificationBody=${msg.notification?.body}');
        _log.d('onMessage: data=${msg.data}');
        try { await _saveMessage(msg); } catch (e) { _log.w('saveMessage failed: $e'); }
        final show = await SharedPrefsManager.getNotificationsEnabled();
        bool osOn = false;
        try { osOn = await NotificationPermissionManager.areNotificationsEnabled(); } catch (_) {}
        if (show && osOn) {
          try {
            LocalNotificationService.showNotification(
              msg.notification?.title ?? "No Title",
              msg.notification?.body ?? "No Body",
              payload: msg.data.isNotEmpty ? jsonEncode(msg.data) : null,
            );
          } catch (e) {
            _log.w('showNotification failed: $e');
          }
        }
      } catch (e) {
        _log.w('onMessage handler error: $e');
      }
    }, onError: (e, [st]) {
      _log.w('onMessage stream error: $e');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      try {
        _log.d('onMessageOpenedApp: id=${msg.messageId} from=${msg.from} data=${msg.data}');
        _saveMessage(msg);
      } catch (e) {
        _log.w('onMessageOpenedApp handler error: $e');
      }
    }, onError: (e, [st]) {
      _log.w('onMessageOpenedApp stream error: $e');
    });

    try {
      final initialMsg = await _firebaseMessaging.getInitialMessage();
      if (initialMsg != null) {
        _log.d('getInitialMessage: data=${initialMsg.data}');
        _saveMessage(initialMsg);
      }
    } catch (e) {
      _log.w('getInitialMessage failed: $e');
    }
}

  Future<void> _saveMessage(RemoteMessage msg) async {
    try {
      final now = DateTime.now().toLocal();

      final title =
          msg.notification?.title ?? (msg.data['title'] as String?) ?? "No Title";
      final body =
          msg.notification?.body ?? (msg.data['body'] as String?) ?? "No Body";
      final type = (msg.data['type'] as String?) ?? "General";

      _log.t('Saving message: ${msg.data}');

      AppointmentNotificationData? data;
      try {
        data = AppointmentNotificationData.fromMap(
          Map<String, dynamic>.from(msg.data),
        );
      } catch (e) {
        _log.w('Parsing AppointmentNotificationData failed: $e');
        data = null;
      }

      final note = NotificationModel(
        title: title,
        body: body,
        type: type,
        timestamp: now,
        data: data,
        isRead: false,
      );
      NotificationService.notifications.insert(0, note);
      await SharedPrefsManager.saveNotifications(
        NotificationService.notifications,
      );
    } catch (e) {
      _log.w('saveMessage outer error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    await SharedPrefsManager.markAllAsRead(notifications);
  }

  static Future<void> removeNotificationAt(int index) async {
    final notifications = await SharedPrefsManager.loadNotifications();

    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
      await SharedPrefsManager.saveNotifications(notifications);
    }
  }
}






