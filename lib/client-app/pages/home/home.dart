import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/client-app/pages/home/bottom_sheet.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class ClientHome extends StatefulWidget {

  const ClientHome({super.key, this.position});

  final Position? position;

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {

  // Default m3  BottomAppBar height. The length of the curved space under a centered FAB coincides with this value.
  final _bottomAppBarHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final borderRadius = Theme.of(context).extension<DimensionExtension>()!.borderRadius;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: const MapView(usingExtendedScaffold: true),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          onPressed: () {
            showModalBottomSheet(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              isDismissible: false,
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
              ),
              builder: (context) => RequestTravelSheet()
            );
          },
          child: Icon(
            Icons.local_taxi,
            color: Theme.of(context).iconTheme.color,
            size: Theme.of(context).iconTheme.size
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Row(
          spacing: _bottomAppBarHeight,
          children: [
            Flexible(flex: 1, child: Center(child: _BottomBarItem(icon: Icons.location_on, label: 'Mapa'))),
            Flexible(flex: 1, child: Center(child: _QuberPoints())),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {

  final IconData icon;
  final String label;

  const _BottomBarItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        Text(label)
      ]
    );
  }
}

class _QuberPoints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('56'),
        Text('Puntos Quber')
      ]
    );
  }
}