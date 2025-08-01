import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/utils/map/geolocator.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/utils/map/turf.dart';
import 'package:quber_taxi/utils/map/mapbox.dart' as mb_util;

class MapView extends StatefulWidget {

  const MapView({super.key, this.usingExtendedScaffold = false});

  final bool usingExtendedScaffold;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  MapboxMap? _mapController;
  
  // Global map bearing. Initialized onMapCreated and updated onCameraChangeListener. Needed for calculate bearing
  // and updates driver (real or fakes) annotation markers.
  late double _mapBearing;

  // Fake drivers animation control
  static const _frameInterval = Duration(milliseconds: 100);
  late Ticker _ticker;
  Duration _lastUpdate = Duration.zero;
  late final List<AnimatedFakeDriver> _taxis = [];

  // Point annotation (markers) control
  PointAnnotationManager? _pointAnnotationManager;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _pointAnnotationManager?.deleteAll();
    super.dispose();
  }

  void _onTick(Duration elapsed) async {
    if (elapsed - _lastUpdate < _frameInterval) return;
    _lastUpdate = elapsed;
    for (final taxi in _taxis) {
      taxi.updatePosition(elapsed, _mapBearing);
      _pointAnnotationManager?.update(taxi.annotation);
    }
  }

  @override
  Widget build(BuildContext context) {

    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return Stack(
        children: [
          MapWidget(
            styleUri: MapboxStyles.STANDARD,
            cameraOptions: cameraOptions,
            onMapCreated: (controller) async {
              // Init class's field references
              _mapController = controller;
              _mapBearing = await controller.getCameraState().then((c) => c.bearing);
              // Update some mapbox component
              await controller.location.updateSettings(LocationComponentSettings(enabled: true));
              await controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
              // Disable pitch/tilt gestures to keep map flat
              await controller.gestures.updateSettings(GesturesSettings(pitchEnabled: false));
              // Create PAM
              _pointAnnotationManager = await controller.annotations.createPointAnnotationManager();
              
              // Load Taxi Marker
              final assetBytesA = await rootBundle.load('assets/markers/taxi/taxi_pin_x172.png');
              final assetBytesB = await rootBundle.load('assets/markers/taxi/pin_mototaxix172.png');
              final iconA = assetBytesA.buffer.asUint8List();
              final iconB = assetBytesB.buffer.asUint8List();
              
              // Add Fake Drivers Animation
              String definedAllowFDA = const String.fromEnvironment("ALLOW_FDA", defaultValue: "TRUE");
              final fdaAllowed = definedAllowFDA == "TRUE";
              if (fdaAllowed) {
                for (int i = 1; i <= 5; i++) {
                  final fakeRoute = await GeoUtils.loadGeoJsonFakeRoute("assets/geojson/line/fake_route_$i.geojson");
                  final origin = fakeRoute.coordinates.first;

                  final imageToUse = (i % 2 == 0) ? iconA : iconB;

                  final annotation = await _pointAnnotationManager?.create(
                    PointAnnotationOptions(
                      geometry: Point(coordinates: Position(origin[0], origin[1])),
                      image: imageToUse,
                      iconAnchor: IconAnchor.CENTER,
                    ),
                  );

                  _taxis.add(AnimatedFakeDriver(
                      routeCoords: fakeRoute.coordinates,
                      annotation: annotation!,
                      routeDuration: Duration(milliseconds: (fakeRoute.duration * 1000).round())
                  ));
                }
                _ticker.start();
              }
            },
            onCameraChangeListener: (cameraData) {
              // Always update bearing 'cause fake drivers animation depends on it
              _mapBearing = cameraData.cameraState.bearing;
            },
          ),
          // Find my location
          Positioned(
              right: 20.0, bottom: widget.usingExtendedScaffold ? 100.0 : 20.0,
              child: FloatingActionButton(
                  heroTag: "fab2",
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  onPressed: () async {
                    await requestLocationPermission(
                        context: context,
                        onPermissionGranted: () async {
                          final position = await g.Geolocator.getCurrentPosition();
                          // Check if inside of Havana
                          if (!kDebugMode) {
                            final isInside = GeoBoundaries.isPointInHavana(position.longitude, position.latitude);
                            if(!context.mounted) return;
                            if(!isInside) {
                              showToast(
                                  context: context,
                                  message: AppLocalizations.of(context)!.ubicationFailed
                              );
                              return;
                            }
                          }
                          _mapController!.easeTo(
                              CameraOptions(center: Point(coordinates: Position(position.longitude, position.latitude))),
                              MapAnimationOptions(duration: 500)
                          );
                        },
                        onPermissionDenied: () => showToast(context: context, message: AppLocalizations.of(context)!.permissionsDenied),
                        onPermissionDeniedForever: () =>
                            showToast(context: context, message: AppLocalizations.of(context)!.permissionDeniedPermanently)
                    );
                  },
                  child: Icon(
                      Icons.my_location_outlined,
                      color: Theme.of(context).iconTheme.color,
                      size: Theme.of(context).iconTheme.size
                  )
              )
          )
        ]
    );
  }
}

/// Represent a fake driver.
class AnimatedFakeDriver {

  /// Fake route coords.
  final List<List<num>> routeCoords;
  /// The corresponding annotation (marker) in the map.
  final PointAnnotation annotation;
  /// The route's duration in milliseconds estimated by Mapbox API.
  final Duration routeDuration;

  // Total segments to be covered.
  late final int _totalSegments;
  // Keep track of a specific animation.
  Duration startOffset = Duration.zero;

  AnimatedFakeDriver({required this.routeCoords, required this.annotation, required this.routeDuration}) {
    _totalSegments = routeCoords.length - 1;
  }

  /// Updates the geometry and orientation of the [AnimatedFakeDriver.annotation].
  void updatePosition(Duration globalElapsed, double mapBearing) {
    // Time a specific animation has been running
    final elapsed = globalElapsed - startOffset;
    // Real progress based in the suggested mapbox route duration
    double progress = elapsed.inMilliseconds / routeDuration.inMilliseconds;
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
    final start = routeCoords[segmentIndex];
    final end = routeCoords[segmentIndex + 1];
    // Adjust bearing
    final bearing = mb_util.calculateBearing(start[1], start[0], end[1], end[0]);
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
}