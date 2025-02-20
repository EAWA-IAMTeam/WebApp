// login_controller.dart

import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kclogin/home/config.dart';
import 'package:kclogin/home/controllers/auth_controller.dart';
import 'package:kclogin/home/views/home_page.dart';

class LoginController {
  final authController = AuthController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );
  String logoutBool = "true";
  String googleId = '';
  String googleEmail = '';
  String googleUserName = '';
  String kcUserId = '';

  void initfunction(BuildContext context) async {
    await authController.fetchKeycloakConfig();
    await checkForKeycloakToken(context);
  }

  Future<String?> getLocalStorage(String key) async {
    print('Name: ' + key);
    return html.window.localStorage[key];
  }

  Future<void> setLocalStorage(String key, String value) async {
    print('Local Storage set successfully: $key=$value');
    html.window.localStorage[key] = value;
  }

  Future<void> navigateToHomePage(
      BuildContext context,
      String keycloakAccessToken,
      String? googleAccessToken,
      String? keycloakRefreshToken,
      String? email) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          keycloakAccessToken: keycloakAccessToken,
          googleAccessToken: googleAccessToken ?? '',
          keycloakRefreshToken: keycloakRefreshToken ?? '',
          email: email ?? '',
        ),
      ),
    );
  }

  Future<void> checkForKeycloakToken(BuildContext context) async {
    final keycloakAccessToken = await getLocalStorage('keycloakAccessToken');
    final keycloakRefreshToken = await getLocalStorage('keycloakRefreshToken');
    final googleAccessToken = await getLocalStorage('googleAccessToken');
    final keycloakEmail = await getLocalStorage('email');
    logoutBool = (await getLocalStorage('logoutBool')) ?? "true";
    final isTokenExpired =
        await authController.isTokenExpired(keycloakAccessToken.toString());

    if (logoutBool == "true") {
      print("Redirecting to Google sign-in due to logoutBool.");
      await handleSignIn(context);
    } else if (keycloakAccessToken != null &&
        keycloakEmail != null &&
        !isTokenExpired) {
      print("Redirecting to HomePage.");
      navigateToHomePage(context, keycloakAccessToken, googleAccessToken,
          keycloakRefreshToken, keycloakEmail);
    } else {
      print(
          "Keycloak token invalid or missing. Redirecting to Google sign-in.");
      await handleSignIn(context);
    }
  }

  Future<void> handleSignIn(BuildContext context) async {
    try {
      var googleAccessToken = await getGoogleAccessToken();
      print(googleAccessToken.toString());

      if (googleAccessToken != null) {
        await fetchGoogleUserData(googleAccessToken);
        final clientAccessToken = await authController.getClientAccessToken();
        if (clientAccessToken != null) {
          final userExists = await checkIfUserExistsInKeycloak(
              googleEmail, clientAccessToken);
          if (userExists) {
            final userLinked = await isUserLinkedToIdentityProvider(
                clientAccessToken, kcUserId);
            if (!userLinked) {
              await linkUserToGoogleIdentityProvider(
                  clientAccessToken, kcUserId, googleId, googleUserName);
            }

            var keycloakTokens =
                await exchangeGoogleTokenForKeycloakTokens(googleAccessToken);

            if (keycloakTokens != null &&
                keycloakTokens['access_token'] != null &&
                keycloakTokens['refresh_token'] != null &&
                keycloakTokens['email'] != null) {
              print('User exists in Keycloak. Redirecting to homepage.');

              setLocalStorage(
                  'keycloakAccessToken', keycloakTokens['access_token']);
              setLocalStorage(
                  'keycloakRefreshToken', keycloakTokens['refresh_token']);
              setLocalStorage('googleAccessToken', googleAccessToken);
              setLocalStorage('email', keycloakTokens['email']);
              setLocalStorage('logoutBool', "false");
              // Decode the token
              Map<String, dynamic> decodedToken =
                  JwtDecoder.decode(keycloakTokens['access_token']);

              // Access the claims
              String firstname = decodedToken['given_name'];
              String lastname = decodedToken['family_name'];
              sendUserToBackend(googleEmail, firstname, lastname);
              await passTokensBackToMainApp();
              await navigateToHomePage(
                  context,
                  keycloakTokens['access_token'],
                  googleAccessToken,
                  keycloakTokens['refresh_token'],
                  keycloakTokens['email']);
            }
          } else {
            print('User does not exist in Keycloak.');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "Please contact our support team for more information. +603-3341 6909")));
          }
        }
      }
    } catch (error) {
      print('Error during sign-in: $error');
    }
  }

  Future<String?> getGoogleAccessToken() async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        GoogleSignInAuthentication auth = await account.authentication;
        return auth.accessToken;
      } else {
        return null;
      }
    } catch (error) {
      print('Error during Google sign-in: $error');
      return null;
    }
  }

  Future<void> fetchGoogleUserData(String accessToken) async {
    final response = await http.get(
      Uri.parse("https://www.googleapis.com/oauth2/v3/userinfo"),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      // Decode the JSON response
      final Map<String, dynamic> userData = json.decode(response.body);

      // Directly assign variables
      googleId = userData['sub'];
      googleEmail = userData['email'];
      googleUserName = userData['name'];

      // Print the values
      print("Google ID: $googleId");
      print("Email: $googleEmail");
      print("Username: $googleUserName");
    } else {
      print("Failed to fetch user info: ${response.body}");
    }
  }

  Future<bool> checkIfUserExistsInKeycloak(
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

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);

      if (users.isNotEmpty) {
        kcUserId = users.first['id']; // ✅ Set the global variable
        return true;
      }
    }

    return false;
  }

  Future<bool> isUserLinkedToIdentityProvider(
      String keycloakAdminToken, String keycloakUserId) async {
    const String realm = "G-SSO-Connect";

    final String url =
        "${Config.server}:8080/admin/realms/$realm/users/$keycloakUserId/federated-identity";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $keycloakAdminToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> identities = json.decode(response.body);

        return identities.isNotEmpty; // ✅ Returns true if linked, false if not
      } else {
        throw Exception(
            "Failed to fetch federated identities: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (error) {
      throw Exception("Error checking identity provider linkage: $error");
    }
  }

  Future<void> linkUserToGoogleIdentityProvider(String keycloakAdminToken,
      String keycloakUserId, String googleUserId, String googleUserName) async {
    final String url =
        "${Config.server}:8080/admin/realms/G-SSO-Connect/users/$keycloakUserId/federated-identity/google";

    final Map<String, dynamic> requestBody = {
      "identityProvider": "google",
      "userId": googleUserId,
      "userName": googleUserName
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $keycloakAdminToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 204) {
        print("✅ User successfully linked to Google.");
      } else {
        print(
            "❌ Failed to link user to Google: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      print("🚨 Error linking user to Google: $error");
    }
  }

  Future<void> passTokensBackToMainApp() async {
    final keycloakAccessToken = await getLocalStorage('keycloakAccessToken');
    final keycloakEmail = await getLocalStorage('email');

    // Sending tokens back to port 3000 (main app) via window messaging
    html.window.postMessage({
      'keycloakAccessToken': keycloakAccessToken,
      'email': keycloakEmail,
    }, '*');
  }

  void sendUserToBackend(
      String email, String firstName, String lastName) async {
    // Prepare the user data to send to the backend
    Map<String, String> userInfo = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    };

    // Print the data to verify it's correct
    print('Sending user info: $userInfo');

    // Send the user data to the backend
    final response = await http.post(
      Uri.parse("${Config.server}:3002/user"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userInfo),
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      print("User info successfully sent!");
    } else {
      print("Error sending user info: ${response.body}");
    }
  }

  Future<Map<String, dynamic>?> exchangeGoogleTokenForKeycloakTokens(
      String googleAccessToken) async {
    const String keycloakUrl =
        '${Config.server}:8080/realms/G-SSO-Connect/protocol/openid-connect/token';

    final response = await http.post(
      Uri.parse(keycloakUrl),
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',
        'subject_token_type': 'urn:ietf:params:oauth:token-type:access_token',
        'subject_token': googleAccessToken,
        'client_id': authController.kcid,
        'client_secret': authController.kcsecret,
        'subject_issuer': 'google',
      },
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      data['email'] = googleEmail;
      return data;
    } else {
      print('Failed to exchange token with Keycloak');
      return null;
    }
  }
}
