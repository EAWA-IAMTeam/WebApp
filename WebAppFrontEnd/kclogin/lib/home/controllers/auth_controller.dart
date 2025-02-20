import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kclogin/home/config.dart';

class AuthController {
 // Step 1: Create a static instance of AuthController
  static final AuthController _instance = AuthController._internal();

  // Step 2: Provide a factory constructor that returns the same instance
  factory AuthController() {
    return _instance;
  }

  // Step 3: Private constructor (prevents external instantiation)
  AuthController._internal();

  // Variables to store Keycloak credentials
  String kcid = '';
  String kcsecret = '';

  // Step 4: Fetch Keycloak Config (only one instance holds these values)
  // Fetch Keycloak configuration (client ID and secret)
  Future<void> fetchKeycloakConfig() async {
    final url = Uri.parse('${Config.server}:3002/keycloak-config');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        kcid = data['KCID'];
        kcsecret = data['KCSecret'];
        print("Fetched KCID: $kcid, KCSecret: $kcsecret");
      } else {
        print('Failed to fetch Keycloak config: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Keycloak config: $e');
    }
  }

   // Function to get keycloak client access token
  Future<String?> getClientAccessToken() async {
    await fetchKeycloakConfig(); // Ensure credentials are loaded

    const keycloakTokenUrl =
        '${Config.server}:8080/realms/G-SSO-Connect/protocol/openid-connect/token';

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
        print('Failed to get access token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error obtaining access token: $e');
    }
    return null;
  }

  // Function to refresh the access token
  Future<String?> refreshAccessToken(String refreshToken) async {
    await fetchKeycloakConfig();
    print("Refreshing Token...");

    if (refreshToken.isNotEmpty) {
      final url = '${Config.server}:8080/realms/G-SSO-Connect/protocol/openid-connect/token';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: utf8.encode(
            'client_id=$kcid'
            '&client_secret=$kcsecret'
            '&grant_type=refresh_token'
            '&refresh_token=$refreshToken',
          ),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final accessToken = responseBody['access_token'];
          print("New Access Token: $accessToken");
          return accessToken;
        } else {
          print('Failed to refresh token: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error during token refresh: $e');
      }
    }
    return null;
  }

  // Function to check if the token is expired
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

  // Function to call API with a token
  Future<http.Response?> callApiWithToken(String url, String accessToken, String refreshToken) async {
    String? token = accessToken;
    if (isTokenExpired(token)) {
      String? refreshedToken = await refreshAccessToken(refreshToken);
      if (refreshedToken != null && refreshedToken.isNotEmpty) {
        token = refreshedToken;
      }
    }

    try {
      print('Using token: $token');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('API call successful');
        return response;
      } else {
        print('API call failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error during API call: $e');
    }
    return null;
  }
}
