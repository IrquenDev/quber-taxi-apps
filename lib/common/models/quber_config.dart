import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';

@immutable
class QuberConfig implements Encodable{

  final double driverCredit;
  final double travelPrice;

  const QuberConfig({required this.driverCredit, required this.travelPrice});

  @override
  Map<String, dynamic> toJson() => {"driverCredit": driverCredit, "travelPrice": travelPrice};

  factory QuberConfig.fromJson(Map<String, dynamic> json) {
    return QuberConfig(driverCredit: json["driverCredit"], travelPrice: json["travelPrice"]);
  }
}