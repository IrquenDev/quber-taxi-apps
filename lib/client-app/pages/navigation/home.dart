import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/client-app/pages/navigation/map_view.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/client-app/pages/navigation/trip_info.dart';

class ClientNavigation extends StatefulWidget {

  const ClientNavigation({super.key, this.position});

  final Position? position;

  @override
  State<ClientNavigation> createState() => _ClientNavigationState();
}

class _ClientNavigationState extends State<ClientNavigation> {


  @override
  Widget build(BuildContext context) {
    final borderRadius = Theme.of(context).extension<DimensionExtension>()!
        .borderRadius;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
      body: Stack(
        children: const [
          MapView(usingExtendedScaffold: true),
          TripInfoBottomOverlay(),
        ],
      ),
    );
  }
}