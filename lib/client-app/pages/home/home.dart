import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/client-app/pages/home/request_travel_sheet.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class ClientHomePage extends StatefulWidget {

  const ClientHomePage({super.key, this.position});

  final Position? position;

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {

  // Default m3  BottomAppBar height. The length of the curved space under a centered FAB coincides with this value.
  final _bottomAppBarHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final borderRadius = Theme.of(context).extension<DimensionExtension>()!.borderRadius;
    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status, useTopSafeArea: true),
      alertPosition: Alignment.topCenter,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: const MapView(usingExtendedScaffold: true),
        floatingActionButton: FloatingActionButton(
          heroTag: "fab1",
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
            builder: (context) => MapView(),
            );
          },
          child: Icon(
            Icons.location_on,
            color: Theme.of(context).iconTheme.color,
            size: Theme.of(context).iconTheme.size,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        bottomNavigationBar: BottomAppBar(
          height: _bottomAppBarHeight,
          padding: EdgeInsets.zero,
          shape: const CircularNotchedRectangle(),
          notchMargin: 12.0,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 24,),
              _BottomBarItem(
                icon: Icons.local_taxi_outlined,
                label: AppLocalizations.of(context)!.askTaxi,
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
                    builder: (context) => RequestTravelSheet(),
                  );
                },
              ),
              _BottomBarItem(
                icon: Icons.settings_outlined,
                label: AppLocalizations.of(context)!.settingsHome,
                onPressed: () => context.push(ClientRoutes.settings),
              ),
              _QuberPoints(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.shadow,),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.shadow,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuberPoints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(ClientRoutes.quberReviews),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '56',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.quberPoints,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}