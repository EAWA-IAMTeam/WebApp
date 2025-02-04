import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static Future<List<dynamic>> fetchStores(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load stores');
    }
  }
}
