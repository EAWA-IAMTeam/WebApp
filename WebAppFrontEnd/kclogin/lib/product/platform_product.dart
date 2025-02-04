import 'package:flutter/material.dart';

class PlatformProductList extends StatelessWidget {
  final List<dynamic> mappedProducts;
  final List<dynamic> unmappedProducts;
  final Function onFetch;
  final Set<dynamic> selectedProducts;
  final Function(dynamic) onSelect;
  final Function(String) onSearch;

  const PlatformProductList({
    super.key,
    required this.mappedProducts,
    required this.unmappedProducts,
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
            child: ListView(
              children: [
                _buildProductSection('Unmapped Products', unmappedProducts,
                    selectable: true),
                _buildProductSection('Mapped Products', mappedProducts,
                    selectable: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection(String title, List<dynamic> products,
      {bool selectable = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        products.isEmpty
            ? Center(child: Text('No Data'))
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final skus = product['skus'] as List<dynamic>;
                  final attributes =
                      product['attributes'] as Map<String, dynamic>;
                  final productImages = product['images'] ?? [];

                  return Column(
                    children: skus.map<Widget>((sku) {
                      return GestureDetector(
                        onTap: selectable ? () => onSelect(sku) : null,
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                if (selectable)
                                  Checkbox(
                                    value: selectedProducts.contains(sku),
                                    onChanged: selectable
                                        ? (bool? value) {
                                            onSelect(sku);
                                          }
                                        : null,
                                  ),
                                _buildProductImage(sku, productImages),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('SKU: ${sku['ShopSku']}'),
                                      Text('Name: ${attributes['name']}'),
                                      Text('Quantity: ${sku['quantity']}'),
                                      Text('Price (MYR): ${sku['price']}'),
                                      Text(
                                          'Special Price (MYR): ${sku['special_price']}'),
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
      ],
    );
  }

  Widget _buildProductImage(dynamic sku, List<dynamic> productImages) {
    final skuImages = sku['Images'] ?? [];

    if (skuImages.isNotEmpty) {
      return Image.network(
        skuImages[0],
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 100);
        },
      );
    } else if (productImages.isNotEmpty) {
      return Image.network(
        productImages[0],
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 100);
        },
      );
    } else {
      return Icon(Icons.image_not_supported, size: 100);
    }
  }
}
