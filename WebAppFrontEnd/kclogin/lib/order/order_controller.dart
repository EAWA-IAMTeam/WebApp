import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kclogin/home/config.dart';
import 'package:kclogin/order/order_model.dart';

class OrderController {
  /// Fetch orders and determine whether to deduplicate based on quantity values.
  Future<List<OrderModel>> fetchOrders(int page, String token) async {
    try {
      final response = await http.get(
        Uri.parse("${Config.orderUrl}?page=$page&limit=10"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print("✅ API Response: ${response.body}");

        final List<dynamic> data = json.decode(response.body);
        List<OrderModel> orders = [];

        for (var orderJson in data) {
          try {
            OrderModel order = OrderModel.fromJson(orderJson);

            // ✅ Check if any item has quantity == 0
            // If the platform is Lazada, the order may contains duplicated orderitem
            // as the quantity of the orderitem is not 1 (it does not shows the quantity directly)
            // ✅ Check if any item has quantity == 0
            bool hasZeroQuantity =
                order.itemList.any((item) => item.quantity == 0);

            if (hasZeroQuantity) {
              print("🔄 Applying deduplication due to zero quantity items.");
              Map<String, OrderItem> uniqueItems = {};

              for (var item in order.itemList) {
                String shopSku = item.shopSku;

                if (item.quantity == 0) {
                  // ✅ Deduplicate and sum if quantity == 0
                  if (uniqueItems.containsKey(shopSku)) {
                    uniqueItems[shopSku]!.quantity +=
                        1; // Each duplicate should count as +1
                  } else {
                    uniqueItems[shopSku] = item;
                    uniqueItems[shopSku]!.quantity = 1; // Reset to 1, then sum
                  }
                } else {
                  // ✅ Keep original item with quantity > 0
                  uniqueItems[shopSku] = item;
                }
              }

              // ✅ Replace order list with deduplicated items
              order.itemList = uniqueItems.values.toList();
            } else {
              print("✅ Keeping original quantities from API.");
            }

            orders.add(order);
          } catch (e) {
            print("❌ Error parsing order: $orderJson");
            print("⚠️ Exception: $e");
          }
        }

        return orders;
      } else {
        print("❌ API Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to load orders: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ General Error fetching orders: $e");
      return [];
    }
  }
}
