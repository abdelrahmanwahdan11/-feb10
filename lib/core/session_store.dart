import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _seenOnboardingKey = 'seen_onboarding';
  static const _authModeKey = 'auth_mode';
  static const _darkModeKey = 'dark_mode';
  static const _animationsKey = 'animations_enabled';
  static const _promptDraftKey = 'draft_prompt';
  static const _lastRouteKey = 'last_route';
  static const _localeCodeKey = 'locale_code';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<bool> hasSeenOnboarding() async => (await _prefs).getBool(_seenOnboardingKey) ?? false;

  Future<void> setSeenOnboarding() async => (await _prefs).setBool(_seenOnboardingKey, true);

  Future<String?> getAuthMode() async => (await _prefs).getString(_authModeKey);

  Future<void> setAuthMode(String mode) async => (await _prefs).setString(_authModeKey, mode);

  Future<bool> getDarkMode() async => (await _prefs).getBool(_darkModeKey) ?? true;

  Future<void> setDarkMode(bool value) async => (await _prefs).setBool(_darkModeKey, value);

  Future<bool> getAnimationsEnabled() async => (await _prefs).getBool(_animationsKey) ?? true;

  Future<void> setAnimationsEnabled(bool value) async => (await _prefs).setBool(_animationsKey, value);

  Future<bool> getBoolPref(String key, {bool defaultValue = false}) async => (await _prefs).getBool(key) ?? defaultValue;

  Future<void> setBoolPref(String key, bool value) async => (await _prefs).setBool(key, value);

  Future<int> getIntPref(String key, {int defaultValue = 0}) async => (await _prefs).getInt(key) ?? defaultValue;

  Future<void> setIntPref(String key, int value) async => (await _prefs).setInt(key, value);

  Future<void> incrementIntPref(String key, {int by = 1}) async {
    final current = await getIntPref(key);
    await setIntPref(key, current + by);
  }

  Future<String?> getStringPref(String key) async => (await _prefs).getString(key);

  Future<void> setStringPref(String key, String value) async => (await _prefs).setString(key, value);

  Future<void> setPromptDraft(String value) => setStringPref(_promptDraftKey, value);

  Future<String?> getPromptDraft() => getStringPref(_promptDraftKey);

  Future<void> clearPromptDraft() async => (await _prefs).remove(_promptDraftKey);

  Future<void> setLastVisitedRoute(String route) => setStringPref(_lastRouteKey, route);

  Future<String?> getLastVisitedRoute() => getStringPref(_lastRouteKey);

  Future<void> clearLastVisitedRoute() async => (await _prefs).remove(_lastRouteKey);

  Future<void> setLocaleCode(String code) => setStringPref(_localeCodeKey, code);

  Future<String?> getLocaleCode() => getStringPref(_localeCodeKey);

  Future<void> resetPreferences() async {
    final prefs = await _prefs;
    await prefs.remove(_darkModeKey);
    await prefs.remove(_animationsKey);
  }

  Future<void> signOut() async {
    final prefs = await _prefs;
    await prefs.remove(_authModeKey);
    await prefs.remove(_lastRouteKey);
    await prefs.remove(_promptDraftKey);
  }
}
