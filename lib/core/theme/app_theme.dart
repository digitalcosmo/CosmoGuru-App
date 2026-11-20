import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        primary: AppColors.red,
        surface: AppColors.card,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.tx,
        displayColor: AppColors.tx,
      ),
      splashFactory: InkSparkle.splashFactory,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.red,
        selectionHandleColor: AppColors.red,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.card,
        headerBackgroundColor: AppColors.red,
        headerForegroundColor: Colors.white,
        todayBorder: const BorderSide(color: AppColors.red),
        dayBackgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.red : null,
        ),
      ),
    );
  }
}
