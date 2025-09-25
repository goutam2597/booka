import 'package:bookapp_customer/app/providers/locale_provider.dart';
import 'package:bookapp_customer/features/account/providers/theme_provider.dart';
import 'package:bookapp_customer/app/localization/translations.dart';
import 'package:bookapp_customer/app/providers/connectivity_provider.dart';
import 'package:bookapp_customer/app/routes/app_routes.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/screens/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:bookapp_customer/network_service/core/local_notification_service.dart';

class BookApp extends StatefulWidget {
  const BookApp({super.key});

  @override
  State<BookApp> createState() => _BookAppState();
}

class _BookAppState extends State<BookApp> {
  @override
  void initState() {
    super.initState();
    final lp = context.read<LocaleProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      lp.init();
      try {
        final pending = LocalNotificationService.takePendingLaunchPayload();
        if (pending != null) {
          Future.microtask(() {
            LocalNotificationService.handleTapPayload(pending);
          });
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityProvider>().isOnline;
    final lp = context.watch<LocaleProvider>();
    final isArabic = lp.isRtl;
    final theme = context.watch<ThemeProvider>().theme;

    return GetMaterialApp(
      key: ValueKey(theme.hashCode),
      debugShowCheckedModeBanner: false,
      theme: theme,

      // GetX i18n
      translations: AppTranslations(),
      locale: lp.locale,
      fallbackLocale: const Locale('en'),
  supportedLocales: lp.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) {
        final content = (!online)
            ? const NoInternetScreen()
            : (child ?? const SizedBox.shrink());
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              content,
              if (lp.isSwitching)
                const Center(child: CustomCPI()),
            ],
          ),
        );
      },

      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}



