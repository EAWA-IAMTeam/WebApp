import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kclogin/home/config.dart';
import 'package:kclogin/home/controllers/auth_controller.dart';
import 'package:kclogin/home/controllers/login_controller.dart';
import 'package:kclogin/home/views/login_page.dart';
import 'package:url_launcher/url_launcher.dart';


class HomeController {
  final authController = AuthController();
  final LoginController _loginController = LoginController();

  Future<void> deleteLocalStorage(String name) async {
    try {
      html.window.localStorage.remove(name);
      print('Local storage item deleted successfully: $name');
    } catch (e) {
      print('Failed to delete local storage item: $e');
    }
  }

  Future<void> logout(BuildContext context, String keycloakRefreshToken) async {
    // Revoke Google Access Token by calling Google's revocation endpoint
    //final googleAccessToken = html.window.localStorage['googleAccessToken'];
    final googleAccessToken = await _loginController.getLocalStorage('googleAccessToken');
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

    // Clear cookies
    deleteLocalStorage('keycloakAccessToken');
    deleteLocalStorage('keycloakRefreshToken');
    deleteLocalStorage('googleAccessToken');
    deleteLocalStorage('email');
    await deleteLocalStorage('logoutBool');

    // Set logoutBool to true
    _loginController.setLocalStorage('logoutBool', "true");

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
          'client_id': authController.kcid,
          'client_secret': authController.kcsecret,
          'refresh_token': keycloakRefreshToken, // Pass the refresh token here
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

  //  void _launchURL() async {
  //   const url = 'http://localhost:3003'; // URL to redirect to
  //   final Uri uri = Uri.parse(url); // Convert the string URL to a Uri object
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  }