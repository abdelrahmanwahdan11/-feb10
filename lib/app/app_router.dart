import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/spreadsheet_editor_screen.dart';
import '../features/home/templates_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/account/profile_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/privacy/privacy_security_screen.dart';
import '../features/progress/progress_center_screen.dart';
import '../features/billing/billing_screen.dart';
import '../features/team/team_workspace_screen.dart';
import '../features/integrations/integrations_screen.dart';
import '../features/activity/activity_timeline_screen.dart';
import '../features/backup/backup_restore_screen.dart';
import '../features/support/support_tickets_screen.dart';
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
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacySecurityScreen()),
      GoRoute(path: '/progress', builder: (_, __) => const ProgressCenterScreen()),
      GoRoute(path: '/billing', builder: (_, __) => const BillingScreen()),
      GoRoute(path: '/team', builder: (_, __) => const TeamWorkspaceScreen()),
      GoRoute(path: '/integrations', builder: (_, __) => const IntegrationsScreen()),
      GoRoute(path: '/activity', builder: (_, __) => const ActivityTimelineScreen()),
      GoRoute(path: '/backup', builder: (_, __) => const BackupRestoreScreen()),
      GoRoute(path: '/support-tickets', builder: (_, __) => const SupportTicketsScreen()),
      GoRoute(path: '/expert-review', builder: (_, __) => const ExpertReviewScreen()),
      GoRoute(path: '/help-center', builder: (_, __) => const HelpCenterScreen()),
    ],
  );
}
