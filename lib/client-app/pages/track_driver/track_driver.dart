import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/websocket/impl/driver_location_handler.dart';
import 'package:quber_taxi/util/mapbox.dart' as mb_util;

class TrackDriver extends StatefulWidget {
  final Travel travel;

  const TrackDriver({super.key, required this.travel});

  @override
  State<TrackDriver> createState() => _TrackDriverState();
}

class _TrackDriverState extends State<TrackDriver> {

  // Map
  late final MapboxMap _mapController;
  late double _mapBearing;

  // Markers
  late final PointAnnotationManager _pointAnnotationManager;
  PointAnnotation? _driverAnnotation;
  late final Uint8List _driverMarkerImage;

  // Driver location streaming
  late Position _coords;
  late Position _lastKnownCoords;

  // Websocket Handler for location tracking
  late final DriverLocationHandler _locationHandler;

  @override
  void initState() {
    super.initState();
    _loadDriverMarkerImage();
    _locationHandler = DriverLocationHandler(
        driverId: widget.travel.driver!.id,
        onLocation: _onDriverLocationUpdate
    )..activate();
  }

  void _loadDriverMarkerImage() async {
    final assetBytes = await rootBundle.load('assets/markers/taxi/taxi_pin_x172.png');
    _driverMarkerImage = assetBytes.buffer.asUint8List();
  }

  void _onDriverLocationUpdate(Position coords) async {
    // First time getting location data
    if (_driverAnnotation == null) {
      // Init coords
      _coords = coords;
      _lastKnownCoords = coords;
      // Set the marker
      _driverAnnotation = await _pointAnnotationManager.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: coords),
          image: _driverMarkerImage,
          iconAnchor: IconAnchor.CENTER,
        ),
      );
    } else {
      // Update coord
      _lastKnownCoords = _coords;
      _coords = coords;
      // Adjust bearing
      final bearing = mb_util.calculateBearing(
          _lastKnownCoords.lat, _lastKnownCoords.lng,
          coords.lat, coords.lng
      );
      final adjustedBearing = (bearing - _mapBearing + 360) % 360;
      // Update the marker
      _driverAnnotation!.iconRotate = adjustedBearing;
      _driverAnnotation!.geometry = Point(coordinates: coords);
      _pointAnnotationManager.update(_driverAnnotation!);
    }
  }

  @override
  void dispose() {
    _locationHandler.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final originCoords = widget.travel.originCoords;
    final center = Point(coordinates: Position(originCoords[0], originCoords[1]));

    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status, useTopSafeArea: true),
      alertPosition: Alignment.topCenter,
      child: MapWidget(
        styleUri: MapboxStyles.STANDARD,
        cameraOptions: CameraOptions(
          center: center,
          pitch: 45,
          bearing: 0,
          zoom: 17,
        ),
          onMapCreated: (controller) async {
            // Init class's field references
            _mapController = controller;
            _mapBearing = await _mapController.getCameraState().then((c) => c.bearing);
            // Update some mapbox component
            await controller.location.updateSettings(LocationComponentSettings(enabled: false));
            await controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
            // Create PAM
            _pointAnnotationManager = await controller.annotations.createPointAnnotationManager();
          },
          onCameraChangeListener: (cameraData) async {
            _mapBearing = cameraData.cameraState.bearing;
            if(_driverAnnotation != null) {
              final bearing = mb_util.calculateBearing(
                  _lastKnownCoords.lat, _lastKnownCoords.lng,
                  _coords.lat, _coords.lng
              );
              final adjustedBearing = (bearing - _mapBearing + 360) % 360;
              _driverAnnotation!.iconRotate = adjustedBearing;
              _pointAnnotationManager.update(_driverAnnotation!);
            }
          }
      ),
    );
  }
}