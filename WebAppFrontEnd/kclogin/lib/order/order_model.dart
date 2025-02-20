import 'dart:convert';

class OrderModel {
  final int orderId;
  final String platformOrderId;
  final int storeId;
  final int companyId;
  final DateTime shipmentDate;
  final DateTime orderDate;
  final String trackingId;
  final String orderStatus;
  final OrderData data;
  List<OrderItem> itemList;

  OrderModel({
    required this.orderId,
    required this.platformOrderId,
    required this.storeId,
    required this.companyId,
    required this.shipmentDate,
    required this.orderDate,
    required this.trackingId,
    required this.orderStatus,
    required this.data,
    required this.itemList,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'],
      platformOrderId: json['platform_order_id'].toString(),
      storeId: int.tryParse(json['store_id'].toString()) ?? 0,
      companyId: json['company_id'],
      shipmentDate: DateTime.parse(json['shipment_date']),
      orderDate: DateTime.parse(json['order_date']),
      trackingId: json['tracking_id'] ?? '',
      orderStatus: json['order_status'],
      data: OrderData.fromJson(json['data']),
      itemList: (json['item_list'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderData {
  final int orderId;
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
  final double totalAmount;
  final String currency;
  final double refundAmount;
  final String reasonText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> statuses;

  OrderData({
    required this.orderId,
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
    required this.totalAmount,
    required this.currency,
    required this.refundAmount,
    required this.reasonText,
    required this.createdAt,
    required this.updatedAt,
    required this.statuses,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      orderId: json['order_id'],
      customerName: json['CustomerName'] ?? '',
      customerPhone: json['CustomerPhone'] ?? '',
      customerAddress: json['CustomerAddress'] ?? '',
      courierService: json['CourierService'] ?? '',
      transactionFee: (json['TransactionFee'] as num).toDouble(),
      shippingFee: (json['ShippingFee'] as num).toDouble(),
      processFee: (json['ProcessFee'] as num).toDouble(),
      serviceFee: (json['service_fee'] as num).toDouble(),
      sellerDiscount: (json['seller_discount'] as num).toDouble(),
      platformDiscount: (json['platform_discount'] as num).toDouble(),
      shippingFeeDiscountSeller: (json['shipping_fee_discount_seller'] as num).toDouble(),
      totalAmount: double.tryParse(json['TotalAmount'].toString()) ?? 0.0,
      currency: json['currency'] ?? '',
      refundAmount: (json['refund_amount'] as num).toDouble(),
      reasonText: json['reason_text'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      statuses: List<String>.from(json['statuses'] ?? []),
    );
  }
}

class OrderItem {
  final int orderItemId;
  final String name;
  final String status;
  final double paidPrice;
  final double itemPrice;
  int quantity;
  final String sku;
  final String shopSku;
  final String trackingCode;
  final String shippingProviderType;
  final double shippingFeeOriginal;
  final double shippingFeeDiscountSeller;
  final double shippingAmount;
  final int orderId;
  final String returnStatus;
  final String reason;
  final String productMainImage;

  OrderItem({
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
    required this.reason,
    required this.productMainImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['order_item_id'],
      name: json['name'],
      status: json['status'],
      paidPrice: (json['paid_price'] as num).toDouble(),
      itemPrice: (json['item_price'] as num).toDouble(),
      quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) ?? 1 : 1,
      sku: json['sku'],
      shopSku: json['shop_sku'],
      trackingCode: json['tracking_code'] ?? '',
      shippingProviderType: json['shipping_provider_type'],
      shippingFeeOriginal: (json['shipping_fee_original'] as num).toDouble(),
      shippingFeeDiscountSeller: (json['shipping_fee_discount_seller'] as num).toDouble(),
      shippingAmount: (json['shipping_amount'] as num).toDouble(),
      orderId: json['order_id'],
      returnStatus: json['return_status'] ?? '',
      reason: json['reason'] ?? '',
      productMainImage: json['product_main_image'] ?? '',
    );
  }
}
