import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/util/turf.dart';
import 'package:turf/turf.dart' as turf;

class MapView extends StatefulWidget {

  const MapView({super.key, this.usingExtendedScaffold = false});

  final bool usingExtendedScaffold;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  MapboxMap? _mapController;
  late turf.Polygon _havanaPolygon;

  @override
  void initState() {
    super.initState();
    _loadHavanaGeoJson();
  }

  Future<void> _loadHavanaGeoJson() async {
    _havanaPolygon = await loadGeoJsonPolygon("assets/geojson/polygon/CiudadDeLaHabana.geojson");
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
            onMapCreated: (controller) {
              // Update some mapbox component
              controller.location.updateSettings(LocationComponentSettings(enabled: true));
              controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
              _mapController = controller;
            },
          ),
        ]
    );
  }
}