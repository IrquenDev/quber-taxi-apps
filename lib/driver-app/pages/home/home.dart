import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/driver-app/pages/home/info_travel_sheet.dart';
import 'package:quber_taxi/util/geolocator.dart' as g_util;
import 'package:quber_taxi/driver-app/pages/home/available_travels_sheet.dart';
import 'package:quber_taxi/util/mapbox.dart' as mb_util;
import 'package:quber_taxi/websocket/core/websocket_service.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key, this.coords});

  final Position? coords;

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {

  // Mapbox controller instance
  late MapboxMap _mapController;
  // Global map bearing. Initialized onMapCreated and updated onCameraChangeListener. Needed for calculate bearing
  // and updates driver (real or fakes) annotation markers.
  late double _mapBearing;
  // Fake drivers animation control
  final _frameInterval = Duration(milliseconds: 100);
  late Ticker _ticker;
  Duration _lastUpdate = Duration.zero;
  late final List<AnimatedFakeDriver> _taxis = [];
  // Point annotation (markers) control
  late final PointAnnotationManager _pointAnnotationManager;
  late final PointAnnotation _driverAnnotation;
  late final Uint8List _driverMarkerImage;
  // Driver location streaming
  late final Stream<g.Position> _locationStream;
  late Position _coords;
  late Position _lastKnownCoords;
  bool _isLocationStreaming = false;
  // Selected travel. If not null, we should hide the available travel sheet.
  Travel? _selectedTravel;
  final _travelService = TravelService();

  void _startStreamingLocation() async {
    // Get current position
    final position = await g.Geolocator.getCurrentPosition();
    final coords = Position(position.longitude, position.latitude);
    // Update class's field coord references
    _coords = coords;
    _lastKnownCoords = coords;
    // Add driver marker to map
    await _pointAnnotationManager.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: coords),
        image: _driverMarkerImage,
        iconAnchor: IconAnchor.CENTER,
      ),
    ).then((annotation) {
      _driverAnnotation = annotation;
      // Listen for real location updates
      _locationStream.listen((position) async {
        // Update coords
        final coords = Position(position.longitude, position.latitude);
        _lastKnownCoords = _coords;
        _coords = coords;
        // Adjust bearing
        final bearing = mb_util.calculateBearing(
            _lastKnownCoords.lat, _lastKnownCoords.lng,
            coords.lat, coords.lng
        );
        final adjustedBearing = (bearing - _mapBearing + 360) % 360;
        _driverAnnotation.iconRotate = adjustedBearing;
        _driverAnnotation.geometry = Point(coordinates: coords);
        _pointAnnotationManager.update(_driverAnnotation);
      });
    });
    _isLocationStreaming = true;
  }

  void _startSharingLocation() {
    _locationStream.listen((position) async {
      WebSocketService.instance.send(
        "/app/travels/${_selectedTravel!.id}/location",
        {"longitude": position.longitude, "latitude": position.latitude},
      );
      if(!_isLocationStreaming) _startStreamingLocation();
    });
  }

  void _onTravelSelected(Travel travel) async {
    /// TODO("yapmDev": static driver id)
    final response = await _travelService.assignTravelToDriver(travelId: travel.id, driverId: 3);
    if(response.statusCode == 200) {
      final assetBytes = await rootBundle.load('assets/markers/route/x120/origin.png');
      final originMarkerImage = assetBytes.buffer.asUint8List();
      final originCoords = Position(travel.originCoords[0], travel.originCoords[1]);
      await _pointAnnotationManager.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: originCoords),
          image: originMarkerImage,
          iconAnchor: IconAnchor.BOTTOM,
        ),
      );
      _mapController.easeTo(
          CameraOptions(center: Point(coordinates: originCoords)),
          MapAnimationOptions(duration: 500)
      );
      _startSharingLocation();
      setState(() => _selectedTravel = travel);
    } else {
      if(mounted) {
        showToast(context: context, message: "No se puedo asignar el viaje");
      }
    }
  }

  void _onTick(Duration elapsed) async {
    if (elapsed - _lastUpdate < _frameInterval) return;
    _lastUpdate = elapsed;
    for (final taxi in _taxis) {
      taxi.updatePosition(elapsed, _mapBearing);
      _pointAnnotationManager.update(taxi.annotation);
    }
  }

  @override
  void initState() {
    super.initState();
    _locationStream = g.Geolocator.getPositionStream().asBroadcastStream();
    _ticker = Ticker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraOptions = CameraOptions(
      center: Point(coordinates: widget.coords ?? Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return Material(
      child: Stack(
        children: [
          MapWidget(
            styleUri: MapboxStyles.STANDARD,
            cameraOptions: cameraOptions,
            onMapCreated: (controller) async {
              // Init class's field references
              _mapController = controller;
              _mapBearing = await _mapController.getCameraState().then((c) => c.bearing);
              // Update some mapbox component
              await controller.location.updateSettings(LocationComponentSettings(enabled: false));
              await controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
              // Create PAM
              _pointAnnotationManager = await controller.annotations.createPointAnnotationManager();
              // Load Taxi Marker
              final assetBytes = await rootBundle.load('assets/markers/taxi/taxi_pin_x172.png');
              _driverMarkerImage = assetBytes.buffer.asUint8List();
              // Add Fake Drivers Animation.
              // FDA is too heavy for the emulator.
              // As it is a requirement of the app, it will be enabled by default.
              // If you are working in this view or any other flow where you need to go through it, you can
              // disable it if you want (you should).
              // To do that set -dart-define=ALLOW_FDA=FALSE.
              // Just care running "flutter build apk" including this flag as FALSE.
              String definedAllowFDA = const String.fromEnvironment("ALLOW_FDA", defaultValue: "TRUE");
              final fdaAllowed = definedAllowFDA == "TRUE";
              if(fdaAllowed) {
                for (int i = 1; i <= 5; i++) {
                  final fakeRoute = await mb_util.loadGeoJsonFakeRoute("assets/geojson/line/fake_route_$i.geojson");
                  final origin = fakeRoute.coordinates.first;
                  final annotation = await _pointAnnotationManager.create(
                    PointAnnotationOptions(
                      geometry: Point(coordinates: Position(origin[0], origin[1])),
                      image: _driverMarkerImage,
                      iconAnchor: IconAnchor.CENTER,
                    ),
                  );
                  _taxis.add(AnimatedFakeDriver(
                      routeCoords: fakeRoute.coordinates,
                      annotation: annotation,
                      routeDuration: Duration(milliseconds: (fakeRoute.duration * 1000).round())
                  ));
                }
                // Start running fake drivers animation
                _ticker.start();
              }
            },
            onCameraChangeListener: (cameraData) async {
              // Always update bearing 'cause fake drivers animation depends on it
              _mapBearing = cameraData.cameraState.bearing;
              // Return if the driver location is not being streaming. Otherwise we need to re-calculate bearing for
              // the real driver marker. It is possible for this metric to change without significantly changing the
              // driver location.
              if(!_isLocationStreaming) return;
              final bearing = mb_util.calculateBearing(
                  _lastKnownCoords.lat, _lastKnownCoords.lng,
                  _coords.lat, _coords.lng
              );
              final adjusted = (bearing - _mapBearing + 360) % 360;
              _driverAnnotation.iconRotate = adjusted;
              _pointAnnotationManager.update(_driverAnnotation);
            }
          ),
          Positioned(
            right: 20.0,
            /// TODO("yapm": Avoid hardcoded space)
            bottom: _selectedTravel == null ? 150.0 : 20.0,
            child: Column(
              spacing: 8.0,
              children: [
                // Find my location
                FloatingActionButton(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  onPressed: () async {
                    // Ask for location permission
                    await g_util.requestLocationPermission(
                        context: context,
                        onPermissionGranted: () async {
                          // Start streaming location
                          if(!_isLocationStreaming) _startStreamingLocation();
                          // Ease to current position (Whether the location is being streaming)
                          _mapController.easeTo(
                              CameraOptions(center: Point(coordinates: _coords)),
                              MapAnimationOptions(duration: 500)
                          );
                        },
                        onPermissionDenied: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Permiso de ubicación denegado")),
                          );
                        },
                        onPermissionDeniedForever: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Permiso de ubicación denegado permanentemente")),
                          );
                        }
                    );
                  },
                  child: Icon(
                      Icons.my_location_outlined,
                      color: Theme.of(context).iconTheme.color,
                      size: Theme.of(context).iconTheme.size
                  ),
                ),
                // Show travel info bottom sheet
                if(_selectedTravel != null)
                  FloatingActionButton(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      onPressed: () => showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (context) => TravelInfoSheet(travel: _selectedTravel!)
                      ),
                      child: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).iconTheme.color,
                          size: Theme.of(context).iconTheme.size
                      )
                  ),
              ],
            )
          ),
          if(_selectedTravel == null)
            Align(alignment: Alignment.bottomCenter, child: AvailableTravelsSheet(onTravelSelected: _onTravelSelected))
        ]
      )
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