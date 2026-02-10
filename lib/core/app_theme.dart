import 'package:flutter/material.dart';

ThemeData buildAppTheme({required TextTheme textTheme, bool isDark = false}) {
  final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);

  return base.copyWith(
    textTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF0057D8),
      secondary: const Color(0xFF6F2CFF),
      tertiary: const Color(0xFF0DBD8B),
    ),
    scaffoldBackgroundColor: isDark ? const Color(0xFF10131A) : const Color(0xFFF5F8FF),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      filled: true,
      fillColor: isDark ? const Color(0xFF1D2330) : Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
