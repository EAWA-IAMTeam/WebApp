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
  List<dynamic> mappedProducts = [];
  List<dynamic> filteredProducts = [];
  List<dynamic> filteredMappedProducts = [];
  dynamic selectedSQLProduct;
  Set<dynamic> selectedPlatformProducts = {};
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSQLProducts();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();

      // Filter unmapped products
      filteredProducts = platformProducts.where((product) {
        final skus = product['skus'] as List<dynamic>? ?? [];
        final attributes = product['attributes'] as Map<String, dynamic>? ?? {};

        final name = attributes['name']?.toLowerCase() ?? '';
        final description = attributes['description']?.toLowerCase() ?? '';

        return skus.any(
                (sku) => sku['ShopSku'].toLowerCase().contains(searchQuery)) ||
            name.contains(searchQuery) ||
            description.contains(searchQuery);
      }).toList();

      // Filter mapped products
      mappedProducts = mappedProducts.where((product) {
        final skus = product['skus'] as List<dynamic>? ?? [];
        final attributes = product['attributes'] as Map<String, dynamic>? ?? {};

        final name = attributes['name']?.toLowerCase() ?? '';
        final description = attributes['description']?.toLowerCase() ?? '';

        return skus.any(
                (sku) => sku['ShopSku'].toLowerCase().contains(searchQuery)) ||
            name.contains(searchQuery) ||
            description.contains(searchQuery);
      }).toList();
    });
  }

  Future<void> fetchSQLProducts() async {
    final products = await ApiService.fetchSQLProducts(Config.sqlProductsUrl);
    setState(() {
      sqlProducts = products;
    });
  }

  Future<void> fetchPlatformProducts() async {
    final products =
        await ApiService.fetchPlatformProducts(Config.platformProductsUrl);
    setState(() {
      platformProducts = products['unmapped_products'] ?? [];
      mappedProducts = products['mapped_products'] ?? [];
      filteredProducts = platformProducts;
    });
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
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company ID: 10002',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('SQL Inventory',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: fetchSQLProducts,
                            ),
                          ],
                        ),
                        SQLProductList(
                          products: sqlProducts,
                          onFetch: fetchSQLProducts,
                          selectedProduct: selectedSQLProduct,
                          onSelect: (product) => setState(() {
                            selectedSQLProduct = product;
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  VerticalDivider(),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Platform Products',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.animation_rounded),
                              onPressed: fetchPlatformProducts,
                            ),
                          ],
                        ),
                        PlatformProductList(
                          mappedProducts: mappedProducts,
                          unmappedProducts: filteredProducts,
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
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                            'status': sku.containsKey('status')
                          };
                        }).toList();

                        Map<String, dynamic> requestBody = {
                          'store_id': Config.storeId,
                          'products': products,
                        };

                        await ApiService.mapProducts(
                            Config.mapProductsUrl, requestBody);
                        print('Products mapped successfully');
                        await fetchPlatformProducts();
                      }
                    },
                    child: Text('Map'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MappedProductsPage(
                              storeId: int.parse(Config.storeId)),
                        ),
                      );
                    },
                    child: Text('View Mapped Products'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
