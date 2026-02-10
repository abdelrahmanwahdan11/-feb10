import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/spreadsheet_editor_screen.dart';
import '../features/home/templates_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/review/expert_review_screen.dart';
import '../features/review/help_center_screen.dart';
import '../features/reports/reports_screen.dart';

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
      GoRoute(path: '/templates', builder: (_, __) => const TemplatesScreen()),
      GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/expert-review', builder: (_, __) => const ExpertReviewScreen()),
      GoRoute(path: '/help-center', builder: (_, __) => const HelpCenterScreen()),
    ],
  );
}
