import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quber_taxi/util/mapbox.dart' as mb_util;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/client-app/pages/navigation/trip_info.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:turf/distance.dart' as td;
import 'package:turf/turf.dart' as turf;

class ClientNavigation extends StatefulWidget {

  final Travel travel;

  const ClientNavigation({super.key, required this.travel});

  @override
  State<ClientNavigation> createState() => _ClientNavigationState();
}

class _ClientNavigationState extends State<ClientNavigation> {

  // Map functionalities
  late final MapboxMap _mapController;
  late double _mapBearing;
  // Markers
  late PointAnnotationManager _pointAnnotationManager;
  PointAnnotation? _taxiMarker;
  // Real time distance calculation
  final List<turf.Position> _realTimeRoute = [];
  late final StreamSubscription<g.Position> _locationStream;
  num _distanceInKm = 0;

  void _startTrackingDistance() {
    _locationStream = g.Geolocator.getPositionStream(
        locationSettings: g.LocationSettings(distanceFilter: 5)
    ).listen(_onMove);
  }

  void _onMove(g.Position newPosition) {
    _calcRealTimeDistance(newPosition);
    _updateTaxiMarker(newPosition);
    _realTimeRoute.add(turf.Position(newPosition.longitude, newPosition.latitude));
  }

  void _calcRealTimeDistance(g.Position newPosition) {
    final point1 = turf.Point(coordinates: _realTimeRoute.last);
    final point2 = turf.Point(coordinates: turf.Position(newPosition.longitude, newPosition.latitude));
    final segmentDistance = td.distance(point1, point2, Unit.kilometers);
    setState(() => _distanceInKm += segmentDistance);
  }

  void _updateTaxiMarker(g.Position newPosition) async {
    final point = Point(coordinates: Position(newPosition.longitude, newPosition.latitude));
    if(_taxiMarker == null) {
      // Display marker
      final taxiMarkerBytes = await rootBundle.load('assets/markers/taxi/taxi_pin_x172.png');
      await _pointAnnotationManager.create(PointAnnotationOptions(
          geometry: point,
          image: taxiMarkerBytes.buffer.asUint8List(),
          iconAnchor: IconAnchor.BOTTOM
      )).then((value) => _taxiMarker = value);
    } else {
      // Update geometry point
      _taxiMarker!.geometry = point;
      // Update icon rotation (orientation)
      final bearing = mb_util.calculateBearing(
          _realTimeRoute.last.lat, _realTimeRoute.last.lng,
          newPosition.latitude, newPosition.longitude
      );
      final adjustedBearing = (bearing - _mapBearing + 360) % 360;
      _taxiMarker!.iconRotate = adjustedBearing;
      // Then update marker
      _pointAnnotationManager.update(_taxiMarker!);
    }
  }

  void _onMapCreated(MapboxMap controller) async {
    // Init fields
    _mapController = controller;
    _mapBearing = await _mapController.getCameraState().then((c) => c.bearing);
    _pointAnnotationManager = await _mapController.annotations.createPointAnnotationManager();
    // Update some mapbox component
    _mapController.location.updateSettings(LocationComponentSettings(enabled: false));
    _mapController.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    final position = Position(widget.travel.originCoords[0], widget.travel.originCoords[1]);
    // Display origin marker
    final originMarkerBytes = await rootBundle.load('assets/markers/route/x120/origin.png');
    await _pointAnnotationManager.create(PointAnnotationOptions(
        geometry: Point(
            coordinates: position
        ),
        image: originMarkerBytes.buffer.asUint8List(),
        iconAnchor: IconAnchor.BOTTOM
    ));
  }

  void _onCameraChangeListener(CameraChangedEventData camera) {
    _mapBearing = camera.cameraState.bearing;
    if(_taxiMarker != null) {
      final bearing = mb_util.calculateBearing(
          _realTimeRoute.last.lat, _realTimeRoute.last.lng,
          _realTimeRoute[_realTimeRoute.length -1].lat, _realTimeRoute[_realTimeRoute.length -1].lng
      );
      final adjustedBearing = (bearing - _mapBearing + 360) % 360;
      _taxiMarker!.iconRotate = adjustedBearing;
      _pointAnnotationManager.update(_taxiMarker!);
    }
  }

  @override
  void initState() {
    super.initState();
    _realTimeRoute.add(turf.Position(widget.travel.originCoords[0], widget.travel.originCoords[1]));
    _startTrackingDistance();
  }

  @override
  void dispose() {
    _locationStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Init camera options
    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(widget.travel.originCoords[0], widget.travel.originCoords[1])),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return Scaffold(
      body: MapWidget(
        styleUri: MapboxStyles.STANDARD,
        cameraOptions: cameraOptions,
        onMapCreated: _onMapCreated,
        onCameraChangeListener: _onCameraChangeListener,
      ),
      bottomSheet: ClientTripInfo(
        distance: _distanceInKm,
        originName: widget.travel.originName,
        destinationName: widget.travel.destinationName,
        taxiType: widget.travel.taxiType
      )
    );
  }
}