import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../network_service/core/lang_service.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:provider/provider.dart';
import 'package:bookapp_customer/features/home/providers/home_provider.dart';
import 'package:bookapp_customer/features/services/providers/services_provider.dart';
import 'package:bookapp_customer/features/home/providers/category_provider.dart';
import 'package:bookapp_customer/features/vendors/providers/vendors_list_provider.dart';
import 'package:bookapp_customer/features/account/providers/dashboard_provider.dart';
import 'package:bookapp_customer/features/appointments/providers/appointments_provider.dart';
import 'package:bookapp_customer/network_service/core/basic_service.dart';

const _kLangCodeKey = 'languageCode';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool _switching = false;
  bool get isSwitching => _switching;

  // Languages advertised by backend get-basic
  List<LanguageInfo> _languages = const [];
  List<LanguageInfo> get languages => _languages;

  // Expose supported locales for Material localizations
  List<Locale> get supportedLocales => _languages.isNotEmpty
      ? _languages.map((l) => Locale(l.code)).toList(growable: false)
      : const [Locale('en'), Locale('ar')];

  // RTL based on backend direction flag for current language
  bool get isRtl {
    final code = _locale.languageCode.toLowerCase();
    final lang = _languages.firstWhere(
      (l) => l.code.toLowerCase() == code,
      orElse: () =>
          LanguageInfo(code: code, name: code, directionRtl: code == 'ar'),
    );
    return lang.directionRtl;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kLangCodeKey);
    final headerLang = HttpHeadersHelper.languageCode;
    String? lang = (stored != null && stored.isNotEmpty)
        ? stored
        : (headerLang.isNotEmpty ? headerLang : null);

    // Always read advertised languages and default from backend
    try {
      final basic = await BasicService.fetchBasic();
      final langs = (basic?['data']?['languages'] as List?) ?? const [];
      _languages = langs
          .map((e) => LanguageInfo.fromMap((e as Map).cast<String, dynamic>()))
          .toList(growable: false);
      // If no stored/header lang, pick server default or first
      if (lang == null) {
        final def = _languages.firstWhere(
          (l) => l.isDefault,
          orElse: () => _languages.isNotEmpty
              ? _languages.first
              : LanguageInfo(code: 'en', name: 'English', directionRtl: false),
        );
        lang = def.code;
      }
    } catch (_) {
      // fallback
      _languages = const [
        LanguageInfo(code: 'en', name: 'English', directionRtl: false),
        LanguageInfo(code: 'ar', name: 'Arabic', directionRtl: true),
      ];
      lang ??= 'en';
    }
    final target = Locale(lang);
    await LangService.ensureLoaded(target.languageCode);
    _locale = target;
    HttpHeadersHelper.setLanguage(target.languageCode);
    Get.updateLocale(target);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _switching = true;
    notifyListeners();
    try {
      await LangService.ensureLoaded(locale.languageCode);
      _locale = locale;
      HttpHeadersHelper.setLanguage(locale.languageCode);
      Get.updateLocale(locale);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLangCodeKey, locale.languageCode);

      // Update Accept-Language header immediately for subsequent requests
      HttpHeadersHelper.setLanguage(locale.languageCode);

      // Kick-off immediate data refresh across the app without waiting for manual pull-to-refresh
      try {
        // Home sections/features/services/cards
        Get.context?.read<HomeProvider>().onLanguageChanged();
      } catch (_) {}
      try {
        // Services listing, categories, search
        Get.context?.read<ServicesProvider>().onLanguageChanged();
      } catch (_) {}
      try {
        // Clear per-category caches so next open refetches in new language
        Get.context?.read<CategoryProvider>().invalidateAll();
      } catch (_) {}
      try {
        // Vendors list
        Get.context?.read<VendorsListProvider>().onLanguageChanged();
      } catch (_) {}
      try {
        // Dashboard texts/metrics (if logged in)
        Get.context?.read<DashboardProvider>().onLanguageChanged();
      } catch (_) {}
      try {
        // Appointments + vendor names
        Get.context?.read<AppointmentsProvider>().onLanguageChanged();
      } catch (_) {}
    } finally {
      _switching = false;
      notifyListeners();
    }
  }
}

class LanguageInfo {
  final String code;
  final String name;
  final bool directionRtl;
  final bool isDefault;

  const LanguageInfo({
    required this.code,
    required this.name,
    this.directionRtl = false,
    this.isDefault = false,
  });

  factory LanguageInfo.fromMap(Map<String, dynamic> m) {
    final code = (m['code']?.toString() ?? 'en').trim();
    final name = (m['name']?.toString() ?? code).trim();
    final dir = (m['direction']?.toString() ?? '0') == '1';
    final def = (m['is_default']?.toString() ?? '0') == '1';
    return LanguageInfo(
      code: code,
      name: name,
      directionRtl: dir,
      isDefault: def,
    );
  }
}
