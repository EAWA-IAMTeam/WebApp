import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
// Import the Inventory and Store classes
import 'inventory.dart';
import 'store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Store store;
  late Inventory inventory;

  // Add a variable to store fetched products
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    store = Store.fromJson(jsonData);
    inventory = Inventory.fromJson(jsondata);
    _listenForTokenMessage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _listenForTokenMessage() {
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data != null) {
        // Save the tokens to localStorage
        html.window.localStorage['keycloakAccessToken'] =
            data['keycloakAccessToken'];
        html.window.localStorage['email'] = data['email'];
      }
    });
  }

  Future<void> fetchProducts(int storeId) async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.0.73:5000/api/products?store_id=$storeId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("Get Product successfully");
        print(response.body);

        // Update the _products list and call setState
        setState(() {
          _products = data.map((product) {
            return {
              'id': product['id'],
              'price': product['price'],
              'discounted_price': product['discounted_price'],
              'sku': product['sku'],
              'currency': product['currency'],
              'status': product['status'],
              'stock_item_id': product['stock_item_id'],
            };
          }).toList();
        });
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
        title: const Text('E-Commerce'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Account'),
            Tab(text: 'Product'),
          ],
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Account Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Store ID: ${store.id}'),
                        Text('Store Name: ${store.name}'),
                      ],
                    ),
                  ),
                  // Product Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock Code: ${inventory.stockCode}'),
                        Text('Description: ${inventory.description}'),
                        Text('Quantity: ${inventory.quantity}'),
                        Text('Cost: RM${inventory.cost}'),
                        // Display the fetched products here
                        _products.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: _products.length,
                                  itemBuilder: (context, index) {
                                    final product = _products[index];
                                    return Card(
                                      margin: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        title: Text('SKU: ${product['sku']}'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Price: RM${product['price']}'),
                                            Text(
                                                'Discounted Price: RM${product['discounted_price']}'),
                                            Text(
                                                'Stock Item ID: ${product['stock_item_id']}'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Text('No products available')
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  // html.window.location.href = 'http://localhost:3001'; //Redirect user to another app in same tab
                  html.window.open('http://localhost:3001',
                      '_blank'); //Open the web app in another new window
                  //192.168.0.102:8000
                  _listenForTokenMessage();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  fetchProducts(2);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Fetch'), // Fetch from ecommerce web app
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                    'Post'), //post to ecommerce web app from mock sql account
              ),
            ],
          ),
          const SizedBox(width: 20), // Add space to the right of the buttons
        ],
      ),
    );
  }
}
