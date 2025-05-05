import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: CameraOptions(
          center: Point(coordinates: widget.position),
          pitch: 0,
          bearing: 0,
          zoom: 15
      ),
      onMapCreated: (controller){
        controller.location.updateSettings(LocationComponentSettings(enabled: true));
      }
    );
  }
}