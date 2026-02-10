import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app_router.dart';
import 'core/app_localizations.dart';
import 'core/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExcelAiAssistantApp());
}

class ExcelAiAssistantApp extends StatefulWidget {
  const ExcelAiAssistantApp({super.key});

  @override
  State<ExcelAiAssistantApp> createState() => _ExcelAiAssistantAppState();
}

class _ExcelAiAssistantAppState extends State<ExcelAiAssistantApp> {
  Locale _locale = const Locale('ar');

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(onToggleLanguage: _toggleLocale);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildAppTheme(
        textTheme: GoogleFonts.tajawalTextTheme(),
      ),
      darkTheme: buildAppTheme(
        textTheme: GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme),
        isDark: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
