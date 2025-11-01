import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/common/services/driver_service.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/common/widgets/dialogs/circular_info_dialog.dart';
import 'package:quber_taxi/common/widgets/dialogs/info_dialog.dart';
import 'package:quber_taxi/driver-app/pages/home/available_travels_sheet.dart';
import 'package:quber_taxi/driver-app/pages/home/blocked_sheet.dart';
import 'package:quber_taxi/driver-app/pages/home/info_travel_sheet.dart';
import 'package:quber_taxi/driver-app/pages/home/needs_approval_sheet.dart';
import 'package:quber_taxi/driver-app/pages/home/trip_card.dart';
import 'package:quber_taxi/driver-app/pages/home/trip_notification.dart';
import 'package:quber_taxi/enums/driver_account_state.dart';
import 'package:quber_taxi/enums/municipalities.dart';
import 'package:quber_taxi/enums/travel_request_type.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/storage/session_prefs_manger.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/map/geolocator.dart' as g_util;
import 'package:quber_taxi/utils/map/mapbox.dart' as mb_util;
import 'package:quber_taxi/utils/map/turf.dart' as turf_util;
import 'package:quber_taxi/utils/map/turf.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';
import 'package:quber_taxi/utils/websocket/impl/travel_request_handler.dart';
import 'package:quber_taxi/utils/websocket/impl/travel_state_handler.dart';

// Wrapper class to keep travel and its creation timestamp
class TravelNotification {
  final Travel travel;
  final DateTime createdAt;
  final String id;

  TravelNotification(this.travel)
      : createdAt = travel.requestedDate,
        // Use requestedDate from backend
        id = travel.requestedDate.millisecondsSinceEpoch.toString();
}

class DriverHomePage extends StatefulWidget {
  final Position? coords;
  final bool wasRestored;
  final Travel? selectedTravel;

  const DriverHomePage({super.key, this.selectedTravel, this.wasRestored = false, this.coords});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  // Mapbox controller instance
  late MapboxMap _mapController;

  // Global map bearing. Initialized onMapCreated and updated onCameraChangeListener. Needed for calculate bearing
  // and updates driver (real or fakes) annotation markers.
  late double _mapBearing;

  // Fake drivers animation control
  static const _frameInterval = Duration(milliseconds: 100);
  late Ticker _ticker;
  Duration _lastUpdate = Duration.zero;
  late final List<AnimatedFakeDriver> _taxis = [];

  // Point annotation (markers) control
  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotation? _driverAnnotation;
  late final Uint8List _driverMarkerImage;

  // Travel markers references for cleanup
  PointAnnotation? _originMarker;
  PointAnnotation? _destinationMarker;

  // Driver location streaming
  late final Stream<g.Position> _locationBroadcast;
  StreamSubscription<g.Position>? _locationStreamSubscription;
  StreamSubscription<g.Position>? _locationShareSubscription;
  late Position _coords;
  late Position _lastKnownCoords;
  bool _isLocationStreaming = false;
  bool _isStartingLocationStream = false;

  // Selected travel. If not null, we should hide the available travel sheet.
  Travel? _selectedTravel;

  // Http Services
  final _driverService = DriverService();
  final _travelService = TravelService();

  // Handling new travel requests
  TravelRequestHandler? _newTravelRequestHandler;
  final List<TravelNotification> _newTravels = [];
  final Map<String, Timer> _notificationTimers = {}; // Timers for auto-removing notifications

  // Websocket for travel state changed (Here we must wait for the client to accept the pickup confirmation).
  TravelStateHandler? _travelStateHandler;

  // Logged in driver
  Driver _driver = Driver.fromJson(loggedInUser);
  bool _isAccountEnabled = false;
  bool _showNeedsApprovalSheet = false;
  bool _showDriverBlockedSheet = false;

  // Network Checker
  late final NetworkScope _scope;
  late void Function() _checkDriverAccountStateListenerRef;
  late void Function() _checkNewsListenerRef;
  late void Function() _syncTravelStateListenerRef;
  bool _didCheckAccount = false;
  bool _didSyncTravelState = false;

  // Travel info sheet controller
  final DraggableScrollableController _travelInfoSheetController = DraggableScrollableController();

  bool get _shouldShowAvailableTravels => _isAccountEnabled && _selectedTravel == null;

  /// Automatically requests location permission and starts streaming on app startup
  Future<void> _autoRequestLocation() async {
    await g_util.requestLocationPermission(
        context: context,
        onPermissionGranted: () async {
          // Start streaming location automatically
          if (!_isLocationStreaming) await _startStreamingLocation();
        },
        onPermissionDenied: () {
          // Permission denied, but don't show error - user can still use the button
          if (kDebugMode) {
            print('Location permission denied on startup');
          }
        },
        onPermissionDeniedForever: () {
          // Permission denied permanently, but don't show error - user can still use the button
          if (kDebugMode) {
            print('Location permission denied permanently on startup');
          }
        });
  }

