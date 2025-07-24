import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/client-app/pages/home/request_travel_screen.dart';
import 'package:quber_taxi/client-app/pages/settings/account_setting.dart';
import 'package:quber_taxi/common/services/app_announcement_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
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

  // Announcement service
  final _announcementService = AppAnnouncementService();
  bool _didCheckAnnouncements = false;

  // Network Checker
  late void Function() _listener;
  late final NetworkScope _scope;

  void _handleNetworkScopeAndListener() {
    _scope = NetworkScope.of(context);
    _listener = _scope.registerListener(_checkAnnouncementsListener);
  }

  void _checkAnnouncementsListener(ConnectionStatus status) async {
    if (!_didCheckAnnouncements) {
      final connectionStatus = NetworkScope.statusOf(context);
      if (connectionStatus == ConnectionStatus.checking) return;
      final isConnected = connectionStatus == ConnectionStatus.online;
      if (isConnected) {
        await _checkAnnouncements();
      }
    }
  }

  Future<void> _checkAnnouncements() async {
    if (_didCheckAnnouncements) return;
    
    try {
      final announcements = await _announcementService.getActiveAnnouncements();
      
      if (announcements.isNotEmpty && mounted) {
        // Navigate to the first announcement, passing the announcement data
        context.push(CommonRoutes.announcement, extra: announcements.first);
        _didCheckAnnouncements = true;
      }
    } catch (e) {
      // Handle error silently - announcements are not critical for app functionality
      print('Error checking announcements: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _handleNetworkScopeAndListener();
    });
  }

  @override
  void dispose() {
    _scope.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
              child: _buildNavItem(Icons.location_on, localizations.mapBottomItem, 0),
            ),
            Transform.scale(
              scale: 1,
              child: _buildNavItem(Icons.local_taxi_outlined, localizations.requestTaxiBottomItem, 1),
            ),
            Transform.scale(
              scale: 1,
              child:  _buildNavItem(Icons.settings_outlined, localizations.settingsBottomItem, 2),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    _client.quberPoints.toInt().toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.shadow,
                    ),
                  ),
                if(_currentIndex != 3)
                Text(
                  localizations.quberPoints,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:  Theme.of(context).colorScheme.shadow,
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
    final double iconSize = 32;

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
                color: Theme.of(context).colorScheme.shadow,
              ),
            if(_currentIndex != index)
            Transform.translate(
              offset: Offset(0, 2.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:  Theme.of(context).colorScheme.shadow,
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
      case 0: return const MapView(usingExtendedScaffold: true);
      case 1: return const RequestTravelScreen();
      case 2: return const ClientSettingsPage();
      case 3: return const SizedBox();
      default: return const SizedBox();
    }
  }
}
