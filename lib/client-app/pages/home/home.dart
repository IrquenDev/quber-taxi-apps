import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/client-app/pages/home/request_travel_sheet.dart';
import 'package:quber_taxi/client-app/pages/navigation/quber_reviews.dart';
import 'package:quber_taxi/client-app/pages/settings/account_setting.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../../../common/models/client.dart';
import '../../../utils/runtime.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key, this.position});

  final Position? position;

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _currentIndex = 0;
  final _navKey = GlobalKey<CurvedNavigationBarState>();
  final _client = Client.fromJson(loggedInUser);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return NetworkAlertTemplate(
      alertBuilder: (_, status) =>
          CustomNetworkAlert(status: status, useTopSafeArea: true),
      alertPosition: Alignment.topCenter,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: _getCurrentScreen(),
        bottomNavigationBar: CurvedNavigationBar(
          key: _navKey,
          index: _currentIndex,
          height: 70,
          color: Theme.of(context).colorScheme.primaryContainer,
          buttonBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.0),
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 500),
          items: [
            Transform.scale(
              scale: 1,
              child: _buildNavItem(
                  Icons.location_on, localizations.mapBottomItem, 0),
            ),
            Transform.scale(
              scale: 1,
              child: _buildNavItem(Icons.local_taxi_outlined,
                  localizations.requestTaxiBottomItem, 1),
            ),
            Transform.scale(
              scale: 1,
              child: _buildNavItem(
                  Icons.settings_outlined, localizations.settingsBottomItem, 2),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _client.quberPoints.toInt().toString(),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                    Text(
                      localizations.quberPointsBottomItem,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),

              ],
            )
          ],
          onTap: (index) {
            // Only navigate for the first 3 items (0, 1, 2)
            if (index < 3) {
              setState(() {
                _currentIndex = index;
              });
            } 
            // Index 3 (QuberPoints) does nothing - completely static
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String text, int index) {
    final double iconSize = Theme.of(context).iconTheme.size ?? 32;

    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
              Transform.translate(
                offset: const Offset(0, 2.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const MapView(usingExtendedScaffold: true);
      case 1:
        return const RequestTravelSheet();
      case 2:
        return const ClientSettingsPage();
      // case 3:
      //   return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}
