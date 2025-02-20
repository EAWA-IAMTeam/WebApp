import 'package:flutter/material.dart';
import 'package:kclogin/home/config.dart';
import 'package:kclogin/home/controllers/auth_controller.dart';
import 'package:kclogin/order/order_model.dart';
import 'order_controller.dart';

class OrdersView extends StatefulWidget {
  final String keycloakAccessToken;
  final String keycloakRefreshToken;

  OrdersView({super.key, required this.keycloakAccessToken, required this.keycloakRefreshToken});

  @override
  _OrdersViewState createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final OrderController controller = OrderController();
  final AuthController _authController = AuthController();
  int currentPage = 1;
  List<OrderModel> orders = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final response = await _authController.callApiWithToken(
        Config.orderUrl, widget.keycloakAccessToken, widget.keycloakRefreshToken);
    if (response != null && response.statusCode == 200) {
      fetchOrders(currentPage);
    }
  }

  Future<void> fetchOrders(int page) async {
    setState(() => isLoading = true);
    final newOrders = await controller.fetchOrders(page, widget.keycloakAccessToken);
    setState(() {
      orders = newOrders; // Replace orders with new data
      currentPage = page;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: 500, // Scrollable fixed height
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? Center(child: Text("No orders available."))
                      : ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            OrderModel order = orders[index];
                            return Card(
                              margin: EdgeInsets.all(10),
                              child: ListTile(
                                title: Text('Order ID: ${order.platformOrderId}'),
                                subtitle: Text(
                                    'Status: ${order.orderStatus}\nTotal Price:  ${order.data.currency} ${order.data.totalAmount}'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailView(order: order),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 1 && !isLoading ? () => fetchOrders(currentPage - 1) : null,
                  child: Text("Previous Page"),
                ),
                Text("Page $currentPage"),
                ElevatedButton(
                  onPressed: !isLoading ? () => fetchOrders(currentPage + 1) : null,
                  child: Text("Next Page"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailView extends StatelessWidget {
  final OrderModel order;

  OrderDetailView({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.platformOrderId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Status: ${order.orderStatus}'),
            Text('Shipment Date: ${order.shipmentDate}'),
            Text('Tracking ID: ${order.trackingId.isNotEmpty ? order.trackingId : "N/A"}'),
            SizedBox(height: 20),
            Text('Customer Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Name: ${order.data.customerName.isNotEmpty ? order.data.customerName : "N/A"}'),
            Text('Phone: ${order.data.customerPhone.isNotEmpty ? order.data.customerPhone : "N/A"}'),
            Text('Address: ${order.data.customerAddress.isNotEmpty ? order.data.customerAddress : "N/A"}'),
            SizedBox(height: 20),
            Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: order.itemList.length,
                itemBuilder: (context, index) {
                  OrderItem item = order.itemList[index];
                  return Card(
                    child: ListTile(
                      leading: item.productMainImage.isNotEmpty
                          ? Image.network(item.productMainImage, width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.image_not_supported),
                      title: Text(item.name),
                      subtitle: Text('Quantity: ${item.quantity}\nPrice: ${order.data.currency} ${item.paidPrice}'),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
