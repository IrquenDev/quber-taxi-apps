import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:quber_taxi/common/models/mapbox_route.dart';

/// Load a [MapboxRoute] from local .geojson asset.
Future<MapboxRoute> loadGeoJsonFakeRoute(String source) async {
  final data = await rootBundle.loadString(source);
  return MapboxRoute.fromJson(json.decode(data));
}

/// Bearing calculation.
double calculateBearing(num lat1, num lon1, num lat2, num lon2) {
  final phi1 = lat1 * (pi / 180);
  final phi2 = lat2 * (pi / 180);
  final deltaLon = (lon2 - lon1) * (pi / 180);
  final y = sin(deltaLon) * cos(phi2);
  final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLon);
  final theta = atan2(y, x);
  return (theta * 180 / pi + 360) % 360;
}