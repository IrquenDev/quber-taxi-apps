import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/driver-app/pages/navigation/trip_info.dart';

class DriverNavigation extends StatelessWidget {

  const DriverNavigation({super.key});

  @override
  Widget build(BuildContext context) {

    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );

    return Scaffold(
        body: Stack(
            children: [
              MapWidget(
                styleUri: MapboxStyles.STANDARD,
                cameraOptions: cameraOptions,
                onMapCreated: (controller) {
                  // Update some mapbox component
                  controller.location.updateSettings(LocationComponentSettings(enabled: false));
                  controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
                }
              ),
              Align(alignment: Alignment.bottomCenter, child: DriverTripInfo())
            ]
        )
    );
  }
}