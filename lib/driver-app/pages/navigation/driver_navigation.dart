import 'package:flutter/material.dart';
import 'package:quber_taxi/driver-app/pages/navigation/map.dart';
import 'package:quber_taxi/driver-app/pages/navigation/trip_info.dart';

class DriverNavigation extends StatelessWidget {

  const DriverNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: const [
              DriverNavigationMap(),
              Align(alignment: Alignment.bottomCenter, child: TripInfoBottomOverlay())
            ]
        )
    );
  }
}