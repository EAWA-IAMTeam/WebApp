class Inventory {
  final String stockCode;
  final String description;
  final int quantity;
  final double cost;

  Inventory({
    required this.stockCode,
    required this.description,
    required this.quantity,
    required this.cost,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      stockCode: json['stockCode'],
      description: json['description'],
      quantity: json['quantity'],
      cost: json['cost'],
    );
  }

// Optional: Convert User object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'stockCode': stockCode,
      'description': description,
      'quantity': quantity,
      'cost': cost,
    };
  }
}

// Hardcoded JSON data outside the class
const Map<String, dynamic> jsondata = {
  "stockCode": "New 1234",
  "description": "New Balance",
  "quantity": 12,
  "cost": 679,
};