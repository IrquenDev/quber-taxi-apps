import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class ClientNavigationMap extends StatefulWidget {

  const ClientNavigationMap({super.key});

  @override
  State<ClientNavigationMap> createState() => _ClientNavigationMapState();
}

class _ClientNavigationMapState extends State<ClientNavigationMap> {

  @override
  Widget build(BuildContext context) {

    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return MapWidget(
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: cameraOptions,
      onMapCreated: (controller) {
        // Update some mapbox component
        controller.location.updateSettings(LocationComponentSettings(enabled: false));
        controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
      },
    );
  }
}