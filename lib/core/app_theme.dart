import 'package:flutter/material.dart';

ThemeData buildAppTheme({required TextTheme textTheme, bool isDark = false}) {
  final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
  final primary = const Color(0xFF4F46E5);
  final secondary = const Color(0xFF7C3AED);
  final tertiary = const Color(0xFF06B6D4);

  return base.copyWith(
    textTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surfaceTint: primary,
    ),
    scaffoldBackgroundColor: isDark ? const Color(0xFF0E1320) : const Color(0xFFF4F7FF),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF11192B) : Colors.white,
      surfaceTintColor: Colors.transparent,
      foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: isDark ? const Color(0xFF151E33) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1C2640) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: primary,
      textColor: isDark ? Colors.white : const Color(0xFF0F172A),
    ),
    dividerTheme: DividerThemeData(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0), thickness: 0.8),
  );
}
