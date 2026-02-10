class AppConfig {
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const searchApiKey = String.fromEnvironment('SEARCH_API_KEY', defaultValue: '');
  static const searchEngineCx = String.fromEnvironment('SEARCH_ENGINE_CX', defaultValue: '');

  static bool get hasGemini => geminiApiKey.isNotEmpty;
  static bool get hasSearch => searchApiKey.isNotEmpty && searchEngineCx.isNotEmpty;
}
