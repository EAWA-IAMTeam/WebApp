import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<dynamic>> fetchSQLProducts(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load SQL products');
    }
  }

  static Future<List<dynamic>> fetchPlatformProducts(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['products'];
    } else {
      throw Exception('Failed to load platform products');
    }
  }

  static Future<void> mapProducts(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to map products: ${response.body}');
    }
  }

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
