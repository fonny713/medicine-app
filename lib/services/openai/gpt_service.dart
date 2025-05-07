import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAiService {
  final String _apiKey;
  final String _endpoint = 'https://api.openai.com/v1/chat/completions';

  OpenAiService(this._apiKey);

  Future<Map<String, dynamic>> analyzeMedicine({
    required String name,
    required List<String> ingredients,
    required String use,
  }) async {
    final prompt = '''
      Analyze the following medicine and its ingredients.
      Name: $name
      Ingredients: ${ingredients.join(', ')}
      Use: $use

      Return a JSON with:
      - naturalness (0-100%)
      - short summary (2 sentences)
      - common side effects (list)
      - interactions (mention if it interacts with other common drugs)
    ''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return jsonDecode(content);
    } else {
      throw Exception('Failed to analyze medicine: ${response.body}');
    }
  }
}
