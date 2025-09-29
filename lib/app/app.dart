import 'package:bookapp_customer/app/providers/locale_provider.dart';
import 'package:bookapp_customer/features/account/providers/theme_provider.dart';
import 'package:bookapp_customer/app/localization/translations.dart';
import 'package:bookapp_customer/app/providers/connectivity_provider.dart';
import 'package:bookapp_customer/app/routes/app_routes.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/offline_banner.dart';
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
    // Keep listening for connectivity changes indirectly via OfflineBanner.
    // No UI blocking; banner handles its own visibility.
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
        // Always render the app content; offline data is served from
        // cached sources in network services.
        final base = (child ?? const SizedBox.shrink());

        // Global unfocus: tap anywhere outside inputs to dismiss keyboard/focus
        final content = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            final focus = FocusManager.instance.primaryFocus;
            if (focus != null && !focus.hasPrimaryFocus) {
              focus.unfocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          child: base,
        );

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              content,
              const OfflineBanner(),
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



