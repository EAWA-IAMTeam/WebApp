import 'package:flutter/material.dart';
import 'services.dart'; // Import the services.dart file

class MappedProductsPage extends StatefulWidget {
  final int storeId; // Pass storeId as parameter to the page

  const MappedProductsPage({super.key, required this.storeId});

  @override
  _MappedProductsPageState createState() => _MappedProductsPageState();
}

class _MappedProductsPageState extends State<MappedProductsPage> {
  late Future<List<Map<String, dynamic>>> mappedProducts;

  @override
  void initState() {
    super.initState();
    // Fetch products when the widget is initialized
    mappedProducts = ApiService.fetchProducts(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapped Products'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: mappedProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No mapped products found'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final storeProducts =
                    product['store_products'] as List<dynamic>;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      'Store Product ID: ${product['stock_item_id']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ref. Price: ${product['ref_price']} MYR'),
                        Text('Ref. Cost: ${product['ref_cost']} MYR'),
                        // Display SKUs for all store products
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: storeProducts.map<Widget>((storeProduct) {
                            return Text('SKU: ${storeProduct['sku']}');
                          }).toList(),
                        ),
                        // Display currency and status only once
                        if (storeProducts.isNotEmpty) ...[
                          Text('Currency: ${storeProducts[0]['currency']}'),
                          Text('Status: ${storeProducts[0]['status']}'),
                        ],
                        Text('Stock Item ID: ${product['stock_item_id']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
