import 'dart:convert';
import 'package:http/http.dart' as http;

class RxNormService {
  final String _baseUrl = 'https://rxnav.nlm.nih.gov/REST';

  Future<Map<String, dynamic>?> getMedicineByNdc(String ndc) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/ndcstatus.json?ndc=$ndc'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch medicine data: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> searchMedicineByName(String name) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/drugs.json?name=$name'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(
        data['drugGroup']['conceptGroup'] ?? [],
      );
    } else {
      throw Exception('Failed to search medicine: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getInteractions(
    List<String> rxcuis,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/interaction/list.json?rxcuis=${rxcuis.join("+")}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(
        data['fullInteractionTypeGroup'] ?? [],
      );
    } else {
      throw Exception('Failed to get interactions: ${response.body}');
    }
  }
}
