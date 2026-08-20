import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF12343B);
  static const parchment = Color(0xFFF1F5F3);
  static const paper = Color(0xFFFFFFFF);
  static const fatah = Color(0xFFC4863F);
  static const hamas = Color(0xFF147D78);
  static const undecided = Color(0xFFC9D3D0);
  static const alert = Color(0xFFB34E3D);
  static const slate = Color(0xFF58758A);
  static const mint = Color(0xFFDDEEEA);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.parchment,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.hamas,
      brightness: Brightness.light,
      surface: AppColors.paper,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.parchment,
      elevation: 0,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFD8E1DE)),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paper,
      border: OutlineInputBorder(borderSide: BorderSide.none),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      bodySmall: TextStyle(color: Colors.black54, fontSize: 12),
    ),
  );
}
