import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_theme_data.dart';

/// Provides a dynamic theme that can be updated at runtime
class ThemeProvider extends ChangeNotifier {
  ThemeData _theme = AppThemeData.buildLightTheme();
  ThemeData get theme => _theme;

  /// ThemeProvider just exposes theme built from AppColors (which are set by Basic API in main)
  Future<void> bootstrap() async {
    _theme = AppThemeData.buildLightTheme();
    notifyListeners();
  }

  /// Called when Basic API brand colors change to rebuild ThemeData
  void rebuildFromBrandColors() {
    _theme = AppThemeData.buildLightTheme();
    notifyListeners();
  }
}
