# Permission Layer

Centralizes runtime permission handling using `permission_handler`.

## Supported
- Notifications (Android 13+/iOS)
- Location (when-in-use)
- Camera
- Photos / Storage (platform aware)

## Usage
```dart
final perms = PermissionService();
final granted = await perms.requestCamera();
if (!granted) {
  // show rationale or open settings
  await perms.openAppSettingsSafe();
}
```

## Notification Flow (as wired in SettingsScreen)
1. Check current status.
2. If permanently denied → open settings.
3. If not granted → request.
4. If granted → call provider.turnOn().
5. If denied again → offer system settings.

## Future Enhancements
- Batch ensure(list<Permission>)
- Central rationale callbacks
- TTL / caching permission decisions for session
