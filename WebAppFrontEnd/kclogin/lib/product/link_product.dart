import 'package:flutter/material.dart';
import 'package:kclogin/config.dart';
import 'package:kclogin/product/MappedProductsPage.dart';
import 'package:kclogin/product/platform_product.dart';
import 'package:kclogin/product/services.dart';
import 'package:kclogin/product/sql_product.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class LinkProductPage extends StatefulWidget {
  const LinkProductPage({super.key});

  @override
  _LinkProductPageState createState() => _LinkProductPageState();
}

class _LinkProductPageState extends State<LinkProductPage> {
  List<dynamic> sqlProducts = [];
  List<dynamic> platformProducts = [];
  dynamic selectedSQLProduct;
  Set<dynamic> selectedPlatformProducts = {};
  List<dynamic> filteredProducts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredProducts = platformProducts;
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = platformProducts.where((product) {
        final skus = product['skus'] as List<dynamic>;
        final attributes = product['attributes'] as Map<String, dynamic>;

        // Check for null and use empty string if null
        final name = attributes['name']?.toLowerCase() ?? '';
        final description = attributes['description']?.toLowerCase() ?? '';

        return skus.any((sku) =>
                sku['ShopSku'].toLowerCase().contains(query.toLowerCase())) ||
            name.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> fetchSQLProducts() async {
    try {
      final products = await ApiService.fetchSQLProducts(Config.sqlProductsUrl);
      setState(() {
        sqlProducts = products;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchPlatformProducts() async {
    try {
      final products =
          await ApiService.fetchPlatformProducts(Config.platformProductsUrl);
      setState(() {
        platformProducts = products;
        filteredProducts = platformProducts;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Product'),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     html.window.location.href = 'http://localhost:3001';
        //   },
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Company ID: 10002', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  SQLProductList(
                    products: sqlProducts,
                    onFetch: fetchSQLProducts,
                    selectedProduct: selectedSQLProduct,
                    onSelect: (product) => setState(() {
                      selectedSQLProduct = product;
                    }),
                  ),
                  VerticalDivider(),
                  PlatformProductList(
                    products: filteredProducts,
                    onFetch: fetchPlatformProducts,
                    selectedProducts: selectedPlatformProducts,
                    onSelect: (sku) => setState(() {
                      if (selectedPlatformProducts.contains(sku)) {
                        selectedPlatformProducts.remove(sku);
                      } else {
                        selectedPlatformProducts.add(sku);
                      }
                    }),
                    onSearch: updateSearchQuery,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedSQLProduct != null) {
                  List<Map<String, dynamic>> products =
                      selectedPlatformProducts.map((sku) {
                    return {
                      'stock_item_id': selectedSQLProduct['id'],
                      'price': sku['price'],
                      'discounted_price': sku['special_price'],
                      'sku': sku['ShopSku'],
                      'currency': Config.currency,
                      'status': sku['Status'],
                    };
                  }).toList();

                  Map<String, dynamic> requestBody = {
                    'store_id': Config.storeId,
                    'products': products,
                  };

                  try {
                    await ApiService.mapProducts(
                        Config.mapProductsUrl, requestBody);
                    print('Products mapped successfully');
                  } catch (e) {
                    print(e);
                  }
                }
              },
              child: Text('Map'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MappedProductsPage(storeId: Config.storeId),
                  ),
                );
              },
              child: Text('View Mapped Products'),
            ),
          ],
        ),
      ),
    );
  }
}
