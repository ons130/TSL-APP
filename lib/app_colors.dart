import 'package:flutter/material.dart';

class AppColors {
  static const MaterialColor orangeSwatch = MaterialColor(
    0xFFFF9874,
    <int, Color>{
      50: Color(0xFFFFF0EA),
      100: Color(0xFFFFDBCC),
      200: Color(0xFFFFC4AB),
      300: Color(0xFFFFAD89),
      400: Color(0xFFFF9D73),
      500: Color(0xFFFF9874),
      600: Color(0xFFF58064),
      700: Color(0xFFDA6952),
      800: Color(0xFFBF533F),
      900: Color(0xFFA43D2D),
    },
  );

  static const MaterialColor blueSwatch = MaterialColor(
    0xFF9DBDFF,
    <int, Color>{
      50: Color(0xFFEFF4FF),
      100: Color(0xFFD7E3FF),
      200: Color(0xFFBDD0FF),
      300: Color(0xFFA3BDFF),
      400: Color(0xFF8FB0FF),
      500: Color(0xFF9DBDFF),
      600: Color(0xFF7BA5FF),
      700: Color(0xFF6696FF),
      800: Color(0xFF5287F5),
      900: Color(0xFF316EF0),
    },
  );

  static const lightBackground = Color(0xFFF5F7FA);
  static const darkBackground = Color(0xFF121212);
  static const textLight = Color(0xFF2D2D2D);
  static const textDark = Color(0xFFF2F2F2);
}

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primarySwatch: AppColors.orangeSwatch,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.orangeSwatch,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orangeSwatch[500],
        foregroundColor: Colors.white,
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: AppColors.orangeSwatch,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.orangeSwatch[800],
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orangeSwatch[600],
        foregroundColor: Colors.white,
      ),
    ),
  );
}
