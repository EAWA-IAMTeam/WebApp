import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kclogin/config.dart';

class ApiService {
  static Future<List<dynamic>> fetchSQLProducts(
      String url, String token) async {
    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load SQL products');
    }
  }

  static Future<Map<String, List<dynamic>>> fetchPlatformProducts(
      String url, String token) async {
    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'unmapped_products': data['unmapped_products'] ?? [],
        'mapped_products': data['mapped_products'] ?? [],
      };
    } else {
      throw Exception('Failed to load platform products');
    }
  }

  static Future<void> mapProducts(
      String url, Map<String, dynamic> body, String token) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(body),
    );
    print(response.body);
    if (response.statusCode != 201) {
      throw Exception('Failed to map products: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchProducts(
      int storeId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/products/store/$storeId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((product) {
          return {
            'quantity': product['quantity'],
            'ref_cost': product['ref_cost'],
            'ref_price': product['ref_price'],
            'stock_item_id': product['stock_item_id'],
            'store_products': (product['store_products'] as List<dynamic>)
                .map((storeProduct) {
              return {
                'id': storeProduct['id'],
                'price': storeProduct['price'],
                'discounted_price': storeProduct['discounted_price'],
                'sku': storeProduct['sku'],
                'currency': storeProduct['currency'],
                'status': storeProduct['status'],
              };
            }).toList(),
          };
        }).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
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
