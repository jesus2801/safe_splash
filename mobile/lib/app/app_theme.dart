import 'package:flutter/material.dart';

import '../core/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.lagoon,
      brightness: Brightness.light,
      primary: AppColors.poolDeep,
      onPrimary: Colors.white,
      secondary: AppColors.seafoam,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base.copyWith(
        primaryContainer: AppColors.mist,
        onPrimaryContainer: AppColors.ink,
        surfaceContainerHighest: AppColors.foam,
      ),
      scaffoldBackgroundColor: AppColors.foam,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.poolDeep,
      ),
    );
  }
}
