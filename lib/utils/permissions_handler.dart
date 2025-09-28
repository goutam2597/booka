import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class PermissionsHandler {
  static final PermissionsHandler _instance = PermissionsHandler._internal();
  PermissionsHandler._internal();
  factory PermissionsHandler() => _instance;

  Future<PermissionStatus> statusAppNotification() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return Permission.notification.status;
    }
    return PermissionStatus.granted;
  }

  Future<bool> requestAppNotification() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return true;
    final result = await Permission.notification.request();
    return _isGranted(result);
  }

  Future<PermissionStatus> statusLocation() async {
    return Permission.locationWhenInUse.status;
  }

  Future<bool> requestLocation() async {
    final result = await Permission.locationWhenInUse.request();
    return _isGranted(result);
  }

  Future<PermissionStatus> statusCamera() async => Permission.camera.status;
  Future<bool> requestCamera() async =>
      _isGranted(await Permission.camera.request());

  Future<PermissionStatus> statusPhotos() async {
    if (Platform.isIOS)
      return Permission.photos.status;
    return Permission.storage.status;
  }

  Future<bool> requestPhotos() async {
    if (Platform.isIOS) return _isGranted(await Permission.photos.request());
    return _isGranted(await Permission.storage.request());
  }

  bool _isGranted(PermissionStatus s) =>
      s == PermissionStatus.granted || s == PermissionStatus.limited;

  bool isPermanentlyDenied(PermissionStatus s) => s.isPermanentlyDenied;

  Future<bool> openAppSettingsSafe() async {
    try {
      final ok = await openAppSettings();
      if (ok) return true;
    } catch (_) {}
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
      return true;
    } catch (_) {}
    try {
      await AppSettings.openAppSettings();
      return true;
    } catch (_) {}
    return false;
  }
}
