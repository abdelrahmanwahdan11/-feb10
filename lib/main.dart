import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app_router.dart';
import 'core/app_localizations.dart';
import 'core/app_theme.dart';
import 'core/session_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExcelAiAssistantApp());
}

class ExcelAiAssistantApp extends StatefulWidget {
  const ExcelAiAssistantApp({super.key});

  @override
  State<ExcelAiAssistantApp> createState() => _ExcelAiAssistantAppState();
}

class _ExcelAiAssistantAppState extends State<ExcelAiAssistantApp> with WidgetsBindingObserver {
  final _store = SessionStore();
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restorePreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restorePreferences();
    }
  }

  Future<void> _restorePreferences() async {
    final code = await _store.getLocaleCode();
    final darkMode = await _store.getDarkMode();
    if (!mounted) return;
    setState(() {
      if (code != null && code.isNotEmpty) {
        _locale = Locale(code);
      }
      _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleLocale() {
    final next = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    setState(() => _locale = next);
    _store.setLocaleCode(next.languageCode);
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
      themeMode: _themeMode,
      routerConfig: router,
    );
  }
}
