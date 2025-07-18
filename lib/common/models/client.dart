import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';

@immutable
class Client implements Encodable{

  final int id;
  final String name;
  final String phone;
  final String? profileImageUrl;
  final String referralCode;

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    this.profileImageUrl,
    required this.referralCode
  });

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "profileImageUrl": profileImageUrl,
    "referralCode": referralCode
  };

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        profileImageUrl: json["profileImageUrl"],
        referralCode: json["referralCode"]
    );
  }
}