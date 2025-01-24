import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import "package:flutter_html/flutter_html.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Product',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: LinkProductPage(),
    );
  }
}

class LinkProductPage extends StatefulWidget {
  @override
  _LinkProductPageState createState() => _LinkProductPageState();
}

class _LinkProductPageState extends State<LinkProductPage> {
  List<dynamic> sqlProducts = [];
  List<dynamic> platformProducts = [];

  Future<void> fetchSQLProducts() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.73:5000/api/products'));

    if (response.statusCode == 200) {
      setState(() {
        sqlProducts = json.decode(response.body);
      });
    } else {
      print('Failed to load SQL products');
    }
  }

  Future<void> fetchPlatformProducts() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.240:7000/products'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        platformProducts = data['data']['products'];
      });
    } else {
      print('Failed to load platform products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'SQL Inventory',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: fetchSQLProducts,
                          child: Text('Fetch SQL Products'),
                        ),
                        Expanded(
                          child: sqlProducts.isEmpty
                              ? Center(child: Text('No Data'))
                              : ListView.builder(
                                  itemCount: sqlProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = sqlProducts[index];
                                    return Card(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: false,
                                              onChanged: (bool? value) {
                                                // Handle checkbox change
                                              },
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'SKU ID: ${product['sku']}'),
                                                  Text(
                                                      'Product Desc: ${product['description']}'),
                                                  Text(
                                                      'Stock (Unit): ${product['stock']}'),
                                                  Text(
                                                      'Ref. Cost (MYR): ${product['cost']}'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Platform Product',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: fetchPlatformProducts,
                          child: Text('Fetch Platform Products'),
                        ),
                        Expanded(
                          child: platformProducts.isEmpty
                              ? Center(child: Text('No Data'))
                              : ListView.builder(
                                  itemCount: platformProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = platformProducts[index];
                                    final skus =
                                        product['skus'] as List<dynamic>;
                                    final sku =
                                        skus.isNotEmpty ? skus[0] : null;

                                    return Card(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: false,
                                              onChanged: (bool? value) {
                                                // Handle checkbox change
                                              },
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Item ID: ${product['item_id']}'),
                                                  Text(
                                                      'Name: ${product['attributes']['name']}'),
                                                  Text(
                                                      'Short Description: ${product['attributes']['short_description']}'),
                                                  if (sku != null) ...[
                                                    Text(
                                                        'Quantity: ${sku['quantity']}'),
                                                    Text(
                                                        'Price (MYR): ${sku['price']}'),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle map action
              },
              child: Text('Map'),
            ),
          ],
        ),
      ),
    );
  }
}
