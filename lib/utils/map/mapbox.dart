import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/models/mapbox_route.dart';

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
Future<MapboxRoute> loadGeoJsonFakeRoute(String source) async {
  final data = await rootBundle.loadString(source);
  return MapboxRoute.fromJson(json.decode(data));
}

/// Calculates the compass bearing between two geographic coordinates (lat/lon).
///
/// The result is the angle in degrees from the first point to the second,
/// measured clockwise from the north (0° is north, 90° is east, etc.).
///
/// Example:
/// ```dart
/// final bearing = calculateBearing(23.1, -82.3, 23.2, -82.4);
/// ```
///
/// Uses the haversine formula on a spherical Earth model.
/// Result is normalized to the range [0, 360).
double calculateBearing(num lat1, num lon1, num lat2, num lon2) {
  final phi1 = lat1 * (pi / 180);
  final phi2 = lat2 * (pi / 180);
  final deltaLon = (lon2 - lon1) * (pi / 180);
  final y = sin(deltaLon) * cos(phi2);
  final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLon);
  final theta = atan2(y, x);
  return (theta * 180 / pi + 360) % 360;
}

/// Zooms the Mapbox map to fit a set of coordinates with padding.
///
/// Calculates the southwest and northeast bounds from the list of
/// `[longitude, latitude]` coordinates, and applies a camera movement
/// with smooth animation and padding on all sides.
///
/// Example:
/// ```dart
/// await zoomToFitRoute(mapController, route.coordinates);
/// ```
///
/// [coords] must be a list of `[lng, lat]` values.
///
/// The padding is:
/// - Top & bottom: 50 pixels
/// - Left & right: 30 pixels
Future<void> zoomToFitRoute(MapboxMap controller, List<List<num>> coords) async {
  // Extract longitude and latitude lists separately
  final lngs = coords.map((e) => e[0]);
  final lats = coords.map((e) => e[1]);
  // Determine the coordinate bounds
  final minLat = lats.reduce((a, b) => a < b ? a : b);
  final maxLat = lats.reduce((a, b) => a > b ? a : b);
  final minLng = lngs.reduce((a, b) => a < b ? a : b);
  final maxLng = lngs.reduce((a, b) => a > b ? a : b);
  // Create a bounding box for camera fitting
  final cameraOptions = await controller.cameraForCoordinateBounds(
    CoordinateBounds(
      southwest: Point(coordinates: Position(minLng, minLat)),
      northeast: Point(coordinates: Position(maxLng, maxLat)),
      infiniteBounds: true,
    ),
    MbxEdgeInsets(top: 50, bottom: 50, left: 30, right: 30),
    0, 0, null, null,
  );
  // Animate the map camera to the computed bounds
  controller.easeTo(
    cameraOptions,
    MapAnimationOptions(duration: 500),
  );
}