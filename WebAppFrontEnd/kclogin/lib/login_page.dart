import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kclogin/config.dart';
import 'package:kclogin/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String kcid = '';
  String kcsecret = '';
  String logoutBool = "true";

  @override
  void initState() {
    super.initState();
    fetchKeycloakConfig();
  }

  Future<void> fetchKeycloakConfig() async {
    final url = Uri.parse('http://localhost:3002/keycloak-config');

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

  bool isTokenExpired(String token) {
    List<String> parts = token.split('.');
    if (parts.length == 3) {
      String payload = parts[1];
      String decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
      Map<String, dynamic> decodedMap = json.decode(decoded);
      int exp = decodedMap['exp'];
      DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    }
    return true;
  }

  Future<String?> getCookie(String name) async {
    final url = Uri.parse('http://localhost:3002/getCookie?name=$name');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print('Failed to retrieve cookie');
      return null;
    }
  }

  Future<void> setCookie(String name, String value) async {
    final url = Uri.parse('http://localhost:3002/setCookie?name=$name&value=$value');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Cookie set successfully: $name=$value');
    } else {
      print('Failed to set cookie');
    }
  }

  Future<void> _checkForKeycloakToken() async {
    final keycloakAccessToken = await getCookie('keycloakAccessToken');
    final keycloakRefreshToken = await getCookie('keycloakRefreshToken');
    final googleAccessToken = await getCookie('googleAccessToken');
    final keycloakEmail = await getCookie('email');
    logoutBool = (await getCookie('logoutBool')) ?? "true";

    if (logoutBool == "true") {
      print("Redirecting to Google sign-in due to logoutBool.");
      await handleSignIn();
    } else if (keycloakAccessToken != null &&
        keycloakEmail != null &&
        !isTokenExpired(keycloakAccessToken)) {
      print("Redirecting to HomePage.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            keycloakAccessToken: keycloakAccessToken,
            googleAccessToken: googleAccessToken ?? '',
            keycloakRefreshToken: keycloakRefreshToken ?? '',
            email: keycloakEmail,
          ),
        ),
      );
    } else {
      print("Keycloak token invalid or missing. Redirecting to Google sign-in.");
      await handleSignIn();
    }
  }

  Future<void> handleSignIn() async {
    try {
      var googleAccessToken = await _getGoogleAccessToken();
      print(googleAccessToken.toString());

      if (googleAccessToken != null) {
        var keycloakTokens = await _exchangeGoogleTokenForKeycloakTokens(googleAccessToken);

        if (keycloakTokens != null &&
            keycloakTokens['access_token'] != null &&
            keycloakTokens['refresh_token'] != null &&
            keycloakTokens['email'] != null) {
          final clientAccessToken = await _getClientAccessToken();

          if (clientAccessToken != null) {
            final userExists = await _checkIfUserExistsInKeycloak(
              keycloakTokens['email'],
              clientAccessToken,
            );

            if (userExists) {
              print('User exists in Keycloak. Redirecting to homepage.');
              setCookie('keycloakAccessToken', keycloakTokens['access_token']);
              setCookie('keycloakRefreshToken', keycloakTokens['refresh_token']);
              setCookie('googleAccessToken', googleAccessToken);
              setCookie('email', keycloakTokens['email']);
              setCookie('logoutBool', "false");
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    googleAccessToken: googleAccessToken,
                    keycloakAccessToken: keycloakTokens['access_token'],
                    keycloakRefreshToken: keycloakTokens['refresh_token'],
                    email: keycloakTokens['email'],
                  ),
                ),
              );
            } else {
              print('User does not exist in Keycloak. Adding user.');
              await _addUserToKeycloak(keycloakTokens, clientAccessToken);
            }
          }
        }
      }
    } catch (error) {
      print('Error during sign-in: $error');
    }
  }

  Future<String?> _getGoogleAccessToken() async {
    html.window.open(
      'https://accounts.google.com/o/oauth2/v2/auth?'
      'client_id=950385657379-k0kk7l3nvdm8cbgp31fjvet0c5neluc7.apps.googleusercontent.com&'
      'redirect_uri=${Config.server}:3001/callback.html&'
      'response_type=token&'
      'scope=email profile openid',
      'google_sign_in_popup',
      'width=500,height=600',
    );

    return await _waitForGoogleToken();
  }

  Future<String?> _waitForGoogleToken() async {
    return await html.window.onMessage.firstWhere((event) {
      if (event.data != null && event.data['googleAccessToken'] != null) {
        return true;
      }
      return false;
    }).then((event) => event.data['googleAccessToken']);
  }

  Future<Map<String, dynamic>?> _exchangeGoogleTokenForKeycloakTokens(
      String googleAccessToken) async {
    const String keycloakUrl =
        '${Config.server}:8080/realms/G-SSO-Connect/protocol/openid-connect/token';

    final response = await http.post(
      Uri.parse(keycloakUrl),
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',
        'subject_token_type': 'urn:ietf:params:oauth:token-type:access_token',
        'subject_token': googleAccessToken,
        'client_id': kcid,
        'client_secret': kcsecret,
        'subject_issuer': 'google',
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      data['email'] = await _getUserEmail(data['access_token']);
      setCookie('logoutBool', "false");
      return data;
    } else {
      print(response.statusCode);
      print('Failed to exchange token with Keycloak');
      print(response.body);
      return null;
    }
  }

  Future<String?> _getUserEmail(String keycloakAccessToken) async {
    List<String> parts = keycloakAccessToken.split('.');
    if (parts.length == 3) {
      String payload = parts[1];
      String decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
      Map<String, dynamic> decodedMap = json.decode(decoded);
      return decodedMap['email'];
    }
    return null;
  }

  Future<String?> _getClientAccessToken() async {
    const keycloakTokenUrl =
        '${Config.server}:8080/realms/G-SSO-Connect/protocol/openid-connect/token';

    try {
      final response = await http.post(
        Uri.parse(keycloakTokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
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

  Future<bool> _checkIfUserExistsInKeycloak(
      String email, String clientAccessToken) async {
    const String keycloakUserUrl =
        '${Config.server}:8080/admin/realms/G-SSO-Connect/users?email=';
    final response = await http.get(
      Uri.parse('$keycloakUserUrl$email'),
      headers: {
        'Authorization': 'Bearer $clientAccessToken',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200 && json.decode(response.body).isNotEmpty;
  }

  Future<void> _addUserToKeycloak(
      Map<String, dynamic> keycloakTokens, String clientAccessToken) async {
    final String keycloakUserUrl =
        '${Config.server}:8080/admin/realms/G-SSO-Connect/users';
    final response = await http.post(
      Uri.parse(keycloakUserUrl),
      headers: {
        'Authorization': 'Bearer $clientAccessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': keycloakTokens['email'],
        'username': keycloakTokens['email'],
        'enabled': true,
        'firstName': 'test',
        'lastName': 'test',
      }),
    );

    if (response.statusCode == 201) {
      print('User added successfully to Keycloak');
    } else {
      print('Failed to add user');
      print(response.statusCode);
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keycloak Sign In'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _checkForKeycloakToken();
          },
          child: const Text('Sign In with Google'),
        ),
      ),
    );
  }
}
