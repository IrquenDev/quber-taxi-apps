import 'package:flutter/foundation.dart';

@immutable
class MapboxPlace {

  final String text; // Ej. Habana del Este
  final String placeName; // Ej. Habana del Este, provincia de La Habana, Cuba
  final List<num> coordinates;

  const MapboxPlace({
    required this.text,
    required this.placeName,
    required this.coordinates,
  });

  factory MapboxPlace.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as List<dynamic>;
    final text = json['text'] as String;
    final placeName = json['place_name'] as String;

    return MapboxPlace(
      text: text,
      placeName: placeName,
      coordinates: [center[0], center[1]],
    );
  }
}