import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';
import 'package:quber_taxi/enums/taxi_type.dart';

@immutable
class QuberConfig implements Encodable {

  final double quberCredit;
  final Map<TaxiType, double> travelPrice;
  final String operatorPhone;

  const QuberConfig({
    required this.quberCredit,
    required this.travelPrice,
    required this.operatorPhone
  });

  @override
  Map<String, dynamic> toJson() => {
    "driverCredit": quberCredit,
    "travelPrice": travelPrice.map((key, value) => MapEntry(key.apiValue, value)),
    "operatorPhone": operatorPhone
  };

  factory QuberConfig.fromJson(Map<String, dynamic> json) {
    final vehiclePricesMap = <TaxiType, double>{};
    if (json["travelPrice"] != null) {
      final prices = json["travelPrice"] as Map<String, dynamic>;
      for (final entry in prices.entries) {
        vehiclePricesMap[TaxiType.resolve(entry.key)] = entry.value.toDouble();
      }
    }
    
    return QuberConfig(
      quberCredit: json["driverCredit"],
      travelPrice: vehiclePricesMap,
      operatorPhone: json["operatorPhone"]
    );
  }
}