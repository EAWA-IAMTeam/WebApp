import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kclogin/config.dart';
import 'package:kclogin/product/services.dart';
import 'stores.dart';
import 'package:http/http.dart' as http;

import 'dart:html' as html;

class LinkStorePage extends StatefulWidget {
  final String keycloakAccessToken;
  final String keycloakRefreshToken;
  LinkStorePage({super.key, required this.keycloakAccessToken, required this.keycloakRefreshToken});

  @override
  _LinkStorePageState createState() => _LinkStorePageState();
}

class _LinkStorePageState extends State<LinkStorePage> {
  List<dynamic> storesList = [];
  Set<dynamic> selectedStores = {};
  List<dynamic> filteredStores = [];
  String searchQuery = '';
  String kcid = '';
  String kcsecret = '';

  @override
  void initState() {
    super.initState();
    _callApiWithToken();
    // fetchStores(); // Fetch stores on initialization
  }

  Future<void> fetchKeycloakConfig() async {
    final url = Uri.parse('${Config.server}:3002/keycloak-config');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          kcid = data['KCID'];
          kcsecret = data['KCSecret'];
        });
      } else {
        print('Failed to fetch Keycloak config: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Keycloak config: $e');
    }
  }

  // Function to refresh access token
  Future<String?> _refreshAccessToken() async {
    final refreshToken = widget.keycloakRefreshToken;
    if (refreshToken.isNotEmpty) {
      const url =
          '${Config.server}:8080/realms/G-SSO-Connect/protocol/openid-connect/token';
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'client_id': kcid,
            'client_secret': kcsecret,
            'grant_type': 'refresh_token',
            'refresh_token': refreshToken,
          },
        );

        if (response.statusCode == 200) {
          final responseBody = response.body;
          // Extract the new access token from the response
          final accessToken =
              responseBody; // Modify this to extract the access token from JSON
          return accessToken;
        } else {
          print('Failed to refresh token: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during token refresh: $e');
      }
    }
    return null;
  }

  // Function to call the API with the Keycloak access token
  Future<void> _callApiWithToken() async {

    String token = widget.keycloakAccessToken;
    if (token.isEmpty) {
      token = await _refreshAccessToken() ??
          ''; // Try refreshing the token if empty
    }

    if (token.isNotEmpty) {
      try {
        print('Using token: $token'); // Log token to ensure it's correct
        final response = await http.get(
          Uri.parse(
              'http://192.168.0.196:9080'), // http:/example.com:9080/lazada/fetch-products
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          print('API call successful');
          print("APISIX response body: ${response.body}");
          fetchStores();
        } else {
          print('API call failed with status: ${response.statusCode}');
          print(
              'Response body: ${response.body}'); // Log response body for further analysis
        }
      } catch (e) {
        print('Error during API call: $e');
      }
    } else {
      print('No valid access token available');
    }
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
              child: StoresList(
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
