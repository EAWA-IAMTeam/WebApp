class Config {
static const String server = "http://192.168.0.230";
//static const String server = "http://localhost";
//static const String server = "http://127.0.0.1";
//static const String server = "http://example.com";
//http://example.com:8080/realms/G-SSO-Connect/protocol/openid-connect/token

  static const int storeId = 2;
  static String get sqlProductsUrl =>
      'http://192.168.0.73:5000/api/stock_items/company/$storeId';
  static const String platformProductsUrl =
      'http://192.168.0.240:7000/products';
  static const String mapProductsUrl = 'http://192.168.0.73:5000/api/products';
  static const String currency = 'MYR';

  static const String storesUrl = 'http://192.168.0.196:8100/stores';
}