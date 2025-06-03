import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/models/mapbox_route.dart';
import 'package:quber_taxi/util/mapbox.dart';

class MultiDriversAnimationExample extends StatefulWidget {
  const MultiDriversAnimationExample({super.key});

  @override
  State<MultiDriversAnimationExample> createState() => _MultiDriversAnimationExampleState();
}

class _MultiDriversAnimationExampleState extends State<MultiDriversAnimationExample> {

  late MapboxMap _mapController;
  late PointAnnotationManager _pointAnnotationManager;
  late final List<AnimatedTaxi> _taxis = [];
  late Ticker _ticker;
  Duration _lastUpdate = Duration.zero;
  final _frameInterval = Duration(milliseconds: 120);

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
  }

  void _onTick(Duration elapsed) async {
    if (elapsed - _lastUpdate < _frameInterval) return;
    _lastUpdate = elapsed;
    final mapBearing = await _mapController.getCameraState().then((camera)=>camera.bearing);
    for (final taxi in _taxis) {
      taxi.updatePosition(elapsed, mapBearing);
      _pointAnnotationManager.update(taxi.annotation);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 15,
    );

    return MapWidget(
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: cameraOptions,
      onMapCreated: (controller) async {
        _mapController = controller;
        await controller.location.updateSettings(LocationComponentSettings(enabled: true));
        await controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
        _pointAnnotationManager = await controller.annotations.createPointAnnotationManager();

        final bytes = await rootBundle.load('assets/markers/taxi/taxi_pin_x172.png');
        final imageData = bytes.buffer.asUint8List();

        for (int i = 1; i <= 5; i++) {
          final fakeRoute = await loadGeoJsonFakeRoute("assets/geojson/line/fake_route_$i.geojson");
          final origin = fakeRoute.coordinates.first;
          final annotation = await _pointAnnotationManager.create(
            PointAnnotationOptions(
              geometry: Point(coordinates: Position(origin[0], origin[1])),
              image: imageData,
              iconAnchor: IconAnchor.CENTER,
            ),
          );

          _taxis.add(AnimatedTaxi(
            route: fakeRoute,
            annotation: annotation,
            totalDuration: Duration(milliseconds: (fakeRoute.duration * 1000).round())
          ));
        }

        _ticker.start();
      },
    );
  }
}

class AnimatedTaxi {

  final MapboxRoute route;
  final PointAnnotation annotation;
  final Duration totalDuration;

  late final List<List<num>> _coords;
  late final int _totalSegments;

  Duration startOffset = Duration.zero;

  AnimatedTaxi({required this.route, required this.annotation, required this.totalDuration}){
    _coords = route.coordinates;
    _totalSegments = _coords.length - 1;
  }

  void updatePosition(Duration globalElapsed, double mapBearing) {
    // Time a specific animation has been running
    final elapsed = globalElapsed - startOffset;
    // Real progress based in the suggested mapbox route duration
    double progress = elapsed.inMilliseconds / totalDuration.inMilliseconds;
    // Check total progress, if complete, then restart animation to the origin
    if (progress >= 1.0) {
      startOffset = globalElapsed;
      progress = 0.0;
    }
    // Index of the start point of the current segment
    final segmentIndex = (progress * _totalSegments).floor();
    // Avoid index out of bounds exception
    if (segmentIndex >= _totalSegments) return;
    // Use next coords
    final start = _coords[segmentIndex];
    final end = _coords[segmentIndex + 1];
    // Adjust bearing
    final bearing = _calculateBearing(start[1], start[0], end[1], end[0]);
    final adjustedBearing = (bearing - mapBearing + 360) % 360;
    // Linear interpolation
    final localT = (progress * _totalSegments) - segmentIndex;
    final lon = _lerp(start[0], end[0], localT);
    final lat = _lerp(start[1], end[1], localT);
    // Update annotation fields
    annotation
      ..geometry = Point(coordinates: Position(lon, lat))
      ..iconRotate = adjustedBearing;
  }

  // Basic linear interpolation.
  static num _lerp(num a, num b, num t) => a + (b - a) * t;

  // Bearing calculation.
  static double _calculateBearing(num lat1, num lon1, num lat2, num lon2) {
    final phi1 = lat1 * (pi / 180);
    final phi2 = lat2 * (pi / 180);
    final deltaLon = (lon2 - lon1) * (pi / 180);
    final y = sin(deltaLon) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLon);
    final theta = atan2(y, x);
    return (theta * 180 / pi + 360) % 360;
  }
}