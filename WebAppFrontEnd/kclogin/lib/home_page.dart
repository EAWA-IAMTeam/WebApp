import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:kclogin/config.dart';
import 'package:kclogin/login_page.dart';

class HomePage extends StatefulWidget {
  final String googleAccessToken;
  final String keycloakAccessToken;
  final String keycloakRefreshToken;
  final String email;

  const HomePage({
    Key? key,
    required this.googleAccessToken,
    required this.keycloakAccessToken,
    required this.keycloakRefreshToken,
    required this.email,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String kcid = '';
  String kcsecret = '';

  //  String? getCookie(String name) {
  //   final cookies = html.document.cookie?.split('; ') ?? [];
  //   for (final cookie in cookies) {
  //     if (cookie.startsWith(name)) {
  //       return cookie.substring(name.length + 1);
  //     }
  //   }
  //   return null;
  // }

  // void setCookie(String name, String value) {
  //   html.document.cookie = '$name=$value; path=/; expires=Fri, 31 Dec 9999 23:59:59 GMT';
  // }

  // void deleteCookie(String name) {
  //   html.document.cookie = '$name=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
  // }

// Future<void> setCookie(String name, String value) async {
//   final url = Uri.parse('http://localhost:3002/setCookie?name=$name&value=$value');
//   final response = await http.post(url);

//   if (response.statusCode == 200) {
//     print('Cookie set successfully');
//   } else {
//     print('Failed to set cookie');
//   }
// }

// Future<void> deleteCookie(String name) async {
//   final url = Uri.parse('http://localhost:3002/deleteCookie?name=$name');
//   final response = await http.delete(url);

//   if (response.statusCode == 200) {
//     print('Cookie deleted successfully');
//   } else {
//     print('Failed to delete cookie');
//   }
// }

// Future<String?> getCookie(String name) async {
//   final url = Uri.parse('http://localhost:3002/getCookie?name=$name');
//   final response = await http.get(url);

//   if (response.statusCode == 200) {
//     return response.body;
//   } else {
//     print('Failed to retrieve cookie');
//     return null;
//   }
// }

  Future<String?> getLocalStorage(String key) async {
    print('Name: ' + key);
    return html.window.localStorage[key];
  }

  Future<void> setLocalStorage(String key, String value) async {
    print('Local Storage set successfully: $key=$value');
    html.window.localStorage[key] = value;
  }

  Future<void> deleteLocalStorage(String name) async {
  try {
    html.window.localStorage.remove(name);
    print('Local storage item deleted successfully: $name');
  } catch (e) {
    print('Failed to delete local storage item: $e');
  }
}


  Future<void> _logout(BuildContext context) async {
    // Revoke Google Access Token by calling Google's revocation endpoint
    //final googleAccessToken = html.window.localStorage['googleAccessToken'];
    final googleAccessToken = await getLocalStorage('googleAccessToken');
    print("GAT: $googleAccessToken");
    if (googleAccessToken != null) {
      final revokeUrl =
          'https://oauth2.googleapis.com/revoke?token=$googleAccessToken';
      try {
        final response = await http.post(Uri.parse(revokeUrl));
        print(response.statusCode);
        if (response.statusCode == 200) {
          print("Google Access Token successfully revoked.");
        } else {
          print("Failed to revoke Google Access Token.");
        }
      } catch (e) {
        print("Error during Google token revocation: $e");
      }
    } else {
      print("Google Access Token already deleted.");
    }

    // Clear local storage
    // html.window.localStorage.remove('keycloakAccessToken');
    // html.window.localStorage.remove('keycloakRefreshToken');
    // html.window.localStorage.remove('googleAccessToken');
    // html.window.localStorage.remove('email');
    // html.window.localStorage['logoutBool'] = "true";

     // Clear cookies
    deleteLocalStorage('keycloakAccessToken');
    deleteLocalStorage('keycloakRefreshToken');
    deleteLocalStorage('googleAccessToken');
    deleteLocalStorage('email');
    await deleteLocalStorage('logoutBool');

    // Set logoutBool to true
    setLocalStorage('logoutBool', "true");

    // Clear cookies with domain "accounts.google.com"
    _clearGoogleCookies();

    print("Logout completed and cookies cleared.");

    const keycloakLogoutUrl =
        '${Config.server}:8080/realms/G-SSO-Connect/protocol/openid-connect/logout';

    // Perform Keycloak logout by calling Keycloak's logout endpoint
    try {
      final response = await http.post(
        Uri.parse(keycloakLogoutUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': kcid,
          'client_secret': kcsecret,
          'refresh_token':
              widget.keycloakRefreshToken, // Pass the refresh token here
        },
      );

      if (response.statusCode == 204) {
        // If logout is successful on Keycloak, redirect to the Login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // Handle logout failure
        print('Error logging out from Keycloak: ${response.statusCode}');
      }
    } catch (error) {
      // Handle the error (e.g., network issues)
      print('Error during Keycloak logout: $error');
    }
  }

// Function to clear cookies with domain "accounts.google.com"
  void _clearGoogleCookies() {
    final cookies = [
      "ACCOUNT_CHOOSER",
      "APISID",
      "HSID",
      "LSID",
      "LSOLH",
      "NID",
      "OTZ",
      "SAPISID",
      "SID",
      "SIDCC",
      "SMSV",
      "SSID",
      "__Host-1PLSID",
      "__Host-3PLSID",
      "__Host-GAPS",
      "__Secure-1PAPISID",
      "__Secure-1PSID",
      "__Secure-1PSIDCC",
      "__Secure-3PAPISID",
      "__Secure-3PSID",
      "__Secure-3PSIDCC",
    ];

    // Loop through each cookie name and clear it by setting it to expire in the past
    for (var cookie in cookies) {
      html.document.cookie =
          "$cookie=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; domain=accounts.google.com;";
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
              'http:/example.com:9080/headers'), // http:/example.com:9080/lazada/fetch-products
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          print('API call successful');
          print("APISIX response body: ${response.body}");
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
  
  @override
  void initState() {
    super.initState();
    fetchKeycloakConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.keycloakAccessToken.isNotEmpty
                  ? Column(
                      children: [
                        //Text('Email: ${widget.email}'),
                        //SizedBox(height: 10),
                        //Text(
                        //    'Keycloak Access Token: ${widget.keycloakAccessToken}'),
                        //SizedBox(height: 10),
                        // Text(
                        //     'Keycloak Refresh Token: ${widget.keycloakRefreshToken}'),
                        // const SizedBox(height: 20),

                        // First Row with Select Company, Create Company, and Join Company
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [ 
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                
                              },
                              child: const Text('Link Store'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                
                              },
                              child: const Text('Link Inventory'),
                            ),                        
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                _callApiWithToken();
                              },
                              child: const Text('Connect with APISIX'),
                            ),
                          ],
                        ),
                        // Second Row Logout
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => _logout(context),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text('Login failed. Please try again.'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
