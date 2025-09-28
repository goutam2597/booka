import 'dart:async';
import 'dart:ui';
import 'package:bookapp_customer/app/app.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/providers/connectivity_provider.dart';
import 'package:bookapp_customer/app/providers/locale_provider.dart';
import 'package:bookapp_customer/app/providers/session_provider.dart';
import 'package:bookapp_customer/features/account/providers/dashboard_provider.dart';
import 'package:bookapp_customer/features/account/providers/notification_settings_provider.dart';
import 'package:bookapp_customer/features/account/providers/profile_provider.dart';
import 'package:bookapp_customer/features/account/providers/theme_provider.dart';
import 'package:bookapp_customer/features/appointments/providers/appointment_details_provider.dart';
import 'package:bookapp_customer/features/appointments/providers/appointments_provider.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/features/common/providers/nav_provider.dart';
import 'package:bookapp_customer/features/home/providers/category_provider.dart';
import 'package:bookapp_customer/features/home/providers/home_provider.dart';
import 'package:bookapp_customer/features/home/providers/notification_provider.dart';
import 'package:bookapp_customer/features/services/providers/service_details_provider.dart';
import 'package:bookapp_customer/features/services/providers/services_provider.dart';
import 'package:bookapp_customer/features/services/providers/services_search_filter_provider.dart';
import 'package:bookapp_customer/features/vendors/providers/vendor_details_provider.dart';
import 'package:bookapp_customer/features/vendors/providers/vendors_list_provider.dart';
import 'package:bookapp_customer/features/wishlist/providers/wishlist_provider.dart';
import 'package:bookapp_customer/features/wishlist/providers/wishlist_ui_provider.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:bookapp_customer/network_service/core/basic_service.dart';
import 'package:bookapp_customer/network_service/core/forget_pass_network_service.dart';
import 'package:bookapp_customer/network_service/core/home_network_service.dart';
import 'package:bookapp_customer/network_service/core/local_notification_service.dart';
import 'package:bookapp_customer/network_service/core/notification_service.dart';
import 'package:bookapp_customer/network_service/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<FirebaseApp> ensureFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    return Firebase.app();
  }
  try {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app' ||
        e.message?.contains('duplicate-app') == true) {
      return Firebase.app();
    }
    rethrow;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await ensureFirebase();
}

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        print('Uncaught async error: $error');
        return true;
      };

      await AuthAndNetworkService.loadToken();
      await AuthAndNetworkService.getUserFromStorage();
      try {
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
      } catch (_) {}
      await ensureFirebase();
      try {
        await NotificationService().initNotification();
      } catch (_) {}
      try {
        final details = await LocalNotificationService.notificationsPlugin
            .getNotificationAppLaunchDetails();
        final response = details?.notificationResponse;
        if (response != null) {
          LocalNotificationService.setPendingLaunchPayload(response.payload);
        }
      } catch (_) {}

      // Locale (so first frame uses correct language/RTL)
      final localeProvider = LocaleProvider();
      await localeProvider.init();

      // Brand colors prefetch (before runApp to avoid flicker)
      Color parseHex(String hex) {
        final h = hex.replaceAll('#', '').trim();
        final full = h.length == 6 ? 'FF$h' : h;
        return Color(int.parse(full, radix: 16));
      }

      try {
        final basic = await BasicService.fetchBasic();
        final m = (basic?['data']?['basic_data'] as Map?)
            ?.cast<String, dynamic>();
        if (m != null) {
          final pc = m['primary_color']?.toString();
          final sc = m['secondary_color']?.toString();
          if (pc != null && sc != null && pc.isNotEmpty && sc.isNotEmpty) {
            AppColors.applyBrand(
              primary: parseHex(pc),
              secondary: parseHex(sc),
            );
          }
        }
        await BasicService.prewarmBranding();
      } catch (_) {
        AppColors.applyBrand(
          primary: const Color(0xFFFF0037),
          secondary: const Color(0xFFFF4870),
        );
      }

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider(create: (_) => ThemeProvider()..bootstrap()),
            ChangeNotifierProvider(create: (_) => SessionProvider()),
            ChangeNotifierProvider(
              create: (_) => AuthProvider(ForgetPassNetworkService()),
            ),
            ChangeNotifierProvider(create: (_) => DashboardProvider()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => NavProvider()),
            ChangeNotifierProvider(create: (_) => CategoryProvider()),
            ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
            ChangeNotifierProvider(create: (_) => AppointmentDetailsProvider()),
            ChangeNotifierProvider(
              create: (_) => WishlistProvider()..refresh(),
            ),
            ChangeNotifierProvider(create: (_) => VendorDetailsProvider()),
            ChangeNotifierProvider(
              create: (_) => VendorsListProvider()..fetch(),
            ),
            ChangeNotifierProvider(create: (_) => ServicesProvider()),
            ChangeNotifierProvider(create: (_) => ServiceDetailsProvider()),
            ChangeNotifierProvider(create: (_) => WishlistUiProvider()),
            ChangeNotifierProvider(
              create: (_) => ServicesSearchFilterProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => NotificationSettingsProvider()..bootstrap(),
            ),
            ChangeNotifierProvider(
              create: (_) => NotificationProvider()..subscribeFirebase(),
            ),
            ChangeNotifierProvider(
              create: (_) => HomeProvider(HomeNetworkService())..fetchInitial(),
            ),
          ],
          child: const _AppWithConnectivity(),
        ),
      );
    },
    (error, stack) {
      print('Zone error: $error');
    },
  );
}

class _AppWithConnectivity extends StatelessWidget {
  const _AppWithConnectivity();

  @override
  Widget build(BuildContext context) {
    return const BookApp();
  }
}
