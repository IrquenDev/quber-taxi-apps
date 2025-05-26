class Travel {

  final int id;
  final String originName;
  final String destinationName;
  final List<num> originCoords;
  final int requiredSeats;
  final bool hasPets;
  final String taxiType;
  final double minDistance;
  final double maxDistance;
  final double minPrice;
  final double maxPrice;
  final String? state;

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
      "taxiType": taxiType,
      "minDistance": minDistance,
      "maxDistance": maxDistance,
      "minPrice": minPrice,
      "maxPrice": maxPrice
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
        taxiType: json["taxiType"],
        minDistance: json["minDistance"],
        maxDistance: json["maxDistance"],
        minPrice: json["minPrice"],
        maxPrice: json["maxPrice"],
        state: json["state"]
    );
  }
}