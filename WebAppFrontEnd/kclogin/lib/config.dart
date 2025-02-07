class Config {
static const String server = "http://192.168.0.230";
//static const String server = "http://192.168.11.12";
//static const String server = "http://localhost";
//static const String server = "http://127.0.0.1";
//static const String server = "http://example.com";
//http://example.com:8080/realms/G-SSO-Connect/protocol/openid-connect/token
  static const int storeId = 7;
  static String get sqlProductsUrl =>
      'http://192.168.0.196:9080/products/company/$storeId'; //port 8100, remove authorization header, no need authorization
  static const String platformProductsUrl =
      'http://192.168.0.196:8100/lazada/$storeId';
  static const String mapProductsUrl = 'http://192.168.0.196:9080/products';
  static const String currency = 'MYR';
  static const String apiBaseUrl = 'http://192.168.0.196:9080';
  static const String storesUrl = 'http://192.168.0.196:8100/stores';
}
