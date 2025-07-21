import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';
import 'package:quber_taxi/enums/taxi_type.dart';

@immutable
class QuberConfig implements Encodable {

  final double driverCredit;
  final Map<TaxiType, double> travelPrice;

  const QuberConfig({
    required this.driverCredit, 
    required this.travelPrice
  });

  @override
  Map<String, dynamic> toJson() => {
    "driverCredit": driverCredit, 
    "travelPrice": travelPrice.map((key, value) => MapEntry(key.apiValue, value))
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
      driverCredit: json["driverCredit"], 
      travelPrice: vehiclePricesMap
    );
  }
}