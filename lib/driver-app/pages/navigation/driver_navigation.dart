import 'dart:async';
import 'dart:convert';
import 'package:quber_taxi/driver-app/pages/navigation/trip_completed.dart';
import 'package:quber_taxi/enums/municipalities.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/util/mapbox.dart' as mb_util;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';
import 'package:quber_taxi/driver-app/pages/navigation/trip_info.dart';
import 'package:quber_taxi/enums/mapbox_place_type.dart';
import 'package:quber_taxi/util/mapbox.dart';
import 'package:quber_taxi/util/turf.dart';
import 'package:quber_taxi/websocket/core/websocket_service.dart';
import 'package:quber_taxi/websocket/impl/travel_state_handler.dart';
import 'package:turf/distance.dart' as td;
import 'package:turf/turf.dart' as turf;

class DriverNavigation extends StatefulWidget {

  final Travel travel;

  const DriverNavigation({super.key, required this.travel});

  @override
  State<DriverNavigation> createState() => _DriverNavigationState();
}

class _DriverNavigationState extends State<DriverNavigation> {

  // Map functionalities
  final _mapboxService = MapboxService();
  late final MapboxMap _mapController;
  late double _mapBearing;
  // Markers
  PointAnnotationManager? _pointAnnotationManager;
  late Uint8List _destinationMakerImage;
  PointAnnotation? _destinationMarker;
  PointAnnotation? _taxiMarker;
  // LineLayer for drawing route
  final _lineLayer = LineLayer(
      id: "line-layer",
      sourceId: "sourceId", // matches GeoJsonSource.id
      lineColor: 0xFF0000FF,
      lineWidth: 4.0,
      minZoom: 1,
      maxZoom: 24
  );
  bool _isRouteDrawn = false;
  bool _isGuidedRouteEnabled = false;
  // Real time distance calculation
  final List<turf.Position> _realTimeRoute = [];
  late final StreamSubscription<g.Position> _locationStream;
  num _distanceInKm = 0;
  Stopwatch? _stopwatch;
  // Ignore points outside of Havana
  late turf.Polygon _municipalityPolygon;
  // Websocket for travel state changed (Here we must wait for the client to accept the finish confirmation or
  // trigger it be himself).
  late final TravelStateHandler _travelStateHandler;

  Future<void> _loadHavanaGeoJson() async {
    final munName= Municipalities.resolveGeoJsonRef(widget.travel.destinationName);
    _municipalityPolygon = await loadGeoJsonPolygon(munName!);
  }

  void _startTrackingDistance() {
    _locationStream = g.Geolocator.getPositionStream(
        locationSettings: g.LocationSettings(distanceFilter: 5)
    ).listen(_onMove);
  }

