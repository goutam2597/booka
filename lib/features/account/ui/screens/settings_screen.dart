import 'package:bookapp_customer/permissions/permission_service.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/providers/locale_provider.dart';
import 'package:bookapp_customer/features/account/providers/notification_settings_provider.dart';
import 'package:bookapp_customer/features/account/ui/screens/legal_screen.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late String _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selected = context.read<LocaleProvider>().locale.languageCode;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      Future.microtask(() async {
        if (!mounted) return;
        try {
          await context.read<NotificationSettingsProvider>().syncFromOS();
        } catch (_) {
          // no-op
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationSettingsProvider>();
    final lp = context.watch<LocaleProvider>();
    final langs = lp.languages;
    // theme is driven by Basic API brand colors only
    final items = langs.isNotEmpty
        ? langs
              .map((l) => DropdownMenuItem(value: l.code, child: Text(l.name)))
              .toList(growable: false)
        : <DropdownMenuItem<String>>[
            const DropdownMenuItem(value: 'en', child: Text('English')),
            const DropdownMenuItem(value: 'ar', child: Text('Arabic')),
          ];
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Messages (Notifications)
                _tile(
                  title: 'Notifications'.tr,
                  subtitle: 'Receive exclusive offers and updates'.tr,
                  trailing: Switch(
                    inactiveThumbColor: AppColors.primaryColor,
                    inactiveTrackColor: Colors.white,
                    activeTrackColor: AppColors.primaryColor,
                    trackOutlineColor: WidgetStatePropertyAll(
                      AppColors.primaryColor,
                    ),
                    value: notif.appEnabled,
                    onChanged: (v) async {
                      if (!mounted) return;
                      final perm = PermissionService();
                      if (v) {
                        // Step 1: check current OS-level permission before asking provider
                        final status = await perm.statusAppNotification();
                        if (status.isPermanentlyDenied) {
                          await perm.openAppSettingsSafe();
                          return;
                        }
                        if (!status.isGranted) {
                          final granted = await perm.requestAppNotification();
                          if (!granted) {
                            // If user denied again, offer settings as fallback
                            await perm.openAppSettingsSafe();
                            return;
                          }
                        }
                        final ok = await context
                            .read<NotificationSettingsProvider>()
                            .turnOn();
                        if (!ok && context.mounted) {
                          await perm.openAppSettingsSafe();
                        }
                      } else {
                        // Turning off in-app toggle, but allow user to manage OS settings
                        await context
                            .read<NotificationSettingsProvider>()
                            .turnOff();
                        await perm.openAppSettingsSafe();
                      }
                    },
                  ),
                ),
                if (!notif.osAuthorized)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4, right: 4, bottom: 8),
                    child: InkWell(
                      onTap: () async {
                        await PermissionService().openAppSettingsSafe();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Notifications are disabled in system settings'.tr,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await PermissionService().openAppSettingsSafe();
                            },
                            child: Text('Open Settings'.tr),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Theme Colors UI removed: colors come from Basic API
                const SizedBox(height: 8),
                // Language
                Text(
                  'Language'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  elevation: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: Colors.white,
                        initialValue: _selected,
                        items: items,
                        onChanged: (v) async {
                          final value = (v ?? _selected);
                          if (!mounted) return;
                          setState(() => _selected = value);
                          await context.read<LocaleProvider>().setLocale(
                            Locale(value),
                          );
                          if (!context.mounted) return;
                          final name = langs.isNotEmpty
                              ? (langs
                                    .firstWhere(
                                      (l) => l.code == value,
                                      orElse: () => langs.first,
                                    )
                                    .name)
                              : (value == 'ar' ? 'Arabic' : 'English');
                          CustomSnackBar.show(
                            context,
                            "${'language changed to'.tr} $name",
                            title: 'Success',
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                // Terms & Conditions
                _navTile(
                  title: 'Terms & Conditions',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LegalScreen(
                        title: 'Terms & Conditions',
                        pageKey: 'terms',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Privacy Policy
                _navTile(
                  title: 'Privacy Policy'.tr,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LegalScreen(
                        title: 'Privacy Policy'.tr,
                        pageKey: 'privacy',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Removed external AppSettings dependency; using permission_handler
  // openAppSettings via PermissionService instead.

  // Styled list tiles similar to the referenced design
  Widget _tile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0.2,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _navTile({required String title, required VoidCallback onTap}) {
    return Card(
      color: Colors.white,
      elevation: 0.2,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // removed _pickColor dialog and related logic
}
