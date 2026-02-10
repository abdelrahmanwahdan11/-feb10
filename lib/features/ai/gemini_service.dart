import 'package:google_generative_ai/google_generative_ai.dart';

import '../../core/app_config.dart';

class GeminiService {
  GeminiService({String? apiKey}) : _apiKey = apiKey ?? AppConfig.geminiApiKey;

  final String _apiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> runPrompt(String prompt, {required String missingKeyMessage}) async {
    if (!isConfigured) return missingKeyMessage;

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response';
    } catch (e) {
      return 'AI error: $e';
    }
  }
}
