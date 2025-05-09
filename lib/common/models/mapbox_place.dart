import 'package:flutter/foundation.dart';

@immutable
class MapboxPlace {

  final String placeName;
  final List<double> coordinates;
  final double relevance;

  const MapboxPlace({
    required this.placeName,
    required this.coordinates,
    required this.relevance
  });

  factory MapboxPlace.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as List<dynamic>;
    return MapboxPlace(
      placeName: json['place_name'],
      coordinates: [center[0], center[1]], // [lng, lat]
      relevance: (json['relevance'] as num).toDouble()
    );
  }
}