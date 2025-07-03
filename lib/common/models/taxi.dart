import 'package:flutter/foundation.dart';
import 'package:quber_taxi/common/models/encodable.dart';
import 'package:quber_taxi/enums/taxi_type.dart';

@immutable
class Taxi implements Encodable{
  final int id;
  final String plate;
  final String imageUrl;
  final int seats;
  final TaxiType type;

  const Taxi({
    required this.id,
    required this.plate,
    required this.imageUrl,
    required this.seats,
    required this.type,
  });

  factory Taxi.fromJson(Map<String, dynamic> json) {
    return Taxi(
        id: json['id'],
        plate: json['plate'],
        imageUrl: json['imageUrl'],
        seats: json['seats'],
        type: TaxiType.resolve(json["type"]),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "plate": plate,
    "imageUrl": imageUrl,
    "seats": seats,
    "type": type.apiValue
  };
}