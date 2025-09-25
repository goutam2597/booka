import 'package:bookapp_customer/app/app_colors.dart';
import 'package:flutter/material.dart';

/// App-wide light & dark themes for MaterialApp
class AppThemeData {
  AppThemeData._();

  /// Build light theme from current AppColors
  static ThemeData buildLightTheme() => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),

    // ───── AppBar Styling ─────
    appBarTheme: AppBarTheme(
      elevation: 1,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white.withAlpha(10),
      shadowColor: Colors.grey.shade50.withAlpha(100),
    ),

    // ───── Text Button Styling ─────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // ───── Elevated Button Styling ─────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        fixedSize: const Size.fromWidth(double.maxFinite),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    // ───── Global Input Field Styling ─────
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),

    // ───── Global Text Theme ─────
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primaryColor,
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return Colors.white;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      overlayColor: WidgetStateProperty.all(AppColors.primaryColor),
    ),
  );
}
