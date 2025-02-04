import 'package:flutter/material.dart';
import 'package:kclogin/config.dart';
import 'package:kclogin/product/services.dart';
import 'stores.dart';

import 'dart:html' as html;

class LinkStorePage extends StatefulWidget {
  const LinkStorePage({super.key});

  @override
  _LinkStorePageState createState() => _LinkStorePageState();
}

class _LinkStorePageState extends State<LinkStorePage> {
  List<dynamic> storesList = [];
  Set<dynamic> selectedStores = {};
  List<dynamic> filteredStores = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStores(); // Fetch stores on initialization
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredStores = storesList.where((store) {
        return store['id'].toString().contains(searchQuery) ||
               store['name'].toLowerCase().contains(searchQuery) ||
               store['platform'].toLowerCase().contains(searchQuery) ||
               store['region'].toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> fetchStores() async {
    try {
      final stores = await ApiService.fetchStores(Config.storesUrl);
      setState(() {
        storesList = stores;
        filteredStores = storesList;
      });
    } catch (e) {
      print('Failed to fetch data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Stores'),
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
            Expanded(
              child: 
                  StoresList(
                    stores: filteredStores,
                    onFetch: fetchStores,
                    selectedStores: selectedStores,
                    onSelect: (storeId) => setState(() {
                      if (selectedStores.contains(storeId)) {
                        selectedStores.remove(storeId);
                      } else {
                        selectedStores.add(storeId);
                      }
                    }),
                    onSearch: updateSearchQuery,
                  ),
               
            ),
          ],
        ),
      ),
    );
  }
}
