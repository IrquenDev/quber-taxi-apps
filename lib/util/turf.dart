import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:quber_taxi/util/waypoint.dart';
import 'package:turf/turf.dart' as turf;

Future<turf.Polygon> loadGeoJsonPolygon(String source) async {
  final data = await rootBundle.loadString(source);
  final geoJson = json.decode(data);
  return turf.FeatureCollection.fromJson(geoJson).features.first.geometry as turf.Polygon;
}

Waypoint findNearestPointInPolygon({
  required turf.Position benchmark,
  required turf.Polygon polygon,
}) {
  turf.Position? closestPoint;
  num? minDistance;
  for (final points in polygon.coordinates) {
    for (final point in points) {
      final dist = turf.distance(turf.Point(coordinates: benchmark), turf.Point(coordinates: point));
      if (minDistance == null || dist < minDistance) {
        minDistance = dist;
        closestPoint = point;
      }
    }
  }
  return Waypoint(benchmark, closestPoint!, minDistance!);
}

Waypoint findFarthestPointInPolygon({
  required turf.Position benchmark,
  required turf.Polygon polygon,
}) {
  turf.Position? farthestPoint;
  num? maxDistance;
  for (final points in polygon.coordinates) {
    for (final point in points) {
      final dist = turf.distance(
        turf.Point(coordinates: benchmark),
        turf.Point(coordinates: point),
      );
      if (maxDistance == null || dist > maxDistance) {
        maxDistance = dist;
        farthestPoint = point;
      }
    }
  }
  return Waypoint(benchmark, farthestPoint!, maxDistance!);
}

bool isPointInPolygon(turf.Position point, turf.Polygon polygon) => turf.booleanPointInPolygon(point, polygon);