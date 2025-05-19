import 'package:flutter/foundation.dart';

@immutable
class MapboxPlace {
  final String name;
  final List<double> coordinates;

  const MapboxPlace({
    required this.name,
    required this.coordinates,
  });

  factory MapboxPlace.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as List<dynamic>;
    final placeName = json['text'] as String;

    return MapboxPlace(
      name: placeName,
      coordinates: [center[0] as double, center[1] as double],
    );
  }
}