import 'dart:convert';

class OrderModel {
  final String platformOrderId;
  final int storeId;
  final DateTime shipmentDate;
  final DateTime orderDate;
  final String trackingId;
  final String status;
  final SQLData data;
  final List<Item> itemList;
  final Map<String, dynamic> log;

  OrderModel({
    required this.platformOrderId,
    required this.storeId,
    required this.shipmentDate,
    required this.orderDate,
    required this.trackingId,
    required this.status,
    required this.data,
    required this.itemList,
    required this.log,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      platformOrderId: json['platform_order_id'],
      storeId: json['store_id'],
      shipmentDate: DateTime.parse(json['shipment_date']),
      orderDate: DateTime.parse(json['order_date']),
      trackingId: json['tracking_id'],
      status: json['status'],
      data: SQLData.fromJson(json['data']),
      itemList: (json['item_list'] as List).map((i) => Item.fromJson(i)).toList(),
      log: jsonDecode(json['log']),
    );
  }
}

class SQLData {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String courierService;
  final double transactionFee;
  final double shippingFee;
  final double processFee;
  final double serviceFee;
  final double sellerDiscount;
  final double platformDiscount;
  final double shippingFeeDiscountSeller;
  final String totalPrice;
  final String currency;
  final int refundAmount;
  final String refundReason;
  final String createdAt;
  final String systemUpdateTime;

  SQLData({
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.courierService,
    required this.transactionFee,
    required this.shippingFee,
    required this.processFee,
    required this.serviceFee,
    required this.sellerDiscount,
    required this.platformDiscount,
    required this.shippingFeeDiscountSeller,
    required this.totalPrice,
    required this.currency,
    required this.refundAmount,
    required this.refundReason,
    required this.createdAt,
    required this.systemUpdateTime,
  });

  factory SQLData.fromJson(Map<String, dynamic> json) {
    return SQLData(
      customerName: json['first_name'],
      customerPhone: json['phone'],
      customerAddress: json['address1'],
      courierService: json['CourierService'],
      transactionFee: (json['transaction_fee'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num).toDouble(),
      processFee: (json['process_fee'] as num).toDouble(),
      serviceFee: (json['service_fee'] as num).toDouble(),
      sellerDiscount: (json['seller_discount'] as num).toDouble(),
      platformDiscount: (json['platform_discount'] as num).toDouble(),
      shippingFeeDiscountSeller: (json['shipping_fee_discount_seller'] as num).toDouble(),
      totalPrice: json['price'],
      currency: json['currency'],
      refundAmount: json['refund_amount'],
      refundReason: json['reason_text'],
      createdAt: json['created_at'],
      systemUpdateTime: json['updated_at'],
    );
  }
}

class Item {
  final int orderItemId;
  final String name;
  final String status;
  final double paidPrice;
  final double itemPrice;
  final int quantity;
  final String sku;
  final String shopSku;
  final String trackingCode;
  final String shippingProviderType;
  final double shippingFeeOriginal;
  final double shippingFeeDiscountSeller;
  final double shippingAmount;
  final int orderId;
  final String returnStatus;
  final String returnReason;
  final String imageUrl;

  Item({
    required this.orderItemId,
    required this.name,
    required this.status,
    required this.paidPrice,
    required this.itemPrice,
    required this.quantity,
    required this.sku,
    required this.shopSku,
    required this.trackingCode,
    required this.shippingProviderType,
    required this.shippingFeeOriginal,
    required this.shippingFeeDiscountSeller,
    required this.shippingAmount,
    required this.orderId,
    required this.returnStatus,
    required this.returnReason,
    required this.imageUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      orderItemId: json['order_item_id'],
      name: json['name'],
      status: json['status'],
      paidPrice: (json['paid_price'] as num).toDouble(),
      itemPrice: (json['item_price'] as num).toDouble(),
      quantity: json['quantity'],
      sku: json['sku'],
      shopSku: json['shop_sku'],
      trackingCode: json['tracking_code'],
      shippingProviderType: json['shipping_provider_type'],
      shippingFeeOriginal: (json['shipping_fee_original'] as num).toDouble(),
      shippingFeeDiscountSeller: (json['shipping_fee_discount_seller'] as num).toDouble(),
      shippingAmount: (json['shipping_amount'] as num).toDouble(),
      orderId: json['order_id'],
      returnStatus: json['return_status'],
      returnReason: json['reason'],
      imageUrl: json['product_main_image'],
    );
  }
}
