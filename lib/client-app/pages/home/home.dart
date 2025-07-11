import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/client-app/pages/home/request_travel_sheet.dart';
import 'package:quber_taxi/client-app/pages/settings/account_setting.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key, this.position});

  final Position? position;

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _currentIndex = 0;
  final _navKey = GlobalKey<CurvedNavigationBarState>();

  @override
  Widget build(BuildContext context) {
    final borderRadius = Theme.of(context).extension<DimensionExtension>()!.borderRadius;

    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status, useTopSafeArea: true),
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
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 500),
          items: [

            Transform.scale(
              scale: 1,
              child: _buildNavItem(Icons.location_on, 'Mapa', 0),
            ),
            Transform.scale(
              scale: 1,
              child: _buildNavItem(Icons.local_taxi_outlined, 'Pedir Taxi', 1),
            ),
            Transform.scale(
              scale: 1,
              child:  _buildNavItem(Icons.settings_outlined, 'Ajustes', 2),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, 4.0),
                  child: Text(
                    '56',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.shadow,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, 0),
                  child: Text(
                  'P. Quber',
                    style: TextStyle(
                      fontSize: _currentIndex == 3 ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color:  Theme.of(context).colorScheme.shadow,
                    ),
                ),
                ),

              ],
            )
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String text, int index) {
    // Ajusta estos valores según necesites
    final double iconVerticalPosition = 5.0; // Negativo = arriba, Positivo = abajo
    final double iconSize = 38.0;

    return SizedBox(
      width: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, iconVerticalPosition),
            child: Icon(
              icon,
              size: iconSize,
              color: Theme.of(context).colorScheme.shadow,
            ),
          ),
          Transform.translate(
            offset: Offset(0, 2.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize:_currentIndex == index ? 12 : 16,
                fontWeight: FontWeight.bold,
                color:  Theme.of(context).colorScheme.shadow,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0: return const MapView(usingExtendedScaffold: true);
      case 1: return const RequestTravelSheet();
      case 2: return const ClientSettingsPage();
      case 3: return const SizedBox();
      default: return const SizedBox();
    }
  }
}
