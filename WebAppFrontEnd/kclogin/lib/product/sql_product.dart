import 'package:flutter/material.dart';

class SQLProductList extends StatelessWidget {
  final List<dynamic> products;
  final Function onFetch;
  final dynamic selectedProduct;
  final Function(dynamic) onSelect;

  const SQLProductList({
    super.key,
    required this.products,
    required this.onFetch,
    required this.selectedProduct,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Text('SQL Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
          // ElevatedButton(
          //   onPressed: () => onFetch(),
          //   child: Text('Fetch SQL Products'),
          // ),
          Expanded(
            child: products.isEmpty
                ? Center(child: Text('No Data'))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () => onSelect(product),
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Radio<dynamic>(
                                  value: product,
                                  groupValue: selectedProduct,
                                  onChanged: (dynamic value) {
                                    onSelect(value);
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Stock Code: ${product['stock_code']}'),
                                      Text(
                                          'Description: ${product['description']}'),
                                      Text('Quantity: ${product['quantity']}'),
                                      Text(
                                          'Reserved Quantity: ${product['reserved_quantity']}'),
                                      Text('Weight: ${product['weight']} kg'),
                                      Text(
                                          'Ref. Cost (MYR): ${product['ref_cost'].toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
