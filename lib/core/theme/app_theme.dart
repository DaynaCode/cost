import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static const fontFamily = 'Vazirmatn';

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? Typography.blackMountainView
        : Typography.whiteMountainView;
    return base.apply(fontFamily: fontFamily);
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _textTheme(Brightness.light),
      fontFamily: fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEDEDED),
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4F6F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF9E9E9E),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F3F0),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.accent,
      secondary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _textTheme(Brightness.dark),
      fontFamily: fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A342A),
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF232E23),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Color(0xFF7A8A7A),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF232E23),
        selectedColor: AppColors.accent.withValues(alpha: 0.25),
        labelStyle: const TextStyle(
            fontFamily: fontFamily, fontSize: 13, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
