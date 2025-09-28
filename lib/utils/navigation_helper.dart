import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bookapp_customer/app/routes/app_routes.dart';

class NavigationHelper {
  NavigationHelper._();

  static void safeBack(BuildContext context, {String? fallbackRoute}) {
    try {
      final rootNav = Navigator.of(context, rootNavigator: true);
      if (rootNav.canPop()) {
        rootNav.pop();
        return;
      }
    } catch (_) {}

    try {
      final localNav = Navigator.of(context);
      if (localNav.canPop()) {
        localNav.pop();
        return;
      }
    } catch (_) {}

    // Fallback: reset to bottom navigation/home
    final route = fallbackRoute ?? AppRoutes.bottomNav;
    try {
      Get.offAllNamed(route);
    } catch (_) {
      // If GetX navigation fails (unlikely), attempt Navigator reset
      try {
        Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
      } catch (_) {}
    }
  }
}
