
class MapboxRoute {
  final double distance; // in meters
  final double duration; // in seconds
  final List<List<num>> coordinates; // [ [lng, lat], ... ]

  MapboxRoute({
    required this.distance,
    required this.duration,
    required this.coordinates,
  });

  factory MapboxRoute.fromJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final geometry = route['geometry']['coordinates'] as List<dynamic>;

    return MapboxRoute(
      distance: route['distance']?.toDouble() ?? 0.0,
      duration: route['duration']?.toDouble() ?? 0.0,
      coordinates: geometry
          .map<List<double>>((position) => [position[0], position[1]]).toList()
    );
  }
}