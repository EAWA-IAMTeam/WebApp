import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kclogin/home/config.dart';
import 'package:kclogin/order/order_model.dart';

class OrderController {
  Future<List<OrderModel>> fetchOrders(int page) async {
    try {
      final response = await http.get(Uri.parse("${Config.orderUrl}?page=$page&limit=10"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load orders: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }
}
