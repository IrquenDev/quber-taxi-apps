import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/client-app/pages/home/request_travel_sheet.dart';
import 'package:quber_taxi/client-app/pages/navigation/quber_reviews.dart';
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
  final List<Map<String, String>> _mockFavorites = [
    {
      'name': 'Mi oficina',
    },
    {
      'name': 'Peluquería de María',
    },
    {
      'name': 'Casa de mi abuela',
    },
    {
      'name': 'Gym',
    },
    {
      'name': 'Universidad de la habana',
    },
  ];
  bool _showRequestSheet = false;
  bool _showfavoriteDialog = false;


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
      alertBuilder: (_, status) =>
          CustomNetworkAlert(status: status, useTopSafeArea: true),
      alertPosition: Alignment.topCenter,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Stack(
          children: [
            _getCurrentScreen(),
            if (_showRequestSheet) _RequestTravelSheetWidget(),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          key: _navKey,
          index: _currentIndex,
          height: 70,
          color: Theme.of(context).colorScheme.primaryContainer,
          buttonBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.0),
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 500),
          letIndexChange: (index) {
            // Allow selection for first 3 items (0, 1, 2), block index 3 (Quber Points)
            if (index < 4) {
              setState(() {
                _currentIndex = index;
                // Show request sheet when taxi item is selected
                _showRequestSheet = index == 1;
                _showfavoriteDialog = index == 3;
              });
              
              // Show favorites dialog if needed
              if (_showfavoriteDialog) _showFavoritesDialog();
              
              return true; // Allow the change
            }
            return false; // Block the change for index 3
          },
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
            Transform.scale(
              scale: 1,
              child: _buildNavItem(Icons.favorite_border, localizations.favoritesBottomItem, 3,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _client.quberPoints.toInt().toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                  ),
                ),
              ),
            )
          ],
          onTap: (index) {
            // Navigation logic is now handled in letIndexChange
            // This callback is kept for any additional functionality if needed
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String text, int index) {
    final double iconSize = 28; // Reduced from 32 to 28
    final bool isSelected = _currentIndex == index;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: isSelected ? 0.0 : 16.0), // No padding when selected
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
              if (!isSelected)
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
      ),
    );
  }

  void _showFavoritesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.myMarkers,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop('map'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _mockFavorites
                .map(
                  (favorite) => ListTile(
                    leading: Image.asset(
                      'assets/markers/route/x60/pin_fav.png',
                      width: 20,
                      height: 20,
                    ),
                    title: Text(favorite['name']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_sharp),
                      onPressed: () {},
                    ),
                  ),
                )
                .toList(),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  Theme.of(context).cardTheme.elevation ?? 12.0)),
        );
      },
    ).then((_) => setState(() => _currentIndex = 0));
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const MapView(usingExtendedScaffold: true);
      case 1:
        return const MapView(usingExtendedScaffold: true);
      case 2:
        return const ClientSettingsPage();
      case 3:
        return const MapView(usingExtendedScaffold: true);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _RequestTravelSheetWidget extends StatefulWidget {
  @override
  State<_RequestTravelSheetWidget> createState() => _RequestTravelSheetWidgetState();
}

class _RequestTravelSheetWidgetState extends State<_RequestTravelSheetWidget> with TickerProviderStateMixin {
  double _sheetHeight = 0.0;
  double _dragStartY = 0;
  double _dragStartHeight = 0;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 0.9, // 90% final
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation
    _animationController.forward();

    // Update height when the animation changes
    _animationController.addListener(() {
      setState(() {
        _sheetHeight = _heightAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * _sheetHeight;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
              child: Container(
          height: sheetHeight,
        child: GestureDetector(
          onPanStart: (details) {
            _dragStartY = details.globalPosition.dy;
            _dragStartHeight = _sheetHeight;
          },
          onPanUpdate: (details) {
            final deltaY = _dragStartY - details.globalPosition.dy;
            final deltaHeight = deltaY / screenHeight;
            final newHeight = (_dragStartHeight + deltaHeight).clamp(0.2, 0.9);
            setState(() {
              _sheetHeight = newHeight;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
            ),
            child: Column(
              children: [
                // Handle bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: const RequestTravelSheet(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
