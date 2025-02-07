import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kclogin/config.dart';

// Global variables
String kcid = '';
String kcsecret = '';
String? userId;
String storeRole = '';
String storeName = '';
String storePermission = '';
String storeId = '';

class UpdateUserPage extends StatefulWidget {
  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  List<Map<String, dynamic>> storeList = [];

  bool isUserFound = false;
  bool isEditingStore = false;

  @override
  void initState() {
    super.initState();
    fetchKeycloakConfig();
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

  Future<String?> _getClientAccessToken() async {
    final url = Uri.parse(
        '${Config.server}:8080/realms/G-SSO-Connect/protocol/openid-connect/token');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': kcid,
          'client_secret': kcsecret,
          'grant_type': 'client_credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      } else {
        print(
            'Failed to get access token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error obtaining access token: $e');
    }
    return null;
  }

  Future<void> _fetchUserByEmail() async {
    final token = await _getClientAccessToken();
    if (token == null) {
      print("Error: Token is null");
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      print("Error: Email field is empty");
      return;
    }

    final url = Uri.parse(
        "${Config.server}:8080/admin/realms/G-SSO-Connect/users?email=$email");
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        if (users.isEmpty) {
          print("No user found with email: $email");
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("User not found")));
          return;
        }

        final user = users.first;
        setState(() {
          userId = user['id'];
          isUserFound = true;
        });

        print("User ID Found: $userId");
        await _fetchUserData();
      } else {
        print("Error fetching user by email: ${response.body}");
      }
    } catch (e) {
      print("Exception while fetching user by email: $e");
    }
  }

  Future<void> _fetchUserData() async {
    if (userId == null) {
      print("Error: User ID is null");
      return;
    }

    final token = await _getClientAccessToken();
    if (token == null) {
      print("Error: Token is null");
      return;
    }

    final url = Uri.parse(
        "${Config.server}:8080/admin/realms/G-SSO-Connect/users/$userId");
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        print("User Data Retrieved: $userData");

        setState(() {
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _emailController.text = userData['email'] ?? '';

          if (userData['attributes'] != null &&
              userData['attributes']['store'] != null) {
            try {
              final decodedData =
                  jsonDecode(userData['attributes']['store'][0]);
              print("Decoded Store Data: $decodedData");

              List<dynamic> storeData =
                  jsonDecode(userData['attributes']['store'][0]);
              print(storeData);
              storeData.forEach((store) {
                print("Store: $store");
              });

              // Safely mapping each store object
              storeList = storeData.map((store) {
                String storeRole = store['store_role']?.toString() ??
                    ''; // Default to empty string if null
                String storeName = store['store_name']?.toString() ?? '';
                String storePermission =
                    store['store_permission']?.toString() ?? '';
                String storeId = store['store_id']?.toString() ?? '';

                return {
                  'storeRole': storeRole,
                  'storeName': storeName,
                  'storePermission': storePermission,
                  'storeId': storeId,
                };
              }).toList();

              print("Store List: $storeList");
            } catch (e) {
              print("Error parsing store data: $e");
              storeList = [];
              print("Parsed Store List: $storeList");
            }
          }
        });
      } else {
        print("Error fetching user data: ${response.body}");
      }
    } catch (e) {
      print("Exception while fetching user data: $e");
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (userId == null) {
      print("Error: User ID is null");
      return;
    }

    final token = await _getClientAccessToken();
    if (token == null) {
      print("Error: Token is null");
      return;
    }

    Map<String, dynamic> userData = {
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "username": _emailController.text,
      "email": _emailController.text,
      "attributes": {
        "store": jsonEncode(storeList),
      }
    };

    final url = Uri.parse(
        "${Config.server}:8080/admin/realms/G-SSO-Connect/users/$userId");
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User updated successfully!")));
      } else {
        print("Error updating user: ${response.body}");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      print("Exception while updating user: $e");
    }
  }

// Function to handle adding a new store
  Future<void> _addStore() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Store"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Store ID"),
                onChanged: (value) => storeId = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Store Name"),
                onChanged: (value) => storeName = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Store Role"),
                onChanged: (value) => storeRole = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Store Permissions"),
                onChanged: (value) => storePermission = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Mapping each value to a string to avoid dynamic types
                  Map<String, String> newStore = {
                    'storeId': storeId.toString(),
                    'storeName': storeName.toString(),
                    'storeRole': storeRole.toString(),
                    'storePermission': storePermission.toString(),
                  };

                  storeList.add(newStore); // Adding mapped values to storeList
                });
                print(storeList); // For debugging
                Navigator.of(context).pop();
              },
              child: Text("Add Permission"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editStorePermission(int index) async {
    final store = storeList[index];
    final updatedStore = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController storeIdController =
            TextEditingController(text: store['storeId']);
        final TextEditingController storeNameController =
            TextEditingController(text: store['storeName']);
        final TextEditingController storeRoleController =
            TextEditingController(text: store['storeRole']);
        final TextEditingController storePermissionController =
            TextEditingController(text: store['storePermission']);

        return AlertDialog(
          title: Text("Edit Store Permission"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: storeIdController,
                decoration: InputDecoration(labelText: "Store ID"),
              ),
              TextField(
                controller: storeNameController,
                decoration: InputDecoration(labelText: "Store Name"),
              ),
              TextField(
                controller: storeRoleController,
                decoration: InputDecoration(labelText: "Store Role"),
              ),
              TextField(
                controller: storePermissionController,
                decoration: InputDecoration(labelText: "Store Permission"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Map<String, String> newStore = {
                    'storeId': storeIdController.text,
                    'storeName': storeNameController.text,
                    'storeRole': storeRoleController.text,
                    'storePermission': storePermissionController.text,
                  };

                  storeList[index] = newStore;
                });
                Navigator.of(context).pop();
              },
              child: Text("Edit Permission"),
            ),
          ],
        );
      },
    );
    if (updatedStore != null) {
      setState(() {
        storeList[index] = updatedStore;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update User")),
      body: Padding(
        padding: EdgeInsets.fromLTRB(64, 32, 64, 32),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: "Email"),
                      readOnly: isUserFound,
                      validator: (value) =>
                          value!.isEmpty ? 'Email cannot be empty' : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: !isUserFound ? _fetchUserByEmail : null,
                    child: Text("Search User"),
                  ),
                ],
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: "First Name"),
                readOnly: !isUserFound,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: "Last Name"),
                readOnly: !isUserFound,
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Store Permissions',
                    style: TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed: isUserFound ? _addStore : null,
                    child: Text('Add Permission'),
                  ),
                ],
              ),
              SizedBox(height: 32),
              SizedBox(
                height: 480,
                child: SingleChildScrollView(
                  child: Column(
                    children: storeList.map((store) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(store['storeName'] ?? ''),
                          subtitle: Text('Role: ${store['storeRole'] ?? ''}\n'
                              'Permission: ${store['storePermission'] ?? ''}\n'
                              'Store ID: ${store['storeId'] ?? ''}'),
                          trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                print(storeList);
                                _editStorePermission(storeList.indexOf(store));
                              }),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: isUserFound
                    ? () {
                        _updateUser();
                        //Navigator.pop(context);
                      }
                    : null,
                child: Text('Update User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
