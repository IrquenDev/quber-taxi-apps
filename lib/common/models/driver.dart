import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';
import 'package:quber_taxi/common/models/taxi.dart';
import 'package:quber_taxi/enums/driver_account_state.dart';

@immutable
class Driver implements Encodable {

  final int id;
  final String name;
  final String phone;
  // final bool isAvailable;
  final double credit;
  // final DateTime? paymentDate;
  final double rating;
  final Taxi taxi;
  final DriverAccountState accountState;

  const Driver({
    required this.id,
    required this.name,
    required this.phone,
    // required this.isAvailable,
    required this.credit,
    // required this.paymentDate,
    required this.rating,
    required this.taxi,
    required this.accountState
  });

  @override
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      // isAvailable: json['available'],
      credit: (json['credit']),
      // paymentDate: json['paymentDate'] != null ?DateTime.parse(json['paymentDate']) : null,
      rating: (json['rating']),
      taxi: Taxi.fromJson(json['taxi']),
      accountState: DriverAccountState.resolve(json['accountState'] ?? "")
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    // "available": isAvailable,
    "credit": credit,
    // "paymentDate": paymentDate?.toIso8601String(),
    "rating": rating,
    "taxi": taxi.toJson(),
    "accountState": accountState.apiValue
  };
}