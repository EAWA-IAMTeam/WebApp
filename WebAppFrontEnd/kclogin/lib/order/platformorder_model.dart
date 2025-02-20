import 'dart:convert';
// Refresh from platform will get this but refresh from database will have empty value for some columns
// Using the order_model will get everyting needed for display but not the latest ones
// The latest values will be from the Refresh from platform but, backend will pull the latest and save to the database
// What we will need to do is just to get from database
class OrderModel {
  final String platformOrderId;
  final int storeId;
  final DateTime shipmentDate;
  final DateTime orderDate;
  final String trackingId;
  final String status;
  final OrdersData data;
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
      data: OrdersData.fromJson(json['data']),
      itemList: (json['item_list'] as List).map((i) => Item.fromJson(i)).toList(),
      log: jsonDecode(json['log']),
    );
  }
}

class OrdersData {
  final List<Order> orders;

  OrdersData({required this.orders});

  factory OrdersData.fromJson(Map<String, dynamic> json) {
    return OrdersData(
      orders: (json['orders'] as List).map((o) => Order.fromJson(o)).toList(),
    );
  }
}

class Order {
  final int orderNumber;
  final String createdAt;
  final String updatedAt;
  final String price;
  final String paymentMethod;
  final List<String> statuses;
  final int orderId;
  final double voucherPlatform;
  final double voucher;
  final String warehouseCode;
  final double voucherSeller;
  final String voucherCode;
  final bool giftOption;
  final double shippingFeeDiscountPlatform;
  final String customerLastName;
  final String promisedShippingTimes;
  final String nationalRegistrationNumber;
  final double shippingFeeOriginal;
  final String buyerNote;
  final String customerFirstName;
  final double shippingFeeDiscountSeller;
  final double shippingFee;
  final String branchNumber;
  final String taxCode;
  final int itemsCount;
  final String deliveryInfo;
  final String extraAttributes;
  final String remarks;
  final String giftMessage;
  final Address addressShipping;
  final List<Item> items;
  final List<ReturnRefund> refundStatus;

  Order({
    required this.orderNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    required this.paymentMethod,
    required this.statuses,
    required this.orderId,
    required this.voucherPlatform,
    required this.voucher,
    required this.warehouseCode,
    required this.voucherSeller,
    required this.voucherCode,
    required this.giftOption,
    required this.shippingFeeDiscountPlatform,
    required this.customerLastName,
    required this.promisedShippingTimes,
    required this.nationalRegistrationNumber,
    required this.shippingFeeOriginal,
    required this.buyerNote,
    required this.customerFirstName,
    required this.shippingFeeDiscountSeller,
    required this.shippingFee,
    required this.branchNumber,
    required this.taxCode,
    required this.itemsCount,
    required this.deliveryInfo,
    required this.extraAttributes,
    required this.remarks,
    required this.giftMessage,
    required this.addressShipping,
    required this.items,
    required this.refundStatus,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderNumber: json['order_number'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      price: json['price'],
      paymentMethod: json['payment_method'],
      statuses: List<String>.from(json['statuses']),
      orderId: json['order_id'],
      voucherPlatform: json['voucher_platform'].toDouble(),
      voucher: json['voucher'].toDouble(),
      warehouseCode: json['warehouse_code'],
      voucherSeller: json['voucher_seller'].toDouble(),
      voucherCode: json['voucher_code'],
      giftOption: json['gift_option'],
      shippingFeeDiscountPlatform: json['shipping_fee_discount_platform'].toDouble(),
      customerLastName: json['customer_last_name'],
      promisedShippingTimes: json['promised_shipping_times'],
      nationalRegistrationNumber: json['national_registration_number'],
      shippingFeeOriginal: json['shipping_fee_original'].toDouble(),
      buyerNote: json['buyer_note'],
      customerFirstName: json['customer_first_name'],
      shippingFeeDiscountSeller: json['shipping_fee_discount_seller'].toDouble(),
      shippingFee: json['shipping_fee'].toDouble(),
      branchNumber: json['branch_number'],
      taxCode: json['tax_code'],
      itemsCount: json['items_count'],
      deliveryInfo: json['delivery_info'],
      extraAttributes: json['extra_attributes'],
      remarks: json['remarks'],
      giftMessage: json['gift_message'],
      addressShipping: Address.fromJson(json['address_shipping']),
      items: (json['items'] as List).map((i) => Item.fromJson(i)).toList(),
      refundStatus: (json['refund_status'] as List).map((r) => ReturnRefund.fromJson(r)).toList(),
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
      paidPrice: json['paid_price'].toDouble(),
      itemPrice: json['item_price'].toDouble(),
      quantity: json['quantity'],
      sku: json['sku'],
      shopSku: json['shop_sku'],
      trackingCode: json['tracking_code'],
      shippingProviderType: json['shipping_provider_type'],
      shippingFeeOriginal: json['shipping_fee_original'].toDouble(),
      shippingFeeDiscountSeller: json['shipping_fee_discount_seller'].toDouble(),
      shippingAmount: json['shipping_amount'].toDouble(),
      orderId: json['order_id'],
      returnStatus: json['return_status'],
      returnReason: json['reason'],
      imageUrl: json['product_main_image'],
    );
  }
}

class Address {
  final String country;
  final String city;
  final String address1;
  final String postCode;
  final String firstName;
  final String phone;

  Address({
    required this.country,
    required this.city,
    required this.address1,
    required this.postCode,
    required this.firstName,
    required this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      country: json['country'],
      city: json['city'],
      address1: json['address1'],
      postCode: json['post_code'],
      firstName: json['first_name'],
      phone: json['phone'],
    );
  }
}

class ReturnRefund {
  final String status;
  final String reason;

  ReturnRefund({required this.status, required this.reason});

  factory ReturnRefund.fromJson(Map<String, dynamic> json) {
    return ReturnRefund(
      status: json['status'],
      reason: json['reason'],
    );
  }
}
