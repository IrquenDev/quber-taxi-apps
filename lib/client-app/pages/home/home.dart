import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/client-app/pages/home/request_travel_sheet.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/client-app/pages/settings/account_setting.dart';
import 'package:quber_taxi/common/services/app_announcement_service.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/common/widgets/dialogs/circular_info_dialog.dart';
import 'package:quber_taxi/common/widgets/dialogs/info_dialog.dart';
import 'package:quber_taxi/enums/client_account_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/storage/session_prefs_manger.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:quber_taxi/utils/runtime.dart';

import 'package:quber_taxi/storage/favorites_prefs_manager.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key, this.position});

  final Position? position;

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _currentIndex = 0;
  final _navKey = GlobalKey<CurvedNavigationBarState>();

  bool _showRequestSheet = false;
  bool _showfavoriteDialog = false;
  bool _showQuberPointsDialog = false;

  // Announcement service
  final _announcementService = AppAnnouncementService();
  bool _didCheckAnnouncements = false;

  // Network Checker
  late void Function() _listener;
  late final NetworkScope _scope;

  // Client account state verification
  late Client _client;
  bool _didCheckAccount = false;
  bool _isAccountEnabled = false;

  void _handleNetworkScopeAndListener() {
    _scope = NetworkScope.of(context);
    // We need to register a connection status listener, as it depends on ConnectionStatus being online to execute
    // _checkClientAccountState. If the client is offline (any status other than checking or online), they won't be
    // able to continue.
    _listener = _scope.registerListener(_checkClientAccountStateListener);
    // Since execution times are not always the same, it's possible that when the listener is registered, the current
    // status is already online, so the listener won't be notified. This is why we must make an initial manual call.
    // In any case, calls will not be duplicated since they are being protected with the _didCheckAccount flag.
    _checkClientAccountStateListener(NetworkScope.statusOf(context));
  }

  Future<void> _checkClientAccountStateListener(ConnectionStatus status) async {
    if (!_didCheckAccount) {
      if(status == ConnectionStatus.checking) return;
      final isConnected =  status == ConnectionStatus.online;
      if(isConnected) {
        await _checkClientAccountState();
        _didCheckAccount = true;
        // Check announcements after account state is verified
        await _checkAnnouncements();
      }
      else {
        await _showNoConnectionDialog();
      }
    }
  }

  Future<void> _checkClientAccountState() async {
    // Update client data
    final response = await AccountService().findClient(_client.id);
    // Avoid context's gaps
    if (!mounted) return;
    // Handle OK
    if (response.statusCode == 200) {
      _client = Client.fromJson(jsonDecode(response.body));
      // Always update session
      await SessionPrefsManager.instance.save(_client);
      switch (_client.accountState) {
        case ClientAccountState.blocked: await _showAccountBlockedDialog();
        case ClientAccountState.active: setState(() => _isAccountEnabled = true);
      }
    }
  }

  Future<void> _showNoConnectionDialog() async {
    final localizations = AppLocalizations.of(context)!;
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => InfoDialog(
          title: localizations.noConnection,
          bodyMessage: localizations.noConnectionMessage,
          onAccept: ()=> SystemNavigator.pop(),
        ),
    );
  }

  Future<void> _showAccountBlockedDialog() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => InfoDialog(
            title: "Cuenta Bloqueada",
            bodyMessage: "Su cuenta ha sido bloqueada por mal comportamiento. Póngase en contacto con soporte si cree que esto es incorrecto."
        )
    );
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
      if (kDebugMode) {
        print('Error checking announcements: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize client from logged in user
    _client = Client.fromJson(loggedInUser);
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
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 500),
          letIndexChange: (index) {
            if (index < 5) {
              setState(() {
                _currentIndex = index;
                // Show request sheet when taxi item is selected, but only if account is enabled
                _showRequestSheet = index == 1 && _isAccountEnabled;
                _showfavoriteDialog = index == 3;
                _showQuberPointsDialog = index == 4;
              });

              if (_showfavoriteDialog) _showFavoritesDialog();
              if (_showQuberPointsDialog) _showQuberPointsCircularDialog();

              return true;
            }
            return false;
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
              child: _buildNavItem(
                  Icons.favorite_border, localizations.favoritesBottomItem, 3),
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
            // Check if trying to access taxi request (index 1) with blocked account
            if (index == 1 && !_isAccountEnabled) {
              _showAccountBlockedDialog();
              return;
            }
            // Navigation logic is now handled in letIndexChange
            // This callback is kept for any additional functionality if needed
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String text, int index) {
    final double iconSize = 28;
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
        return FavoritesDialog();
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
        return MapView(key: MapView.globalKey, usingExtendedScaffold: true);
      case 1:
        return MapView(key: MapView.globalKey, usingExtendedScaffold: true);
      case 2:
        return const ClientSettingsPage();
      case 3:
        return MapView(key: MapView.globalKey, usingExtendedScaffold: true);
      case 4:
        return MapView(key: MapView.globalKey, usingExtendedScaffold: true);
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
    final favs = await FavoritesPrefsManager.getFavorites();
    setState(() {
      _favorites = favs;
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
      return AlertDialog(
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
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
        borderRadius:
        BorderRadius.circular(Theme.of(context).cardTheme.elevation ?? 12.0),
      ),
    );
  }
}

class _RequestTravelSheetWidget extends StatefulWidget {
  @override
  State<_RequestTravelSheetWidget> createState() =>
      _RequestTravelSheetWidgetState();
}

class _RequestTravelSheetWidgetState extends State<_RequestTravelSheetWidget>
    with TickerProviderStateMixin {
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
                    child: Padding(
                      padding:
                      EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
                      child: RequestTravelSheet(origin: MapView.globalKey.currentState?.origin, destination: MapView.globalKey.currentState?.destination),
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