  Future<void> _handleNetworkScopeAndListener() async {
    _scope = NetworkScope.of(context);
    final connStatus = NetworkScope.statusOf(context);
    final isAlreadyOnline = connStatus == ConnectionStatus.online;
    // We need to register a connection status listener, as it depends on ConnectionStatus being online to execute
    // _checkClientAccountState. If the client is offline (any status other than checking or online), they won't be
    // able to continue.
    _checkDriverAccountStateListenerRef = _scope.registerListener(_checkDriverAccountStateListener);
    _syncTravelStateListenerRef = _scope.registerListener(_syncTravelStateListener);
    // Since execution times are not always the same, it's possible that when the listeners are registered, the current
    // status is already online, so the listeners won't be notified. This is why we must make an initial manual call.
    // In any case, calls will not be duplicated since they are being protected with an inner flag.
    if (isAlreadyOnline) {
      _checkDriverAccountStateListener(connStatus);
      _syncTravelStateListener(connStatus);
    }
  }

  Future<void> _checkDriverAccountStateListener(ConnectionStatus status) async {
    if (!_didCheckAccount) {
      if (status == ConnectionStatus.checking) return;
      final isConnected = status == ConnectionStatus.online;
      if (isConnected) {
        await _checkDriverAccountState();
        _didCheckAccount = true;
      }
    }
  }

