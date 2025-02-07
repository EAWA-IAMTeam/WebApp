import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kclogin/config.dart';

class CreateUserPage extends StatefulWidget {
  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  String kcid = '';
  String kcsecret = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Map<String, dynamic>> storeList = [];

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
    const keycloakTokenUrl =
        '${Config.server}:8080/realms/G-SSO-Connect/protocol/openid-connect/token';
    await fetchKeycloakConfig();
    try {
      final response = await http.post(
        Uri.parse(keycloakTokenUrl),
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

  void _addStore() {
    TextEditingController storeIdController = TextEditingController();
    TextEditingController storeNameController = TextEditingController();
    TextEditingController storeRoleController = TextEditingController();
    TextEditingController storePermissionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Store Permission"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: storeIdController,
                decoration: InputDecoration(labelText: "Store ID")),
            TextField(
                controller: storeNameController,
                decoration: InputDecoration(labelText: "Store Name")),
            TextField(
                controller: storeRoleController,
                decoration: InputDecoration(labelText: "Role")),
            TextField(
                controller: storePermissionController,
                decoration: InputDecoration(
                    labelText: "Permissions")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (storeIdController.text.isNotEmpty &&
                  storeNameController.text.isNotEmpty &&
                  storeRoleController.text.isNotEmpty &&
                  storePermissionController.text.isNotEmpty) {
                setState(() {
                  storeList.add({
                    "store_id": storeIdController.text,
                    "store_name": storeNameController.text,
                    "store_role": storeRoleController.text,
                    "store_permission": storePermissionController.text
                        // .split(",")
                        // .map((e) => e.trim())
                        // .toList(),
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate() || storeList.isEmpty) return;

    // Get the access token
    final token = await _getClientAccessToken();
    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: Token is null")));
      return;
    }

    // Prepare the user data
    // String firstName = _firstNameController.text.replaceAll(' ', '_');
    // String lastName = _lastNameController.text.replaceAll(' ', '_');
    // String username = "${lastName}_$firstName";

    Map<String, dynamic> userData = {
      "username": _emailController.text,
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "email": _emailController.text,
      "enabled": true, // Set enabled to true
      "attributes": {
        "store": jsonEncode(storeList),
      }
    };

    // Make the request to create the user
    final response = await http.post(
      Uri.parse("${Config.server}:8080/admin/realms/G-SSO-Connect/users"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Use Bearer token for authorization
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User created successfully!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid = _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        storeList.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text("Create User")),
      body: Padding(
        padding: EdgeInsets.fromLTRB(64, 32, 64, 32),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: "First Name"),
                      validator: (value) => value!.isEmpty ? "Required" : null),
                  TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: "Last Name"),
                      validator: (value) => value!.isEmpty ? "Required" : null),
                  TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: "Email"),
                      validator: (value) => value!.isEmpty ? "Required" : null),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text("Add Store Permission"),
            ElevatedButton(onPressed: _addStore, child: Text("Add Permission")),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: storeList.length,
                itemBuilder: (context, index) {
                  final store = storeList[index];
                  return ListTile(
                    title:
                        Text("${store['store_name']} - ${store['store_role']}"),
                    subtitle: Text(
                        "ID: ${store['store_id']} | Permissions: ${store['store_permission']}"),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isFormValid
                  ? () async {
                      await _createUser();
                      // Pop the context after user is created successfully
                      Navigator.pop(context);
                    }
                  : null,
              child: Text("Create User"),
            ),
          ],
        ),
      ),
    );
  }
}
