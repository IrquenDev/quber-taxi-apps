import 'dart:async';
import 'package:flutter/material.dart';
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

  late final MapboxMap _mapController;

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
    final point1 = turf.Point(coordinates: _realTimeRoute.last);
    final point2 = turf.Point(coordinates: turf.Position(newPosition.longitude, newPosition.latitude));
    final segmentDistance = td.distance(point1, point2, Unit.kilometers);
    _realTimeRoute.add(turf.Position(newPosition.longitude, newPosition.latitude));
    setState(() => _distanceInKm += segmentDistance);
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
      body: Stack(
          children: [
            // Map
            MapWidget(
                styleUri: MapboxStyles.STANDARD,
                cameraOptions: cameraOptions,
                onMapCreated: (controller) {
                  // Update some mapbox component
                  controller.location.updateSettings(LocationComponentSettings(enabled: true));
                  controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
                  _mapController = controller;
                }
            ),
            // Custom mini "sheet"
            Align(alignment: Alignment.bottomCenter, child: ClientTripInfo(distance: _distanceInKm))
          ]
      )
    );
  }
}