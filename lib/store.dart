class Store {
  final int id;
  final String name;

  Store({
    required this.id,
    required this.name,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
    );
  }

// Optional: Convert User object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
  };
}
}

// Hardcoded JSON data outside the class
const Map<String, dynamic> jsonData = {
  "id": 12345,
  "name": "Shopee Korea",
};