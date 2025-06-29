import 'package:flutter/foundation.dart';

@immutable
class QuberConfig {

  final double driverCredit;
  final double travelPrice;

  const QuberConfig({required this.driverCredit, required this.travelPrice});

  Map<String, dynamic> toJson() => {"driverCredit": driverCredit, "travelPrice": travelPrice};

  factory QuberConfig.fromJson(Map<String, dynamic> json) {
    return QuberConfig(driverCredit: json["driverCredit"], travelPrice: json["travelPrice"]);
  }
}