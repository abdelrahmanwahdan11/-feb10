import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class WebSearchService {
  WebSearchService({required this.apiKey, required this.cx, http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final String apiKey;
  final String cx;
  final http.Client _client;
  final bool _ownsClient;

  bool get isConfigured => apiKey.isNotEmpty && cx.isNotEmpty;

  Future<List<String>> search(String query) async {
    final normalizedQuery = query.trim();
    if (!isConfigured || normalizedQuery.isEmpty) return [];

    final uri = Uri.https(
      'www.googleapis.com',
      '/customsearch/v1',
      {
        'key': apiKey,
        'cx': cx,
        'q': normalizedQuery,
        'num': '5',
      },
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];

      final payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic>) return [];

      final items = payload['items'];
      if (items is! List) return [];

      return items
          .whereType<Map<String, dynamic>>()
          .map((item) => '- ${item['title'] ?? 'Untitled'}\n  ${item['link'] ?? ''}')
          .toList(growable: false);
    } on TimeoutException {
      return [];
    } on FormatException {
      return [];
    }
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