  Future<void> _checkDriverAccountState() async {
    // Update driver data
    final response = await AccountService().findDriver(_driver.id);
    // Avoid context's gaps
    if (!mounted) return;
    // Handle OK
    if (response.statusCode == 200) {
      _driver = Driver.fromJson(jsonDecode(response.body));
      // Always update session
      await SessionPrefsManager.instance.save(_driver);
      // Show payment reminder (if applies)
      // if(_driver.credit > 0.0 && _driver.paymentDate != null) {
      //   await _showPaymentReminder();
      // }
      switch (_driver.accountState) {
        case DriverAccountState.notConfirmed:
          _hideBlockedSheet();
          _showApprovalSheet();
        case DriverAccountState.canPay:
          _hideApprovalSheet();
          _hideBlockedSheet();
          setState(() => _isAccountEnabled = true);
        case DriverAccountState.paymentRequired:
          _hideApprovalSheet();
          _hideBlockedSheet();
          break;
        case DriverAccountState.enabled:
          _hideApprovalSheet();
          _hideBlockedSheet();
          setState(() => _isAccountEnabled = true);
        case DriverAccountState.disabled:
          _hideApprovalSheet();
          _showBlockedSheet();
          break;
        case DriverAccountState.suspended:
          _hideApprovalSheet();
          _showBlockedSheet();
          break;
      }
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
    if (_didSyncTravelState) {
      return;
    }
    final response = await _travelService.getActiveTravelStateForDriver(_driver.id);
    if (!mounted) return;
    //Ignoring 404 (means no active travel) and unexpected status codes.
    if (response.statusCode == 200) {
      final activeTravel = Travel.fromJson(jsonDecode(response.body));
      // A trip is considered active if its status is ACCEPTED or IN_PROGRESS. So we are only going to handle
      // those states.
      final travelState = activeTravel.state;
      if (travelState == TravelState.accepted) {
        await _startSelectedTravelMode(activeTravel);
      }
      // TravelState.inProgress
      else {
        context.go(DriverRoutes.navigation, extra: {
          'travel': activeTravel,
          'wasPageRestored': true,
        });
      }
    }
    _didSyncTravelState = true;
  }

  // Future<void> _showNoConnectionDialog() async {
  //   final localizations = AppLocalizations.of(context)!;
  //   return await showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => InfoDialog(
  //         title: localizations.noConnection,
  //         bodyMessage: localizations.noConnectionMessage,
  //         onAccept: ()=> SystemNavigator.pop(),
  //       ),
  //   );
  // }

  void _disableNewTravelNotifications() {
    _newTravelRequestHandler?.deactivate();
    _clearAllNotifications();
  }

  void _showApprovalSheet() {
    // Deactivate travel request handler and clear notifications when not approved
    _disableNewTravelNotifications();
    setState(() {
      _showNeedsApprovalSheet = true;
    });
  }

  void _hideApprovalSheet() {
    setState(() {
      _showNeedsApprovalSheet = false;
    });
    // Reactivate travel request handler when account becomes enabled
    if (_isAccountEnabled && _selectedTravel == null) {
      _newTravelRequestHandler = TravelRequestHandler(driverId: _driver.id, onNewTravel: _onNewTravel)..activate();
    }
  }

  void _showBlockedSheet() {
    // Deactivate travel request handler and clear notifications when blocked
    _disableNewTravelNotifications();
    setState(() {
      _showDriverBlockedSheet = true;
    });
  }

  void _hideBlockedSheet() {
    setState(() {
      _showDriverBlockedSheet = false;
    });
    // Reactivate travel request handler when account becomes enabled
    if (_isAccountEnabled && _selectedTravel == null) {
      _newTravelRequestHandler = TravelRequestHandler(driverId: _driver.id, onNewTravel: _onNewTravel)..activate();
    }
  }

  void _clearAllNotifications() {
    // Cancel all timers
    for (final timer in _notificationTimers.values) {
      timer.cancel();
    }
    _notificationTimers.clear();
    // Clear notifications list
    _newTravels.clear();
  }

  // Future<void> _showPaymentReminder() async {
  //   final localizations = AppLocalizations.of(context)!;
  //   final now = DateTime.now();
  //   final paymentDate = _driver.paymentDate!;
  //   final today = DateTime(now.year, now.month, now.day);
  //   final paymentDay = DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
  //   final difference = paymentDay.difference(today).inDays;
  //   final formattedPaymentDate = DateFormat("dd-MM-yyyy").format(paymentDate);
  //   final bool isPaymentSoon = difference > 0 && difference <= 3;
  //   final isSameDay = paymentDate.year == now.year && paymentDate.month == now.month && paymentDate.day == now.day;
  //
  //   String title;
  //   String dynamicMessage;
  //
  //   // ---- Payment Soon ----
  //   if (isPaymentSoon) {
  //     String remainingTimeText;
  //     if (difference == 3) {
  //       remainingTimeText = localizations.inThreeDays;
  //     } else if (difference == 2) {
  //       remainingTimeText = localizations.dayAfterTomorrow;
  //     }
  //     else {
  //       remainingTimeText = localizations.tomorrow;
  //     }
  //     title = localizations.paymentSoon;
  //     dynamicMessage = localizations.paymentReminderSoon(remainingTimeText);
  //
  //     // ---- Same Day ----
  //   } else if (isSameDay) {
  //     title = localizations.paymentPending;
  //     dynamicMessage = localizations.paymentReminderToday;
  //
  //     // ---- The Payment Date Has Already Passed ----
  //   } else if (!today.isBefore(paymentDay)) {
  //     final daysSince = today.difference(paymentDay).inDays;
  //     // Before four days
  //     if (daysSince < 3) {
  //       int daysLeft = 3 - daysSince;
  //       String daysText = daysLeft == 1 ? localizations.day : localizations.days;
  //       dynamicMessage = localizations.paymentOverdue(formattedPaymentDate, daysLeft.toString(), daysText);
  //       // Last Day
  //     } else if(daysSince == 3) {
  //       dynamicMessage = localizations.paymentLastDay(formattedPaymentDate);
  //     }
  //     // Deadline Expired
  //     else {
  //       dynamicMessage = localizations.paymentExpired(formattedPaymentDate);
  //     }
  //     title = localizations.paymentPending;
  //
  //     // ---- No Condition Applies, We Don't Show Anything ----
  //   } else {return;}
  //
  //   await showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => InfoDialog(
  //       title: title,
  //       bodyMessage: "$dynamicMessage${localizations.paymentOfficeInfo}",
  //       footerMessage: localizations.thanksForAttention,
  //     ),
  //   );
  // }

  Future<void> _startStreamingLocation() async {
    // Prevent concurrent starts that can create duplicate markers
    if (_isLocationStreaming || _isStartingLocationStream) return;
    _isStartingLocationStream = true;
    try {
      // Clear any existing driver marker reference to prevent duplicates
      if (_driverAnnotation != null) {
        await _pointAnnotationManager?.delete(_driverAnnotation!);
        _driverAnnotation = null;
      }
      // Get current position
      final position = await g.Geolocator.getCurrentPosition();
      final coords = Position(position.longitude, position.latitude);
      // Update class's field coord references
      _coords = coords;
      _lastKnownCoords = coords;
      // Cancel existing subscription to avoid duplicates
      await _locationStreamSubscription?.cancel();
      // Only create marker if we don't have one yet
      if (_driverAnnotation == null) {
        // Add driver marker to map
        _driverAnnotation = await _pointAnnotationManager?.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: coords),
            image: _driverMarkerImage,
            iconAnchor: IconAnchor.CENTER,
          ),
        );
      } else {
        // Update existing marker position
        _driverAnnotation!.geometry = Point(coordinates: coords);
        _pointAnnotationManager?.update(_driverAnnotation!);
      }
      // Listen for real location updates
      _locationStreamSubscription = _locationBroadcast.listen((position) async {
        // Update coords
        final coords = Position(position.longitude, position.latitude);
        _lastKnownCoords = _coords;
        _coords = coords;
        // Adjust bearing
        final bearing = mb_util.calculateBearing(_lastKnownCoords.lat, _lastKnownCoords.lng, coords.lat, coords.lng);
        final adjustedBearing = (bearing - _mapBearing + 360) % 360;
        _driverAnnotation!.iconRotate = adjustedBearing;
        _driverAnnotation!.geometry = Point(coordinates: coords);
        _pointAnnotationManager?.update(_driverAnnotation!);
      });
      _isLocationStreaming = true;
    } finally {
      _isStartingLocationStream = false;
    }
  }

  void _startSharingLocation() {
    _locationShareSubscription = _locationBroadcast.listen((position) async {
      WebSocketService.instance.send(
        "/app/drivers/${_driver.id}/location",
        {"longitude": position.longitude, "latitude": position.latitude},
      );
      if (!_isLocationStreaming) await _startStreamingLocation();
    });
  }

  Future<void> _startSelectedTravelMode(Travel travel) async {
    await _updateMapUiWithSelectedTravel(travel);
    _startSharingLocation();
    _disableNewTravelNotifications();
    setState(() => _selectedTravel = travel);
  }

  void _onTravelSelected(Travel travel) async {
    final localizations = AppLocalizations.of(context)!;
    // Check if driver has location before accepting travel
    if (!_isLocationStreaming) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations.locationNotFoundTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(localizations.locationNotFoundMessage),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        Icons.my_location_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 24.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(localizations.locationNotFoundHint),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.locationNotFoundButton),
              ),
            ],
          ),
        );
      }
      return;
    }
    final response = await _driverService.acceptTravel(driverId: _driver.id, travelId: travel.id);
    if (!mounted) return;
    if (response.statusCode == 200) {
      await _startSelectedTravelMode(travel);
    } else if (response.statusCode == 403) {
      showToast(context: context, message: "Permiso denegado, su cuenta está deshabilitada.");
    } else if (response.statusCode == 409) {
      showToast(context: context, message: "Viaje activo existente, solo puedes aceptar uno a la vez.");
    } else if (response.statusCode == 423) {
      showToast(context: context, message: "Crédito insuficiente");
    }
     else {
      showToast(context: context, message: AppLocalizations.of(context)!.noAssignedTrip);
    }
  }

  Future<void> _updateMapUiWithSelectedTravel(Travel travel) async {
    final colorScheme = Theme.of(context).colorScheme;
    // Load marker images
    final originAssetBytes = await rootBundle.load('assets/markers/route/x120/origin.png');
    final destinationAssetBytes = await rootBundle.load('assets/markers/route/x120/destination.png');
    final originMarkerImage = originAssetBytes.buffer.asUint8List();
    final destinationMarkerImage = destinationAssetBytes.buffer.asUint8List();
    // Create origin marker
    final originCoords = Position(travel.originCoords[0], travel.originCoords[1]);
    // Handle destination based on whether it's a point or municipality
    _originMarker = await _pointAnnotationManager?.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: originCoords),
        image: originMarkerImage,
        iconAnchor: IconAnchor.BOTTOM,
      ),
    );
    if (travel.destinationCoords != null) {
      // Destination is a specific point - add marker
      final destinationCoords = Position(travel.destinationCoords![0], travel.destinationCoords![1]);
      _destinationMarker = await _pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: destinationCoords),
          image: destinationMarkerImage,
          iconAnchor: IconAnchor.BOTTOM,
        ),
      );
      // Calculate bounds to include both origin and destination points
      final bounds = mb_util.calculateBounds([originCoords, destinationCoords]);
      // Calculate camera options for the bounds
      final cameraOptions = await _mapController.cameraForCoordinateBounds(
        bounds,
        MbxEdgeInsets(top: 50, bottom: 50, left: 50, right: 50),
        0,
        0,
        null,
        null,
      );
      // Animate camera to show both points
      _mapController.easeTo(cameraOptions, MapAnimationOptions(duration: 1000));
    } else {
      // Destination is a municipality - add polygon
      final municipalityPath = Municipalities.resolveGeoJsonRef(travel.destinationName);
      if (municipalityPath != null) {
        try {
          // Load and add municipality polygon
          final municipalityGeoJson = await turf_util.GeoUtils.loadGeoJsonPolygon(municipalityPath);
          // Convert polygon to GeoJSON string
          final geoJsonString = jsonEncode(municipalityGeoJson.toJson());
          // Add polygon to map
          await _mapController.style.addSource(GeoJsonSource(id: "municipality-polygon", data: geoJsonString));
          await _mapController.style.addLayer(FillLayer(
            id: "municipality-fill",
            sourceId: "municipality-polygon",
            fillColor: colorScheme.onTertiaryContainer.withValues(alpha: 0.5).toARGB32(),
            fillOutlineColor: colorScheme.tertiary.toARGB32(),
          ));
          // Calculate bounds to include origin and municipality
          // Get the polygon coordinates to calculate proper bounds
          final polygonCoords = municipalityGeoJson.coordinates[0]; // First ring of the polygon
          final List<Position> allCoords = [originCoords];
          // Add all polygon coordinates to the bounds calculation
          for (final coord in polygonCoords) {
            if (coord[0] != null && coord[1] != null) {
              allCoords.add(Position(coord[0]!, coord[1]!));
            }
          }
          final bounds = mb_util.calculateBounds(allCoords);
          // Calculate camera options for the bounds
          final cameraOptions = await _mapController.cameraForCoordinateBounds(
            bounds,
            MbxEdgeInsets(top: 50, bottom: 50, left: 50, right: 50),
            0,
            0,
            null,
            null,
          );
          // Animate camera to show origin and municipality
          _mapController.easeTo(cameraOptions, MapAnimationOptions(duration: 1000));
        } catch (e) {
          if (kDebugMode) {
            print('Error loading municipality polygon: $e');
          }
          // Fallback to just centering on origin
          _mapController.easeTo(
              CameraOptions(center: Point(coordinates: originCoords)), MapAnimationOptions(duration: 500));
        }
      } else {
        // Municipality not found, just center on origin
        _mapController.easeTo(
            CameraOptions(center: Point(coordinates: originCoords)), MapAnimationOptions(duration: 500));
      }
    }
  }

  void _onTick(Duration elapsed) async {
    if (elapsed - _lastUpdate < _frameInterval) return;
    _lastUpdate = elapsed;
    for (final taxi in _taxis) {
      taxi.updatePosition(elapsed, _mapBearing);
      _pointAnnotationManager?.update(taxi.annotation);
    }
  }

  void _onNewTravel(Travel travel) {
    final travelNotification = TravelNotification(travel);

    // Play notification sound
    SystemSound.play(SystemSoundType.alert);

    // Add new notification
    _newTravels.add(travelNotification);

    // Sort by requestedDate (most recent first)
    _newTravels.sort((a, b) => b.travel.requestedDate.compareTo(a.travel.requestedDate));

    // Keep maximum 2 notifications, remove the oldest ones
    while (_newTravels.length > 2) {
      final removedNotification = _newTravels.removeLast();
      _notificationTimers[removedNotification.id]?.cancel();
      _notificationTimers.remove(removedNotification.id);
    }

    _notificationTimers[travelNotification.id] = Timer(const Duration(seconds: 10), () {
      _removeNotificationById(travelNotification.id);
    });

    setState(() {});
  }

  void _removeNotificationById(String notificationId) {
    _notificationTimers[notificationId]?.cancel();
    _notificationTimers.remove(notificationId);

    _newTravels.removeWhere((notification) => notification.id == notificationId);
    setState(() {});
  }

  void _showTripDetailsDialog(Travel travel) {
    final localizations = AppLocalizations.of(context)!;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.tripDescription,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 24.0,
                  ),
                ],
              ),
            ),
            // Trip card content
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
              child: TripCard(
                travel: travel,
                onTravelSelected: (selectedTravel) {
                  Navigator.of(context).pop(); // Close dialog first
                  _onTravelSelected(selectedTravel); // Then handle travel selection
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToNavigationPage(Travel travel) async {
    // Clear municipality polygon when starting the trip
    await _clearMunicipalityPolygon();
    if (!mounted) return;
    context.go(DriverRoutes.navigation, extra: {"travel": travel, "wasPageRestored": false});
  }

  void _showDriverCreditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CircularInfoDialog(
          largeNumber: _driver.credit.toInt().toString(),
          mediumText: AppLocalizations.of(context)!.driverCredit,
          smallText: AppLocalizations.of(context)!.driverCreditDescription,
          animateFrom: 0,
          animateTo: _driver.credit.toInt(),
          onTapToDismiss: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  /// Clears the municipality polygon from the map
  Future<void> _clearMunicipalityPolygon() async {
    try {
      await _mapController.style.removeStyleLayer("municipality-fill");
      await _mapController.style.removeStyleSource("municipality-polygon");
    } catch (e) {
      // Layer or source might not exist, ignore error
      if (kDebugMode) {
        print('Error clearing municipality polygon: $e');
      }
    }
  }

  /// Restores the app to its initial state when a travel is cancelled
  /// This method cleans up all travel-related UI elements and resets the state
  Future<void> _restoreToInitialState() async {
    // Clear travel markers from map
    if (_originMarker != null && _pointAnnotationManager != null) {
      await _pointAnnotationManager!.delete(_originMarker!);
      _originMarker = null;
    }
    if (_destinationMarker != null && _pointAnnotationManager != null) {
      await _pointAnnotationManager!.delete(_destinationMarker!);
      _destinationMarker = null;
    }
    // Clear municipality polygon if exists
    await _clearMunicipalityPolygon();
    // Stop sharing location coordinates
    await _locationShareSubscription?.cancel();
    _locationShareSubscription = null;
    // Deactivate travel state handler
    _travelStateHandler?.deactivate();
    _travelStateHandler = null;
    // Reset travel info sheet to initial size
    if (_travelInfoSheetController.isAttached) {
      _travelInfoSheetController.jumpTo(0.15);
    }
  }

  @override
  void initState() {
    super.initState();
    // Init location streaming
    _locationBroadcast = g.Geolocator.getPositionStream().asBroadcastStream();
    // Ticker controller for fake driver animations
    _ticker = Ticker(_onTick);
    // Subscribe to new travel requests
    _newTravelRequestHandler = TravelRequestHandler(driverId: _driver.id, onNewTravel: _onNewTravel)..activate();
    // Register context-based initializer
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Request and subscribe to location streaming
      await _autoRequestLocation();
      // Handle driver account state
      await _handleNetworkScopeAndListener();
    });
  }

  @override
  void dispose() {
    _scope.removeListener(_checkDriverAccountStateListenerRef);
    _scope.removeListener(_checkNewsListenerRef);
    _scope.removeListener(_syncTravelStateListenerRef);
    _travelStateHandler?.deactivate();
    _disableNewTravelNotifications();
    _ticker.dispose();
    _locationShareSubscription?.cancel();
    _locationStreamSubscription?.cancel();
    _pointAnnotationManager?.deleteAll();
    _clearMunicipalityPolygon();
    // Clear travel marker references
    _originMarker = null;
    _destinationMarker = null;
    // Cancel all notification timers
    for (final timer in _notificationTimers.values) {
      timer.cancel();
    }
    _notificationTimers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraOptions = CameraOptions(
      center: Point(coordinates: widget.coords ?? Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status, useTopSafeArea: true),
      alertPosition: Alignment.topCenter,
      child: Material(
        child: Stack(
          children: [
            // Map view
            MapWidget(
                cameraOptions: cameraOptions,
                onMapCreated: (controller) async {
                  // Init class's field references
                  _mapController = controller;
                  _mapBearing = await _mapController.getCameraState().then((c) => c.bearing);
                  // Update some mapbox component
                  await controller.location.updateSettings(LocationComponentSettings(enabled: false));
                  await controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
                  // Disable pitch/tilt gestures to keep map flat
                  await controller.gestures.updateSettings(GesturesSettings(pitchEnabled: false));
                  // Create PAM
                  _pointAnnotationManager = await controller.annotations.createPointAnnotationManager();
                  // Load Taxi Marker
                  final assetBytesA = await rootBundle.load('assets/markers/taxi/taxi_pin_x172.png');
                  final assetBytesB = await rootBundle.load('assets/markers/taxi/pin_mototaxix172.png');
                  final iconA = assetBytesA.buffer.asUint8List();
                  final iconB = assetBytesB.buffer.asUint8List();
                  // Driver's own marker should use taxi_hdpi
                  final driverAssetBytes = await rootBundle.load('assets/markers/taxi/taxi_hdpi.png');
                  _driverMarkerImage = driverAssetBytes.buffer.asUint8List();
                  // Add Fake Drivers Animation.
                  // FDA is too heavy for the emulator.
                  // As it is a requirement of the app, it will be enabled by default.
                  // If you are working in this view or any other flow where you need to go through it, you can
                  // disable it if you want (you should).
                  // To do that set -dart-define=ALLOW_FDA=FALSE.
                  // Just care running "flutter build apk" including this flag as FALSE.
                  String definedAllowFDA = const String.fromEnvironment("ALLOW_FDA",
                      defaultValue: "TRUE"); // Temporarily disabled to debug marker overlap
                  final fdaAllowed = definedAllowFDA == "TRUE";
                  if (fdaAllowed) {
                    for (int i = 1; i <= 5; i++) {
                      final fakeRoute =
                          await GeoUtils.loadGeoJsonFakeRoute("assets/geojson/line/fake_route_$i.geojson");
                      final origin = fakeRoute.coordinates.first;

                      final imageToUse = (i % 2 == 0) ? iconA : iconB;

                      final annotation = await _pointAnnotationManager?.create(
                        PointAnnotationOptions(
                          geometry: Point(coordinates: Position(origin[0], origin[1])),
                          image: imageToUse,
                          iconAnchor: IconAnchor.CENTER,
                        ),
                      );

                      _taxis.add(AnimatedFakeDriver(
                          routeCoords: fakeRoute.coordinates,
                          annotation: annotation!,
                          routeDuration: Duration(milliseconds: (fakeRoute.duration * 1000).round())));
                    }
                    _ticker.start();
                  }
                },
                onCameraChangeListener: (cameraData) async {
                  // Always update bearing 'cause fake drivers animation depends on it
                  _mapBearing = cameraData.cameraState.bearing;
                  // Return if the driver location is not being streaming. Otherwise we need to re-calculate bearing for
                  // the real driver marker. It is possible for this metric to change without significantly changing the
                  // driver location.
                  if (!_isLocationStreaming) return;
                  final bearing =
                      mb_util.calculateBearing(_lastKnownCoords.lat, _lastKnownCoords.lng, _coords.lat, _coords.lng);
                  final adjusted = (bearing - _mapBearing + 360) % 360;
                  _driverAnnotation?.iconRotate = adjusted;
                  _pointAnnotationManager?.update(_driverAnnotation!);
                }),
            // FAB group - different behavior based on travel selection
            if (_selectedTravel == null) ...[
              // Show all buttons when no travel is selected
              Positioned(
                right: 20.0,
                bottom: _shouldShowAvailableTravels ? 150.0 : 20.0,
                child: Column(
                  spacing: 8.0,
                  children: [
                    // Driver credit
                    FloatingActionButton(
                      heroTag: "driver-credit",
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      onPressed: () {
                        _showDriverCreditDialog();
                      },
                      child: Text(
                        _driver.credit.toInt().toString(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                    // Find my location
                    FloatingActionButton(
                      heroTag: "find-my-location",
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      onPressed: () async {
                        // Ask for location permission
                        await g_util.requestLocationPermission(
                            context: context,
                            onPermissionGranted: () async {
                              // Start streaming location
                              if (!_isLocationStreaming) await _startStreamingLocation();
                              // If still not streaming (e.g., error getting position), do nothing
                              if (!_isLocationStreaming) return;
                              // Ease to current position (Whether the location is being streaming)
                              _mapController.easeTo(CameraOptions(center: Point(coordinates: _coords)),
                                  MapAnimationOptions(duration: 500));
                            },
                            onPermissionDenied: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.permissionsDenied)),
                              );
                            },
                            onPermissionDeniedForever: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.permissionDeniedPermanently)),
                              );
                            });
                      },
                      child: Icon(
                        Icons.my_location_outlined,
                        color: Theme.of(context).iconTheme.color,
                        size: Theme.of(context).iconTheme.size,
                      ),
                    ),
                    // Settings button
                    FloatingActionButton(
                      heroTag: "go-settings",
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      onPressed: () async {
                        context.push(DriverRoutes.settings);
                      },
                      child: Icon(
                        Icons.settings_outlined,
                        color: Theme.of(context).iconTheme.color,
                        size: Theme.of(context).iconTheme.size,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show only location button when travel is selected
              Positioned(
                right: 20.0,
                bottom: 150.0,
                child: FloatingActionButton(
                  heroTag: "find-my-location-selected",
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  onPressed: () async {
                    // Ask for location permission
                    await g_util.requestLocationPermission(
                        context: context,
                        onPermissionGranted: () async {
                          // Start streaming location
                          if (!_isLocationStreaming) await _startStreamingLocation();
                          // If still not streaming (e.g., error getting position), do nothing
                          if (!_isLocationStreaming) return;
                          // Ease to current position (Whether the location is being streaming)
                          _mapController.easeTo(
                              CameraOptions(center: Point(coordinates: _coords)), MapAnimationOptions(duration: 500));
                        },
                        onPermissionDenied: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.permissionsDenied)),
                          );
                        },
                        onPermissionDeniedForever: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.permissionDeniedPermanently)),
                          );
                        });
                  },
                  child: Icon(
                    Icons.my_location_outlined,
                    color: Theme.of(context).iconTheme.color,
                    size: Theme.of(context).iconTheme.size,
                  ),
                ),
              ),
            ],
            // Notification area - only show when account is enabled
            if (_isAccountEnabled)
              Positioned(
                top: 32,
                right: 0.0,
                left: 0.0,
                child: Container(
                  margin: const EdgeInsets.all(12.0),
                  child: Column(
                    children: List.generate(_newTravels.length > 2 ? 2 : _newTravels.length, (index) {
                      final isSecondary = index == 1;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(
                          left: isSecondary ? 8.0 : 0.0,
                          right: isSecondary ? 8.0 : 0.0,
                          top: index == 0 ? 0.0 : 4.0,
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isSecondary ? 0.9 : 1.0,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 300),
                            scale: isSecondary ? 0.9 : 1.0,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              switchInCurve: Curves.easeInOut,
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                  position:
                                      Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                                  child: FadeTransition(opacity: animation, child: child),
                                );
                              },
                              child: TripNotification(
                                key: ValueKey(_newTravels[index].travel.id),
                                travel: _newTravels[index].travel,
                                index: index,
                                createdAt: _newTravels[index].createdAt,
                                onDismissed: () => _removeNotificationById(_newTravels[index].id),
                                onTap: () => _showTripDetailsDialog(_newTravels[index].travel),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            // Available travels sheet
            if (_shouldShowAvailableTravels)
              Align(
                  alignment: Alignment.bottomCenter, child: AvailableTravelsSheet(onTravelSelected: _onTravelSelected)),
            // Travel info sheet when travel is selected
            if (_selectedTravel != null) Align(alignment: Alignment.bottomCenter, child: _buildTravelInfoSheet()),
            // Needs approval sheet
            if (_showNeedsApprovalSheet)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: NeedsApprovalSheet(),
              ),
            // Blocked sheet
            if (_showDriverBlockedSheet)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BlockedSheet(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelInfoSheet() {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      controller: _travelInfoSheetController,
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.7,
      expand: false,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return Stack(
          children: [
            // Background Container With Header
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(dimensions.cardBorderRadiusMedium),
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            if (!_travelInfoSheetController.isAttached) return;
                            _travelInfoSheetController.jumpTo(0.9);
                          },
                          icon: const Icon(Icons.keyboard_double_arrow_up)),
                      const SizedBox(width: 8.0),
                      Text(localizations.tripDescription, style: textTheme.titleMedium)
                    ],
                  ),
                ),
              ),
            ),
            // Main Container with Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 56.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.cardBorderRadiusLarge)),
                  ),
                  child: Column(
                    children: [
                      // Drag Handler
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onVerticalDragUpdate: (details) {
                          if (!_travelInfoSheetController.isAttached) return;
                          final screenHeight = MediaQuery.of(context).size.height;
                          final dragAmount = -details.primaryDelta! / screenHeight;
                          final currentSize = _travelInfoSheetController.size;
                          final newSize = (currentSize + dragAmount).clamp(0.15, 0.9);
                          _travelInfoSheetController.jumpTo(newSize);
                        },
                        child: SizedBox(
                          height: 48.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurfaceVariant.withAlpha(100),
                                  borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Travel Info Sheet Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: TravelInfoSheet(
                            onReportClient: () async {
                              // Restore app to initial state - clean up all travel-related UI and state
                              await _restoreToInitialState();
                              // Re-activate new travel request ws handler, in order to receive notification.
                              _newTravelRequestHandler =
                                  TravelRequestHandler(driverId: _driver.id, onNewTravel: _onNewTravel)..activate();
                              if (!context.mounted) return;
                              showToast(context: context, message: "Reporte enviado correctamente");
                              setState(() {
                                _selectedTravel = null;
                              });
                            },
                            travel: _selectedTravel!,
                            onPickUpConfirmationRequest: () async {
                              // Behavior for travel requested normally, needs pick up confirmation through ws
                              if (_selectedTravel!.requestType == TravelRequestType.online) {
                                // Check connection (web socket depends on it)
                                if (hasConnection(context)) {
                                  // Notify driver about pickup confirmation flow
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => InfoDialog(
                                      title: AppLocalizations.of(context)!.pickupConfirmationSentTitle,
                                      bodyMessage: AppLocalizations.of(context)!.pickupConfirmationInfo,
                                      onAccept: () {
                                        // Send pick up confirmation
                                        WebSocketService.instance.send(
                                            "/app/travels/${_selectedTravel!.id}/pick-up-confirmation",
                                            null // no body needed
                                            );
                                        // Only subscribes once
                                        _travelStateHandler = TravelStateHandler(
                                            state: TravelState.inProgress,
                                            travelId: _selectedTravel!.id,
                                            onMessage: _goToNavigationPage)
                                          ..activate();
                                      },
                                    ),
                                  );
                                } else {
                                  showToast(context: context, message: "Revise su conexión a internet");
                                }
                              }
                              // If client if offline, we don't wait for pick up confirmation
                              else {
                                _goToNavigationPage(_selectedTravel!);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
