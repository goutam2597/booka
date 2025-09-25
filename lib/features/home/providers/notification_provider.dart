import 'dart:async';

import 'package:bookapp_customer/features/home/data/models/notification_model.dart';
import 'package:bookapp_customer/network_service/core/notification_service.dart';
import 'package:bookapp_customer/utils/shared_prefs_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

enum NotificationFilter { all, read, unread }

class NotificationProvider extends ChangeNotifier {
  NotificationFilter _filter = NotificationFilter.all;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedAppSub;

  List<NotificationModel> get _all => NotificationService.notifications;

  NotificationFilter get filter => _filter;

  bool get hasUnread => _all.any((n) => !n.isRead);

  List<NotificationModel> get notifications {
    switch (_filter) {
      case NotificationFilter.read:
        return _all.where((n) => n.isRead).toList();
      case NotificationFilter.unread:
        return _all.where((n) => !n.isRead).toList();
      case NotificationFilter.all:
        return _all;
    }
  }

  void subscribeFirebase() {
    _onMessageSub?.cancel();
    _onOpenedAppSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((_) {
      try { notifyListeners(); } catch (_) {}
    }, onError: (_) {/* swallow to avoid crash */});
    _onOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((_) {
      try { notifyListeners(); } catch (_) {}
    }, onError: (_) {/* swallow to avoid crash */});
  }

  void setFilter(NotificationFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await NotificationService().markAllAsRead();
    notifyListeners();
  }

  Future<void> markAsRead(NotificationModel model) async {
    model.isRead = true;
    notifyListeners();
    // persist change
    await SharedPrefsManager.saveNotifications(NotificationService.notifications);
  }

  Future<void> removeNotification(NotificationModel model) async {
    final i = _all.indexOf(model);
    if (i >= 0) {
      await NotificationService.removeNotificationAt(i);
      notifyListeners();
    }
  }

  void refresh() => notifyListeners();

  @override
  void dispose() {
    _onMessageSub?.cancel();
    _onOpenedAppSub?.cancel();
    super.dispose();
  }
}
