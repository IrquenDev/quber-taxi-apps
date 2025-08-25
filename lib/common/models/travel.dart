import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/models/encodable.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/enums/travel_request_type.dart';
import 'package:quber_taxi/enums/travel_state.dart';

class Travel implements Encodable{

  final int id;
  final String originName;
  final String destinationName;
  final List<num> originCoords;
  final List<num>? destinationCoords;
  final int requiredSeats;
  final bool hasPets;
  final TaxiType taxiType;
  final double? fixedDistance;
  final double? minDistance;
  final double? maxDistance;
  final double? fixedPrice;
  final double? minPrice;
  final double? maxPrice;
  final TravelState state;
  final TravelRequestType requestType;
  final Client client;
  final Driver? driver;
  final double? finalDistance;
  final double? finalDuration;
  final double? finalPrice;
  final DateTime? endDate;
  final DateTime requestedDate;

  const Travel({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.originCoords,
    this.destinationCoords,
    required this.requiredSeats,
    required this.hasPets,
    required this.taxiType,
    this.fixedDistance,
    this.minDistance,
    this.maxDistance,
    this.fixedPrice,
    this.minPrice,
    this.maxPrice,
    required this.state,
    required this.requestType,
    required this.client,
    required this.requestedDate,
    this.driver,
    this.finalDistance,
    this.finalPrice,
    this.finalDuration,
    this.endDate
  });

  factory Travel.fromJson(Map<String, dynamic> json) {
    return Travel(
        id: json["id"],
        originName: json["originName"],
        destinationName: json["destinationName"],
        originCoords: (json["originCoords"] as List).map((e) => e as num).toList(),
        destinationCoords: json["destinationCoords"] != null
            ? (json["destinationCoords"] as List).map((e) => e as num).toList()
            : null,
        requiredSeats: json["requiredSeats"],
        hasPets: json["hasPets"],
        taxiType: TaxiType.resolve(json["taxiType"]),
        fixedDistance: json["fixedDistance"],
        minDistance: json["minDistance"],
        maxDistance: json["maxDistance"],
        fixedPrice: json["fixedPrice"],
        minPrice: json["minPrice"],
        maxPrice: json["maxPrice"],
        state: TravelState.resolve(json["state"]),
        requestType: TravelRequestType.resolve(json["requestType"]),
        client: Client.fromJson(json["client"]),
        requestedDate: DateTime.parse(json["requestedDate"]),
        driver: json["driver"] != null ? Driver.fromJson(json["driver"]) : null,
        finalDuration: json["finalDuration"],
        finalPrice: json["finalPrice"],
        finalDistance: json["finalDistance"],
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "originName": originName,
    "destinationName": destinationName,
    "originCoords": originCoords,
    "destinationCoords": destinationCoords,
    "requiredSeats": requiredSeats,
    "hasPets": hasPets,
    "taxiType": taxiType.apiValue,
    "minDistance": minDistance,
    "fixedDistance": fixedDistance,
    "maxDistance": maxDistance,
    "fixedPrice": fixedPrice,
    "minPrice": minPrice,
    "maxPrice": maxPrice,
    "state": state.apiValue,
    "requestType": requestType.apiValue,
    "client": client.toJson(),
    "requestedDate": requestedDate.toIso8601String(),
    "driver": driver?.toJson(),
    "finalPrice": finalPrice,
    "finalDistance": finalDistance,
    "finalDuration": finalDuration,
    "endDate": endDate?.toIso8601String()
  };
}