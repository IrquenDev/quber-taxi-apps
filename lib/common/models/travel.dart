import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/enums/travel_state.dart';

class Travel {

  final int id;
  final String originName;
  final String destinationName;
  final List<num> originCoords;
  final int requiredSeats;
  final bool hasPets;
  final TaxiType taxiType;
  final double minDistance;
  final double maxDistance;
  final double minPrice;
  final double maxPrice;
  final TravelState state;

  Travel({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.originCoords,
    required this.requiredSeats,
    required this.hasPets,
    required this.taxiType,
    required this.minDistance,
    required this.maxDistance,
    required this.minPrice,
    required this.maxPrice,
    required this.state
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "originName": originName,
      "destinationName": destinationName,
      "originCoords": originCoords,
      "requiredSeats": requiredSeats,
      "hasPets": hasPets,
      "taxiType": taxiType.apiValue,
      "minDistance": minDistance,
      "maxDistance": maxDistance,
      "minPrice": minPrice,
      "maxPrice": maxPrice,
      "state": state.apiValue
    };
  }

  factory Travel.fromJson(Map<String, dynamic> json) {

    return Travel(
        id: json["id"],
        originName: json["originName"],
        destinationName: json["destinationName"],
        originCoords: (json["originCoords"] as List).map((e) => e as num).toList(),
        requiredSeats: json["requiredSeats"],
        hasPets: json["hasPets"],
        taxiType: TaxiType.resolve(json["taxiType"]),
        minDistance: json["minDistance"],
        maxDistance: json["maxDistance"],
        minPrice: json["minPrice"],
        maxPrice: json["maxPrice"],
        state: TravelState.resolve(json["state"])
    );
  }
}