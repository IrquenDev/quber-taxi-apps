import 'package:flutter/material.dart';
import 'package:quber_taxi/client-app/pages/navigation/map.dart';
import 'package:quber_taxi/client-app/pages/navigation/trip_info.dart';

class ClientNavigation extends StatelessWidget {

  const ClientNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: const [
              ClientNavigationMap(),
              Align(alignment: Alignment.bottomCenter, child: TripInfoBottomOverlay())
            ]
        )
    );
  }
}