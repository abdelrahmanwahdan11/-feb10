import 'package:google_generative_ai/google_generative_ai.dart';

import '../../core/app_config.dart';

class GeminiService {
  GeminiService({String? apiKey}) : _apiKey = apiKey ?? AppConfig.geminiApiKey;

  final String _apiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> runPrompt(
    String prompt, {
    required String missingKeyMessage,
    String fallbackErrorMessage = 'AI error. Please try again.',
  }) async {
    if (!isConfigured) return missingKeyMessage;

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final response = await model.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 30));
      final text = response.text?.trim();
      return (text == null || text.isEmpty) ? fallbackErrorMessage : text;
    } catch (_) {
      return fallbackErrorMessage;
    }
  }
}
