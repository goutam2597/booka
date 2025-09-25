import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

/// High-level permission abstraction so the rest of the app does not import
/// permission_handler directly. Add new permissions here as needed.
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  PermissionService._internal();
  factory PermissionService() => _instance;

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
  Future<bool> requestCamera() async => _isGranted(await Permission.camera.request());

  Future<PermissionStatus> statusPhotos() async {
    if (Platform.isIOS) return Permission.photos.status; // iOS limited/provisional
    return Permission.storage.status; // For legacy Android (if needed)
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
      // Fallback: deep-link to notification settings if possible
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
