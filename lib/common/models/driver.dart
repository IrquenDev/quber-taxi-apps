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
  final List<num>? currentLocation;

  const Driver({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.phone,
    required this.email,
    required this.credit,
    required this.paymentDate,
    required this.rating,
    required this.taxi,
    this.currentLocation,
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
      taxi: Taxi.fromJson(json['taxi']),
      currentLocation: json['currentLocation'] != null
          ? List<num>.from(json['currentLocation'].map((e) => (e as num)))
          : null,
    );
  }
}