  void _onMove(g.Position newPosition) {
    _stopwatch ??= Stopwatch()..start();
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
    if(_pointAnnotationManager != null) {
      final point = Point(coordinates: Position(newPosition.longitude, newPosition.latitude));
      if(_taxiMarker == null) {
        // Display marker
        final taxiMarkerBytes = await rootBundle.load('assets/markers/taxi/taxi_pin_x172.png');
        await _pointAnnotationManager!.create(PointAnnotationOptions(
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
        _pointAnnotationManager!.update(_taxiMarker!);
      }
    }
  }

  Future<void> _getAndDrownRoute(num originLng, num originLat, num destinationLng, num destinationLat) async {
    // Getting route and drown
    final route = await _mapboxService.getRoute(
      originLng: originLng, originLat: originLat, destinationLng: destinationLng, destinationLat: destinationLat
    );
    // Applying dynamic zoom to fully expose the route.
    zoomToFitRoute(_mapController, route.coordinates);
    // Create or update destination marker
    final point = Point(coordinates: Position(destinationLng, destinationLat));
    if(_destinationMarker == null) {
      _pointAnnotationManager!.create(PointAnnotationOptions(
          geometry: point,
          image: _destinationMakerImage,
          iconAnchor: IconAnchor.BOTTOM
      )).then((value) => _destinationMarker = value);
    }
    else {
      _destinationMarker!.geometry = point;
      _pointAnnotationManager!.update(_destinationMarker!);
    }
    // Drowning the rute
    if(!_isRouteDrawn) {
      final geoJsonData = {
        "type": "Feature",
        "id": "featureId",
        "geometry": {
          "type": "LineString",
          "coordinates": route.coordinates
        }
      };
      await _mapController.style.addSource(
          GeoJsonSource(id: "sourceId", data: jsonEncode(geoJsonData))
      );
      await _mapController.style.addLayer(_lineLayer);
      _isRouteDrawn = true;
    }
    else {
      final coordinates = route.coordinates
          .map((position) => Position(position[0], position[1]))
          .toList();
      await _mapController.style.updateGeoJSONSourceFeatures(
          "sourceId", "dataId", [Feature(id: "featureId", geometry: LineString(coordinates: coordinates))]
      );
      await _mapController.style.updateLayer(_lineLayer);
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
    await _pointAnnotationManager!.create(PointAnnotationOptions(
        geometry: Point(
            coordinates: position
        ),
        image: originMarkerBytes.buffer.asUint8List(),
        iconAnchor: IconAnchor.BOTTOM
    ));
    // Load destination marker image
    final destinationMarkerBytes = await rootBundle.load('assets/markers/route/x120/destination.png');
    _destinationMakerImage = destinationMarkerBytes.buffer.asUint8List();
  }

  void _onLongTapListener(MapContentGestureContext mapContext) async {
    if(_isGuidedRouteEnabled) {
      // Getting coords
      final lng = mapContext.point.coordinates.lng;
      final lat = mapContext.point.coordinates.lat;
      // Check if inside of Havana
      final isInside = isPointInPolygon(lng, lat, _municipalityPolygon);
      if(!isInside) {
        showToast(context: context, message: "Los destinos están limitados a ${widget.travel.destinationName}");
        return;
      } else {
        await _getAndDrownRoute(widget.travel.originCoords[0], widget.travel.originCoords[1], lng, lat);
      }
    }
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
      _pointAnnotationManager!.update(_taxiMarker!);
    }
  }

  Future<bool> _onSearch (String query) async {
    final destination = await _mapboxService.getLocationCoords(
        query: query,
        proximity: [_realTimeRoute.last.lng, _realTimeRoute.last.lat],
        types: [
          MapboxPlaceType.place,
          MapboxPlaceType.locality,
          MapboxPlaceType.address,
          MapboxPlaceType.district
        ]
    );
    if(!mounted) return false;
    // Depending on what was typed, result could be null
    if(destination == null) {
      showToast(context: context, message: "No se encontró dicho lugar");
      return false;
    }
    // Some places matches ...
    else {
      await _getAndDrownRoute(
          widget.travel.originCoords[0],
          widget.travel.originCoords[1],
          destination.coordinates[0],
          destination.coordinates[1]
      );
      return true;
    }
  }

  void _onGuidedRouteSwitched(bool isEnabled) async {
    if(!isEnabled && _isRouteDrawn) {
      await _mapController.style.removeStyleLayer("line-layer");
      await _mapController.style.removeStyleSource("sourceId");
      await _pointAnnotationManager!.delete(_destinationMarker!);
      _destinationMarker = null;
      _isRouteDrawn = false;
    }
    setState(() => _isGuidedRouteEnabled = isEnabled);
  }

  void _showTripCompletedBottomSheet() {
    _stopwatch?.stop();
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        isDismissible: false,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => DriverTripCompleted(
          travel: widget.travel,
          duration: _stopwatch?.elapsed.inMinutes ?? 0,
          distance: _distanceInKm,
        )
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHavanaGeoJson();
    _realTimeRoute.add(turf.Position(widget.travel.originCoords[0], widget.travel.originCoords[1]));
    _startTrackingDistance();
    _travelStateHandler = TravelStateHandler(
        state: TravelState.completed,
        travelId: widget.travel.id,
        onMessage: (_) => _showTripCompletedBottomSheet()
    )..activate();
  }

  @override
  void dispose() {
    _locationStream.cancel();
    _travelStateHandler.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Init camera options
    final position = Position(widget.travel.originCoords[0], widget.travel.originCoords[1]);
    final cameraOptions = CameraOptions(
      center: Point(coordinates: position),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: MapWidget(
          styleUri: MapboxStyles.STANDARD,
          cameraOptions: cameraOptions,
          onMapCreated: _onMapCreated,
          onLongTapListener: _onLongTapListener,
          onCameraChangeListener: _onCameraChangeListener
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            WebSocketService.instance.send(
                "/app/travels/${widget.travel.id}/finish-confirmation", null // no body needed
            );
          },
          child: Icon(Icons.done_outline),
        ),
        bottomSheet: DriverTripInfo(
          originName: widget.travel.originName,
          destinationName: widget.travel.destinationName,
          distance: _distanceInKm,
          taxiType: widget.travel.taxiType,
          onGuidedRouteSwitched: _onGuidedRouteSwitched,
          onSearch: _onSearch
        )
    );
  }
}