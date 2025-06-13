import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/taxi.dart';

@immutable
class Driver {

  final int id;
  final String name;
  final String imageUrl;
  final String phone;
  final String email;
  final double credit;
  final DateTime paymentDate;
  final double rating;
  final Taxi taxi;

  const Driver({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.phone,
    required this.email,
    required this.credit,
    required this.paymentDate,
    required this.rating,
    required this.taxi
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      phone: json['phone'],
      email: json['email'],
      credit: (json['credit']),
      paymentDate: DateTime.parse(json['paymentDate']),
      rating: (json['rating']),
      taxi: Taxi.fromJson(json['taxi'])
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "imageUrl": imageUrl,
    "phone": phone,
    "email": email,
    "credit": credit,
    "paymentDate": paymentDate,
    "rating": rating,
    "taxi": taxi.toJson()
  };
}