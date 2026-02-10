import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GeminiService({String? apiKey})
      : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  final String _apiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> runPrompt(String prompt) async {
    if (!isConfigured) {
      return 'Gemini API key is missing. Set --dart-define=GEMINI_API_KEY=...';
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No response';
  }
}
