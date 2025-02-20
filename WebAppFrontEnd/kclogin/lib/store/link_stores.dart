import 'package:flutter/material.dart';
import 'package:kclogin/home/config.dart';
import 'package:kclogin/product/services.dart';
import 'stores.dart';
import 'package:kclogin/home/controllers/auth_controller.dart'; // Import new AuthController

class LinkStorePage extends StatefulWidget {
  final String keycloakAccessToken;
  final String keycloakRefreshToken;

  LinkStorePage({super.key, required this.keycloakAccessToken, required this.keycloakRefreshToken});

  @override
  _LinkStorePageState createState() => _LinkStorePageState();
}

class _LinkStorePageState extends State<LinkStorePage> {
  final AuthController _authController = AuthController(); // Use the new controller
  List<dynamic> storesList = [];
  Set<dynamic> selectedStores = {};
  List<dynamic> filteredStores = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStores();
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

  Future<void> _fetchStores() async {
    final response = await _authController.callApiWithToken(Config.storesUrl, widget.keycloakAccessToken, widget.keycloakRefreshToken);
    if (response != null && response.statusCode == 200) {
      fetchStores();
    }
  }

  Future<void> fetchStores() async {
    try {
      final stores = await ApiService.fetchStores(Config.storesUrl, widget.keycloakAccessToken);
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StoresList(
                stores: filteredStores,
                onFetch: _fetchStores,
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
