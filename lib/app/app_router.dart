import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/spreadsheet_editor_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';

GoRouter buildRouter({required void Function() onToggleLanguage}) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => HomeScreen(onToggleLanguage: onToggleLanguage),
      ),
      GoRoute(path: '/sheet', builder: (_, __) => const SpreadsheetEditorScreen()),
    ],
  );
}
