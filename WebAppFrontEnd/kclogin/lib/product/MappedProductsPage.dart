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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store Product ID: ${product['stock_item_id']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Ref. Price: ${product['ref_price']} MYR'),
                        Text('Ref. Cost: ${product['ref_cost']} MYR'),
                        SizedBox(height: 8),
                        Divider(),
                        Text(
                          'Store Items:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: storeProducts.map<Widget>((storeProduct) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text('SKU: ${storeProduct['sku']}'),
                            );
                          }).toList(),
                        ),
                        if (storeProducts.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text('Currency: ${storeProducts[0]['currency']}'),
                          Text('Status: ${storeProducts[0]['status']}'),
                        ],
                        SizedBox(height: 8),
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
