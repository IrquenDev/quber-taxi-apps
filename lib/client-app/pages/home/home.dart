import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_fusion/flutter_fusion.dart' show showToast;
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/client-app/pages/home/request_travel_sheet.dart';
import 'package:quber_taxi/client-app/pages/settings/setting.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/common/widgets/dialogs/circular_info_dialog.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/storage/config_prefs_manager.dart';
import 'package:quber_taxi/storage/favorites_prefs_manager.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key, this.position});

  final Position? position;

  @override
  State<ClientHomePage> createState() => ClientHomePageState();
}

class ClientHomePageState extends State<ClientHomePage> {
  int _currentIndex = 0;
  final _navKey = GlobalKey<CurvedNavigationBarState>();

  bool _showRequestSheet = false;
  bool _showFavoriteDialog = false;
  bool _showQuberPointsDialog = false;

  // Single MapView instance to avoid GlobalKey conflicts
  late final MapView _mapViewInstance;

  // Http Services
  final _travelService = TravelService();

  // NetworkChecker
  late final NetworkScope _scope;
  late void Function() _checkNewsListenerRef;
  late void Function() _syncTravelStateListenerRef;
  static bool didSyncTravelState = false;

  // Logged in user
  final _client = Client.fromJson(loggedInUser);

  void _handleNetworkScopeAndListeners() {
    _scope = NetworkScope.of(context);
    final connStatus = NetworkScope.statusOf(context);
    final isAlreadyOnline = connStatus == ConnectionStatus.online;
    // We need to register a connection status listener, as it depends on ConnectionStatus being online to execute
    // _checkClientAccountState. If the client is offline (any status other than checking or online), they won't be
    // able to continue.
    _syncTravelStateListenerRef = _scope.registerListener(_syncTravelStateListener);
    // Since execution times are not always the same, it's possible that when the listeners are registered, the current
    // status is already online, so the listeners won't be notified. This is why we must make an initial manual call.
    // In any case, calls will not be duplicated since they are being protected with an inner flag.
    if (isAlreadyOnline) {
      _syncTravelStateListener(connStatus);
    }
  }

  Future<void> _syncTravelStateListener(ConnectionStatus status) async {
    if (status == ConnectionStatus.checking) return;
    final isConnected = status == ConnectionStatus.online;
    if (isConnected) {
      await _syncTravelState();
    }
  }

  Future<void> _syncTravelState() async {
    if (didSyncTravelState) {
      return;
    }
    final response = await _travelService.getActiveTravelState(_client.id);
    if (!mounted) return;
    //Ignoring 404 (means no active travel) and unexpected status codes.
    if (response.statusCode == 200) {
      final activeTravel = Travel.fromJson(jsonDecode(response.body));
      // A trip is considered active if its status is WAITING, ACCEPTED, or IN_PROGRESS. So we are only going to handle
      // those states.
      final travelState = activeTravel.state;
      if (travelState == TravelState.waiting) {
        final shouldMarkAsCanceled =
            DateTime.now().subtract(const Duration(minutes: 3)).isAfter(activeTravel.requestedDate);
        if (shouldMarkAsCanceled) {
          await _cancelTravelRequest(activeTravel.id);
        } else {
          context.go(ClientRoutes.searchDriver, extra: {
            'travelId': activeTravel.id,
            'travelRequestedDate': activeTravel.requestedDate,
            'wasPageRestored': true,
          });
        }
      } else if (travelState == TravelState.accepted) {
        context.go(ClientRoutes.trackDriver, extra: activeTravel);
      }
      // TravelState.inProgress
      else {
        context.go(ClientRoutes.navigation, extra: {
          'travel': activeTravel,
          'wasPageRestored': true,
        });
      }
    }
    didSyncTravelState = true;
  }

