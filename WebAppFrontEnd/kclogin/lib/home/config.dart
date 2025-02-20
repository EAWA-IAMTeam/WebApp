class Config {
static const String server = "http://192.168.11.12";
static const String serverhost = "http://192.168.11.12";
//static const String server = "http://192.168.11.12";
//static const String server = "http://localhost";
//static const String server = "http://127.0.0.1";
//static const String server = "http://example.com";
//http://example.com:8080/realms/G-SSO-Connect/protocol/openid-connect/token
  static const int storeId = 2;
  static String get sqlProductsUrl =>
      '$serverhost:9080/products/company/$storeId'; //port 8100, remove authorization header, no need authorization
  static const String platformProductsUrl =
      '$serverhost:8100/lazada/$storeId';
  static const String mapProductsUrl = '$serverhost:9080/products';
  static const String currency = 'MYR';
  static const String apiBaseUrl = '$serverhost:9080';
  static const String storesUrl = '$serverhost:9080/stores';
  //static const String orderUrl = '$serverhost:9080/orders';
  static const String orderUrl = 'http://192.168.0.189:9080/company/$storeId/topic/order';
}
