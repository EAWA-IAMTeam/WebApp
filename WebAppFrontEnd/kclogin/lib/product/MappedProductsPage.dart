import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    mappedProducts = fetchProducts(widget.storeId);
  }

  Future<List<Map<String, dynamic>>> fetchProducts(int storeId) async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.0.73:5000/api/products?store_id=$storeId'));

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