  /// Opens the system phone dialer with the given [phoneNumber].
  ///
  /// If the dialer cannot be launched, throws an exception.
  void _launchPhoneDialer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch dialer with number $phoneNumber';
    }
  }

  Future<void> _showOfflineModeDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: Text("¡Upps!. Parece que no tiene conexión")),
            IconButton(icon: const Icon(Icons.close_outlined), onPressed: () => context.pop()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12.0,
          children: [
            const Text("No hemos detectado conexión para pedir el viaje, pero aquí le traemos otras alternativas:"),
            // Call option
            FilledButton(
              onPressed: () {
                final phoneNumber = ConfigPrefsManager.instance.getOperatorPhone();
                _launchPhoneDialer(phoneNumber ?? "+5352417814");
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12.0,
                children: [Icon(Icons.phone_outlined), Text("Pedir por llamada")],
              ),
            ),
            // SMS option
            const FilledButton(
              onPressed: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12.0,
                children: [
                  Icon(Icons.sms_outlined),
                  Expanded(
                    child: Text("Pedir por SMS (Diponible pronto)"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // It is responsible for canceling the previous trip request, either because the driver search was canceled by
  // manual action of the user or because the time limit has passed.
  Future<void> _cancelTravelRequest(int travelId) async {
    final response = await _travelService.changeState(travelId: travelId, state: TravelState.canceled);
    if (!mounted) return;
    if (response.statusCode == 200) {
      showToast(context: context, message: AppLocalizations.of(context)!.tripRequestCancelled);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize single MapView instance
    _mapViewInstance = MapView(key: MapView.globalKey, usingExtendedScaffold: true);
    // Register post frame callback
    SchedulerBinding.instance.addPostFrameCallback((_) async => _handleNetworkScopeAndListeners());
  }

  @override
  void dispose() {
    _scope.removeListener(_checkNewsListenerRef);
    _scope.removeListener(_syncTravelStateListenerRef);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
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
        color: colorScheme.primaryContainer,
        buttonBackgroundColor: colorScheme.primaryContainer,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 500),
        letIndexChange: (index) {
          if (index < 5) {
            setState(() {
              _currentIndex = index;
              // Show request sheet when taxi item is selected and client has connection
              _showRequestSheet = index == 1 && hasConnection(context);
              _showFavoriteDialog = index == 3;
              _showQuberPointsDialog = index == 4;
            });
            if (_showFavoriteDialog) _showFavoritesDialog();
            if (_showQuberPointsDialog) _showQuberPointsCircularDialog();
            return true;
          }
          return false;
        },
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
            child: _buildNavItem(Icons.settings_outlined, localizations.settingsBottomItem, 2),
          ),
          Transform.scale(
            scale: 1,
            child: _buildNavItem(Icons.favorite_border, localizations.favoritesBottomItem, 3),
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
          // Check if trying to access taxi request with no connection
          if (index == 1 && !hasConnection(context)) {
            _showOfflineModeDialog();
            return;
          }
          // Navigation logic is now handled in letIndexChange
          // This callback is kept for any additional functionality if needed
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String text, int index) {
    const double iconSize = 28;
    final bool isSelected = _currentIndex == index;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: isSelected ? 0.0 : 16.0),
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
    showDialog<FavoriteLocation>(
      context: context,
      builder: (BuildContext context) {
        return const FavoritesDialog();
      },
    ).then((selectedFav) {
      if (selectedFav != null) {
        MapView.globalKey.currentState?.showFavoriteOnMap(selectedFav);
      }
      setState(() => _currentIndex = 0);
    });
  }

  void _showQuberPointsCircularDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CircularInfoDialog(
          largeNumber: _client.quberPoints.toInt().toString(),
          mediumText: AppLocalizations.of(context)!.quberPointsEarned,
          smallText: AppLocalizations.of(context)!.inviteFriendsDescription,
          animateFrom: 0,
          animateTo: _client.quberPoints.toInt(),
          onTapToDismiss: () {
            Navigator.of(context).pop();
            setState(() => _currentIndex = 0);
          },
        );
      },
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _mapViewInstance;
      case 1:
        return _mapViewInstance;
      case 2:
        return const ClientSettingsPage();
      case 3:
        return _mapViewInstance;
      case 4:
        return _mapViewInstance;
      default:
        return const SizedBox.shrink();
    }
  }
}

class FavoritesDialog extends StatefulWidget {
  const FavoritesDialog({super.key});

  @override
  State<FavoritesDialog> createState() => _FavoritesDialogState();
}

class _FavoritesDialogState extends State<FavoritesDialog> {
  List<FavoriteLocation> _favorites = [];
  bool _loadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesPrefsManager.getFavorites();
    setState(() {
      _favorites = favorites;
      _loadingFavorites = false;
    });
  }

  Future<void> _removeFavoriteAt(int index) async {
    await FavoritesPrefsManager.removeFavorite(index);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_loadingFavorites) {
      return const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(localizations.myMarkers,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: _favorites.isEmpty
          ? Text(AppLocalizations.of(context)!.noFavorites)
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final favorite = _favorites[index];
                  return ListTile(
                    leading: Image.asset(
                      'assets/markers/route/x60/pin_fav.png',
                      width: 20,
                      height: 20,
                    ),
                    title: Text(favorite.name),
                    onTap: () {
                      Navigator.pop(context, favorite);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_sharp),
                      onPressed: () async {
                        await _removeFavoriteAt(index);
                      },
                    ),
                  );
                },
              ),
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Theme.of(context).cardTheme.elevation ?? 12.0),
      ),
    );
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
      child: SizedBox(
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
              boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
                      child: RequestTravelSheet(
                        origin: MapView.globalKey.currentState?.origin,
                        destination: MapView.globalKey.currentState?.destination,
                      ),
                    ),
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
