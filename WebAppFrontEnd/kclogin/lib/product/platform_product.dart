import 'package:flutter/material.dart';

class PlatformProductList extends StatelessWidget {
  final List<dynamic> products;
  final Function onFetch;
  final Set<dynamic> selectedProducts;
  final Function(dynamic) onSelect;
  final Function(String) onSearch;

  const PlatformProductList({
    super.key,
    required this.products,
    required this.onFetch,
    required this.selectedProducts,
    required this.onSelect,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            'Platform Product',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () => onFetch(),
            child: Text('Fetch Platform Products'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) => onSearch(query),
              decoration: InputDecoration(
                labelText: 'SKU Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(child: Text('No Data'))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final skus = product['skus'] as List<dynamic>;
                      final attributes =
                          product['attributes'] as Map<String, dynamic>;

                      return Column(
                        children: skus.map<Widget>((sku) {
                          return GestureDetector(
                            onTap: () => onSelect(sku),
                            child: Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: selectedProducts.contains(sku),
                                      onChanged: (bool? value) {
                                        onSelect(sku);
                                      },
                                    ),
                                    if (sku['Images'].isNotEmpty)
                                      Image.network(
                                        sku['Images'][0],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.broken_image,
                                              size: 100);
                                        },
                                      )
                                    else if (product['images'] != null &&
                                        product['images'].isNotEmpty)
                                      Image.network(
                                        product['images'][0],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.broken_image,
                                              size: 100);
                                        },
                                      )
                                    else
                                      Icon(Icons.image_not_supported,
                                          size: 100),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('SKU: ${sku['ShopSku']}'),
                                          Text('Name: ${attributes['name']}'),
                                          Text(
                                              'Quantity: ${int.parse(sku['quantity'].toString())}'),
                                          Text('Status: ${sku['Status']}'),
                                          Text(
                                              'Price (MYR): ${sku['price'].toStringAsFixed(2)}'),
                                          Text(
                                              'Special Price (MYR): ${sku['special_price'].toStringAsFixed(2)}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
