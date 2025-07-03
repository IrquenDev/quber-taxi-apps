import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';
import 'package:quber_taxi/common/models/taxi.dart';

@immutable
class Driver implements Encodable {

  final int id;
  final String name;
  final String imageUrl;
  final String phone;
  final bool isAvailable;
  final double credit;
  final DateTime paymentDate;
  final double rating;
  final Taxi taxi;

  const Driver({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.phone,
    required this.isAvailable,
    required this.credit,
    required this.paymentDate,
    required this.rating,
    required this.taxi
  });

  @override
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      phone: json['phone'],
      isAvailable: json['available'],
      credit: (json['credit']),
      paymentDate: DateTime.parse(json['paymentDate']),
      rating: (json['rating']),
      taxi: Taxi.fromJson(json['taxi'])
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "imageUrl": imageUrl,
    "phone": phone,
    "available": isAvailable,
    "credit": credit,
    "paymentDate": paymentDate.toIso8601String(),
    "rating": rating,
    "taxi": taxi.toJson()
  };
}