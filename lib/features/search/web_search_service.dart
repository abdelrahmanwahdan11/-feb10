import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class WebSearchService {
  WebSearchService({required this.apiKey, required this.cx, http.Client? client}) : _client = client ?? http.Client();

  final String apiKey;
  final String cx;
  final http.Client _client;

  bool get isConfigured => apiKey.isNotEmpty && cx.isNotEmpty;

  Future<List<String>> search(String query) async {
    if (!isConfigured || query.trim().isEmpty) return [];

    final uri = Uri.https(
      'www.googleapis.com',
      '/customsearch/v1',
      {
        'key': apiKey,
        'cx': cx,
        'q': query,
        'num': '3',
      },
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return [];

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (payload['items'] as List<dynamic>? ?? <dynamic>[]).cast<Map<String, dynamic>>();

    return items.map((item) => '- ${item['title'] ?? 'Untitled'}\n  ${item['link'] ?? ''}').toList(growable: false);
  }
}
