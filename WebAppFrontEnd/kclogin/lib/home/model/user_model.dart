import 'dart:convert';

class UserModel {
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final List<Map<String, dynamic>> storeList;

  UserModel({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.storeList,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      storeList: json['attributes']?['store'] != null
          ? List<Map<String, dynamic>>.from(jsonDecode(json['attributes']['store'][0]))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "attributes": {
        "store": jsonEncode(storeList),
      }
    };
  }
}
