import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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

Future<void> zoomToFitRoute(MapboxMap controller, List<List<num>> coords) async {
  final lngs = coords.map((e) => e[0]);
  final lats = coords.map((e) => e[1]);
  final minLat = lats.reduce((a, b) => a < b ? a : b);
  final maxLat = lats.reduce((a, b) => a > b ? a : b);
  final minLng = lngs.reduce((a, b) => a < b ? a : b);
  final maxLng = lngs.reduce((a, b) => a > b ? a : b);

  final cameraOptions = await controller.cameraForCoordinateBounds(
      CoordinateBounds(
          southwest: Point(coordinates: Position(minLng, minLat)),
          northeast: Point(coordinates: Position(maxLng, maxLat)),
          infiniteBounds: true
      ),
      MbxEdgeInsets(top: 50, bottom: 50, left: 30, right: 30), 0, 0, null, null
  );

  controller.easeTo(
      cameraOptions,
      MapAnimationOptions(duration: 500)
  );
}