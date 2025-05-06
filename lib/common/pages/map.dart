import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
    required this.position
  });

  final Position position;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  final _mapboxService = MapboxService();
  final _lineLayer = LineLayer(
      id: "line-layer",
      sourceId: "sourceId", // matches GeoJsonSource.id
      lineColor: 0xFF0000FF,
      lineWidth: 4.0,
      minZoom: 1,
      maxZoom: 24
  );

  late MapboxMap _mapController;
  late PointAnnotationManager _pointAnnotationManager;
  late PointAnnotation _pointAnnotation;
  late Uint8List _imageData;

  var isLocationSelectedOnce = false;

  Future<void> zoomToFitRoute(List<List<double>> coords) async {
    final lats = coords.map((e) => e[1]);
    final lngs = coords.map((e) => e[0]);
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    
    final cameraOptions = await _mapController.cameraForCoordinateBounds(
        CoordinateBounds(
          southwest: Point(coordinates: Position(minLng, minLat)),
          northeast: Point(coordinates: Position(maxLng, maxLat)),
          infiniteBounds: true
        ),
        MbxEdgeInsets(top: 50, bottom: 50, left: 30, right: 30), 0, 0, null, null
    );

    _mapController.easeTo(
        cameraOptions,
        MapAnimationOptions(duration: 500) // 1 seg
    );
  }

  @override
  Widget build(BuildContext context) {

    final cameraOptions = CameraOptions(
        center: Point(coordinates: widget.position),
        pitch: 0,
        bearing: 0,
        zoom: 15
    );

    return MapWidget(
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: cameraOptions,
      onMapCreated: (mapboxMap) async {
        _mapController = mapboxMap;
        _mapController.annotations.createPointAnnotationManager().then((value) async {
          _pointAnnotationManager = value;
          final ByteData bytes = await rootBundle.load('assets/mapbox/location-marker.png');
          _imageData = bytes.buffer.asUint8List();
        });
        _mapController.location.updateSettings(LocationComponentSettings(enabled: true));
      },
      onTapListener: (mapContext) async {

        // Updating point
        final lng = mapContext.point.coordinates.lng;
        final lat = mapContext.point.coordinates.lat;
        var newPoint = Point(coordinates: Position(lng, lat));

        // _mapController.easeTo(
        //     cameraOptions.copyWith(center: newPoint),
        //     MapAnimationOptions(duration: 500) // 1 seg
        // );

        // Create or update destination marker
        if(isLocationSelectedOnce) {
          _pointAnnotation.geometry = newPoint;
          _pointAnnotationManager.update(_pointAnnotation);
        }
        else {
          _pointAnnotationManager.create(PointAnnotationOptions(
              geometry: newPoint,
              image: _imageData,
              iconAnchor: IconAnchor.BOTTOM
          )).then((value) => _pointAnnotation = value);
        }

        // Getting route
        final route = await _mapboxService.getRoute(
            originLat: widget.position.lat.toDouble(),
            originLng: widget.position.lng.toDouble(),
            destinationLat: lat.toDouble(),
            destinationLng: lng.toDouble()
        );

        // Animate the camera to a new point
        zoomToFitRoute(route.coordinates);

        // Drowning the rute
        if(isLocationSelectedOnce) {
          final coordinates = route.coordinates.map((position) => Position(position[0], position[1])).toList();
          await _mapController.style.updateGeoJSONSourceFeatures(
            "sourceId", "dataId", [Feature(id: "featureId", geometry: LineString(coordinates: coordinates))]
          );
          await _mapController.style.updateLayer(_lineLayer);
        }
        else {
          final geoJsonData = {
            "type": "Feature",
            "id": "featureId",
            "geometry": {
              "type": "LineString",
              "coordinates": route.coordinates
            }
          };
          await _mapController.style.addSource(GeoJsonSource(id: "sourceId", data: jsonEncode(geoJsonData)));
          await _mapController.style.addLayer(_lineLayer);
        }
        // If all instructions are completed correctly, it's safe to set that a location has been selected. This is
        // necessary to decide whether to create/update markers or routes.
        isLocationSelectedOnce = true;
      }
    );
  }
}