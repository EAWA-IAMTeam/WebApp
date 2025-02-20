import 'package:flutter/material.dart';
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
  int currentPage = 1;
  List<OrderModel> orders = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrders(currentPage);
  }

  Future<void> fetchOrders(int page) async {
    setState(() => isLoading = true);
    final newOrders = await controller.fetchOrders(page);
    setState(() {
      orders = newOrders;  // Replace orders with new data
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
              height: 500,  // Scrollable fixed height
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
                                subtitle: Text('Status: ${order.status}\nTotal Price: ${order.data.totalPrice} ${order.data.currency}'),
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
            Text('Status: ${order.status}'),
            Text('Shipment Date: ${order.shipmentDate}'),
            Text('Tracking ID: ${order.trackingId}'),
            SizedBox(height: 20),
            Text('Customer Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Name: ${order.data.customerName}'),
            Text('Phone: ${order.data.customerPhone}'),
            Text('Address: ${order.data.customerAddress}'),
            SizedBox(height: 20),
            Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: order.itemList.length,
                itemBuilder: (context, index) {
                  Item item = order.itemList[index];
                  return ListTile(
                    leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(item.name),
                    subtitle: Text('Quantity: ${item.quantity}\nPrice: \$${item.paidPrice}'),
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
