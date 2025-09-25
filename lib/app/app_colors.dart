import 'package:flutter/cupertino.dart';

/// Centralized color definitions used throughout the app.
class AppColors {
  static late Color primaryColor = const Color(0xffF83758);
  static late Color secondaryColor = const Color(0xffe6516c);

  /// Apply brand colors fetched from backend (get-basic)
  static void applyBrand({required Color primary, required Color secondary}) {
    primaryColor = primary;
    secondaryColor = secondary;
  }

  // ───── Accent & Supporting Colors ─────
  static const Color colorPink = Color(0xffF83758);
  static const Color colorText = Color(0xff182D53);
  static const Color titleColor = Color(0xff222B45);
  static const Color snackSuccess = Color(0xff15803E);
  static const Color snackError = Color(0xffff0000);

  // ───── Global Gradient Style ─────
  static LinearGradient get themeGradient => LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
