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
      title: 'Account',
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
  html.WindowBase? newTabWindow; // Track the new tab
  // Add a variable to store fetched mapped products
  List<Map<String, dynamic>> _products = [];
  // Add a variable to store sql stock item
  List<Map<String, dynamic>> allProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 1, vsync: this); //If tab = 2, length should be changed to 2
    store = Store.fromJson(jsonData);
    inventory = Inventory.fromJson(jsondata);
    _listenForTokenMessage();
    saveProduct("1011", "Description 11", 11, 2000);
    loadAllProducts();
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

        // Extract the actual product details inside "store_products"
        setState(() {
          _products = [];
          for (var stockItem in data) {
            if (stockItem.containsKey('store_products')) {
              for (var product in stockItem['store_products']) {
                _products.add({
                  'id': product['id'],
                  'price': product['price'],
                  'discounted_price': product['discounted_price'],
                  'sku': product['sku'],
                  'currency': product['currency'],
                  'status': product['status'],
                  'stock_item_id':
                      stockItem['stock_item_id'], // Link to stock item
                });
              }
            }
          }
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  void loadAllProducts() {
    // Retrieve and decode all products from localStorage
    final storedData = html.window.localStorage['allProducts'] ?? "[]";

    // Explicitly cast to List<Map<String, dynamic>> after decoding
    setState(() {
      allProducts = List<Map<String, dynamic>>.from(jsonDecode(storedData)
          .map((product) => Map<String, dynamic>.from(product)));
    });
  }

  void saveProduct(
      String stockCode, String description, int quantity, double cost) {
    Map<String, dynamic> newProduct = {
      "stockCode": stockCode,
      "description": description,
      "quantity": quantity,
      "cost": cost
    };

    allProducts.add(newProduct);
    html.window.localStorage['allProducts'] = jsonEncode(allProducts);
    loadAllProducts();
  }

  void showAddProductDialog() {
    TextEditingController stockCodeController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockCodeController,
                decoration: InputDecoration(labelText: "Stock Code"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: costController,
                decoration: InputDecoration(labelText: "Cost (MYR)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String stockCode = stockCodeController.text.trim();
                String description = descriptionController.text.trim();
                int quantity = int.tryParse(quantityController.text) ?? 0;
                double cost = double.tryParse(costController.text) ?? 0.0;

                if (stockCode.isEmpty ||
                    description.isEmpty ||
                    quantity <= 0 ||
                    cost <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Please enter valid product details.")),
                  );
                  return;
                }

                saveProduct(stockCode, description, quantity, cost);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void sendProductsToBackend() async {
    // Retrieve user input from local storage
    final storedData = html.window.localStorage['allProducts'] ?? '[]';

    // Decode the JSON into a list of maps
    List<Map<String, dynamic>> products =
        List<Map<String, dynamic>>.from(jsonDecode(storedData));

    // Ensure the data is in the right format
    print('Sending products: $products');

    // Send only user input to backend
    final response = await http.post(
      Uri.parse("http://localhost:8013/products"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(products),
    );

    if (response.statusCode == 200) {
      print("Products successfully sent!");
    } else {
      print("Error sending products: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Account'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            //Tab(text: 'Account'),
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
                  // // Account Tab
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text('Store ID: ${store.id}'),
                  //       Text('Store Name: ${store.name}'),
                  //     ],
                  //   ),
                  // ),
                  // Product Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: allProducts.length,
                            itemBuilder: (context, index) {
                              var product = allProducts[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Stock Code: ${product['stockCode']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 4),
                                        Text(
                                            "Description: ${product['description']}"),
                                        Text(
                                            "Quantity: ${product['quantity']}"),
                                        Text("Cost: MYR ${product['cost']}"),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // html.window.location.href = 'http://localhost:3001'; //Redirect user to another app in same tab
                  // html.window.open('http://localhost:3001', '_blank'); //Open the web app in another new window
                  //192.168.0.102:8000
                  if (newTabWindow == null || (newTabWindow!.closed ?? true)) {
                    // Open a new tab if it's not already open or is closed
                    newTabWindow =
                        html.window.open('http://localhost:3001', '_blank');
                  }
                  _listenForTokenMessage();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Login'),
              ),
              // const SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: () {
              //     fetchProducts(2);
              //   },
              //   style: ElevatedButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //   ),
              //   child: const Text('Fetch'), // Fetch from ecommerce web app
              // ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: showAddProductDialog,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Add Item'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  sendProductsToBackend();
                },
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
