import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _seenOnboardingKey = 'seen_onboarding';
  static const _authModeKey = 'auth_mode';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenOnboardingKey) ?? false;
  }

  Future<void> setSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenOnboardingKey, true);
  }

  Future<String?> getAuthMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authModeKey);
  }

  Future<void> setAuthMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authModeKey, mode);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authModeKey);
  }
}
