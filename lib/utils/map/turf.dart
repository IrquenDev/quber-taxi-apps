import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:quber_taxi/utils/map/waypoint.dart';
import 'package:turf/turf.dart' as turf;

/// Loads a [turf.Polygon] from a local GeoJSON file asset.
///
/// The file must contain a valid FeatureCollection with a Polygon geometry
/// as its first feature. The asset must be declared in `pubspec.yaml`.
///
/// Example:
/// ```dart
/// final polygon = await loadGeoJsonPolygon('assets/zone.geojson');
/// ```
Future<turf.Polygon> loadGeoJsonPolygon(String source) async {
  final data = await rootBundle.loadString(source);
  final geoJson = json.decode(data);
  return turf.FeatureCollection.fromJson(geoJson).features.first.geometry as turf.Polygon;
}

/// Finds the closest point within a [turf.Polygon] to a given [benchmark] position.
///
/// Iterates over all coordinates in the polygon and returns the one
/// with the smallest distance to [benchmark], wrapped in a [Waypoint].
///
/// Example:
/// ```dart
/// final waypoint = findNearestPointInPolygon(
///   benchmark: turf.Position.of([-82.3, 23.1]),
///   polygon: polygon,
/// );
/// ```
Waypoint findNearestPointInPolygon({required turf.Position benchmark, required turf.Polygon polygon}) {
  turf.Position? closestPoint;
  num? minDistance;
  // Loop through each ring and point in the polygon
  for (final points in polygon.coordinates) {
    for (final point in points) {
      final dist = turf.distance(
        turf.Point(coordinates: benchmark),
        turf.Point(coordinates: point),
      );
      // Update minimum if necessary
      if (minDistance == null || dist < minDistance) {
        minDistance = dist;
        closestPoint = point;
      }
    }
  }
  return Waypoint(benchmark, closestPoint!, minDistance!);
}

/// Finds the farthest point within a [turf.Polygon] from a given [benchmark] position.
///
/// Iterates over all coordinates in the polygon and returns the one
/// with the greatest distance to [benchmark], wrapped in a [Waypoint].
///
/// Example:
/// ```dart
/// final farthest = findFarthestPointInPolygon(
///   benchmark: userLocation,
///   polygon: zone,
/// );
/// ```
Waypoint findFarthestPointInPolygon({required turf.Position benchmark, required turf.Polygon polygon}) {
  turf.Position? farthestPoint;
  num? maxDistance;
  // Loop through each ring and point in the polygon
  for (final points in polygon.coordinates) {
    for (final point in points) {
      final dist = turf.distance(
        turf.Point(coordinates: benchmark),
        turf.Point(coordinates: point),
      );
      // Update maximum if necessary
      if (maxDistance == null || dist > maxDistance) {
        maxDistance = dist;
        farthestPoint = point;
      }
    }
  }
  return Waypoint(benchmark, farthestPoint!, maxDistance!);
}

/// Checks whether a point (by [lng] and [lat]) lies within the given [polygon].
///
/// Internally uses Turf's `booleanPointInPolygon()` function.
///
/// Example:
/// ```dart
/// final isInside = isPointInPolygon(-82.3, 23.1, zonePolygon);
/// ```
bool isPointInPolygon(num lng, num lat, turf.Polygon polygon) =>
    turf.booleanPointInPolygon(turf.Position(lng, lat), polygon);