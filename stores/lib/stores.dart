import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StoresList extends StatelessWidget {
  final List<dynamic> stores;
  final Function onFetch;
  final Set<dynamic> selectedStores;
  final Function(dynamic) onSelect;
  final Function(String) onSearch;

  const StoresList({
    super.key,
    required this.stores,
    required this.onFetch,
    required this.selectedStores,
    required this.onSelect,
    required this.onSearch,
  });

  String formatDateTime(String dateTime) {
    final DateTime parsedDate = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd kk:mm').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => onFetch(),
          child: Text('Refresh'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (query) => onSearch(query),
            decoration: InputDecoration(
              labelText: 'Search store',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: stores.isEmpty
              ? Center(child: Text('No Data'))
              : ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return GestureDetector(
                      onTap: () => onSelect(store),
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Store ID: ${store['id']}'),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Name: ${store['name']}'),
                                        Text('Platform: ${store['platform']}'),
                                        Text('Region: ${store['region']}'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Authorized Time: ${formatDateTime(store['authorize_time'])}'),
                                        Text('Expiry Time: ${formatDateTime(store['expiry_time'])}'),
                                        Text('Last Synced: ${formatDateTime(store['last_synced'])}'),
                                      ],
                                    ),
                                  ),
                                ],
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
    );
  }
}
