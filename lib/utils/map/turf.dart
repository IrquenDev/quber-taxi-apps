import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:quber_taxi/common/models/mapbox_route.dart';
import 'package:turf/turf.dart' as turf;
import 'package:quber_taxi/utils/map/waypoint.dart';

/// A collection of geospatial utility methods built on top of Turf.
class GeoUtils {

  GeoUtils._();

  /// Loads a [turf.Polygon] from a local GeoJSON file asset.
  ///
  /// The file must contain a valid FeatureCollection with a Polygon geometry
  /// as its first feature. The asset must be declared in `pubspec.yaml`.
  ///
  /// Example:
  /// ```dart
  /// final polygon = await GeoUtils.loadGeoJsonPolygon('assets/zone.geojson');
  /// ```
  static Future<turf.Polygon> loadGeoJsonPolygon(String source) async {
    final data = await rootBundle.loadString(source);
    final geoJson = json.decode(data);
    return turf.FeatureCollection.fromJson(geoJson).features.first.geometry as turf.Polygon;
  }

  /// Loads a [MapboxRoute] object from a local `.geojson` asset.
  ///
  /// This is useful for testing or simulating routes without relying on
  /// online APIs. The `.geojson` file must be properly formatted and declared
  /// in the `pubspec.yaml` under `assets`.
  ///
  /// Example:
  /// ```dart
  /// final route = await loadGeoJsonFakeRoute('assets/fake_route.geojson');
  /// ```
  static Future<MapboxRoute> loadGeoJsonFakeRoute(String source) async {
    final data = await rootBundle.loadString(source);
    return MapboxRoute.fromJson(json.decode(data));
  }

  /// Finds the closest point within a [polygon] to a given [benchmark] position.
  ///
  /// Iterates over all coordinates in the polygon and returns the one
  /// with the smallest distance to [benchmark], wrapped in a [Waypoint].
  ///
  /// Example:
  /// ```dart
  /// final waypoint = GeoUtils.findNearestPointInPolygon(
  ///   benchmark: turf.Position.of([-82.3, 23.1]),
  ///   polygon: polygon,
  /// );
  /// ```
  static Waypoint findNearestPointInPolygon({
    required turf.Position benchmark,
    required turf.Polygon polygon,
  }) {
    turf.Position? closestPoint;
    num? minDistance;

    for (final ring in polygon.coordinates) {
      for (final point in ring) {
        final dist = turf.distance(
          turf.Point(coordinates: benchmark),
          turf.Point(coordinates: point),
        );
        if (minDistance == null || dist < minDistance) {
          minDistance = dist;
          closestPoint = point;
        }
      }
    }

    return Waypoint(benchmark, closestPoint!, minDistance!);
  }

  /// Finds the farthest point within a [polygon] from a given [benchmark] position.
  ///
  /// Iterates over all coordinates in the polygon and returns the one
  /// with the greatest distance to [benchmark], wrapped in a [Waypoint].
  ///
  /// Example:
  /// ```dart
  /// final farthest = GeoUtils.findFarthestPointInPolygon(
  ///   benchmark: userLocation,
  ///   polygon: zone,
  /// );
  /// ```
  static Waypoint findFarthestPointInPolygon({
    required turf.Position benchmark,
    required turf.Polygon polygon,
  }) {
    turf.Position? farthestPoint;
    num? maxDistance;

    for (final ring in polygon.coordinates) {
      for (final point in ring) {
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
}

/// A static utility class that manages region-specific polygon boundaries,
/// such as the official province boundary of La Havana, Cuba.
class GeoBoundaries {

  GeoBoundaries._();

  static turf.Polygon? _havanaPolygon;

  /// Loads the official polygon boundary for the Province of La Havana (Cuba)
  /// from local GeoJSON assets.
  ///
  /// This method should be called once during app startup.
  ///
  /// Example:
  /// ```dart
  /// await GeoBoundaries.loadHavanaPolygon();
  /// ```
  static Future<void> loadHavanaPolygon() async {
    if (_havanaPolygon != null) return;
    _havanaPolygon = await GeoUtils.loadGeoJsonPolygon("assets/geojson/polygon/CiudadDeLaHabana.geojson");
  }

  /// Returns `true` if the point defined by [lng] and [lat] lies within the
  /// boundaries of the Province of La Havana.
  ///
  /// Throws a [StateError] if the polygon hasn't been loaded yet.
  ///
  /// Example:
  /// ```dart
  /// final isInHavana = GeoBoundaries.isPointInHavana(-82.3, 23.1);
  /// ```
  static bool isPointInHavana(num lng, num lat) {
    if (_havanaPolygon == null) {
      throw StateError("Havana polygon not loaded. Call loadHavanaPolygon() first.");
    }
    return isPointInPolygon(lng, lat, _havanaPolygon!);
  }

  /// Checks whether a point defined by [lng] and [lat] lies inside the given [polygon].
  ///
  /// Internally uses Turf's `booleanPointInPolygon()` function.
  ///
  /// Example:
  /// ```dart
  /// final isInside = GeoUtils.isPointInPolygon(-82.3, 23.1, polygon);
  /// ```
  static bool isPointInPolygon(num lng, num lat, turf.Polygon polygon) {
    return turf.booleanPointInPolygon(turf.Position(lng, lat), polygon);
  }
}