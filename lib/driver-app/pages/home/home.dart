import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/common/services/app_announcement_service.dart';
import 'package:quber_taxi/common/services/driver_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/common/widgets/dialogs/circular_info_dialog.dart';
import 'package:quber_taxi/common/widgets/dialogs/info_dialog.dart';
import 'package:quber_taxi/driver-app/pages/home/available_travels_sheet.dart';
import 'package:quber_taxi/driver-app/pages/home/info_travel_sheet.dart';
import 'package:quber_taxi/driver-app/pages/home/trip_card.dart';
import 'package:quber_taxi/driver-app/pages/home/trip_notification.dart';
import 'package:quber_taxi/enums/driver_account_state.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/storage/session_manger.dart';
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
    : createdAt = travel.requestedDate, // Use requestedDate from backend
      id = travel.requestedDate.millisecondsSinceEpoch.toString();
}

class DriverHomePage extends StatefulWidget {

  final Position? coords;

  const DriverHomePage({super.key, this.coords});

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

  // Driver location streaming
  late final Stream<g.Position> _locationBroadcast;
  StreamSubscription<g.Position>? _locationStreamSubscription;
  StreamSubscription<g.Position>? _locationShareSubscription;
  late Position _coords;
  late Position _lastKnownCoords;
  bool _isLocationStreaming = false;

  // Selected travel. If not null, we should hide the available travel sheet.
  Travel? _selectedTravel;
  final _driverService = DriverService();

  // Handling new travel requests
  late final TravelRequestHandler _newTravelRequestHandler;
  final List<TravelNotification> _newTravels = [];
  final Map<String, Timer> _notificationTimers = {}; // Timers for auto-removing notifications

  // Websocket for travel state changed (Here we must wait for the client to accept the pickup confirmation).
  TravelStateHandler? _travelStateHandler;

  // LoggedIn Driver
  Driver _driver = Driver.fromJson(loggedInUser);
  bool _didCheckAccount = false;
  bool _isAccountEnabled = false;

  // Announcement service
  final _announcementService = AppAnnouncementService();
  bool _didCheckAnnouncements = false;

  // Network Checker
  late void Function() _listener;
  late final NetworkScope _scope;
  
  // Travel info sheet controller
  final DraggableScrollableController _travelInfoSheetController = DraggableScrollableController();

  bool get _shouldShowAvailableTravels => _isAccountEnabled && _selectedTravel == null;

  /// Automatically requests location permission and starts streaming on app startup
  Future<void> _autoRequestLocation() async {
    await g_util.requestLocationPermission(
      context: context,
      onPermissionGranted: () async {
        // Start streaming location automatically
        if (!_isLocationStreaming) _startStreamingLocation();
      },
      onPermissionDenied: () {
        // Permission denied, but don't show error - user can still use the button
        print('Location permission denied on startup');
      },
      onPermissionDeniedForever: () {
        // Permission denied permanently, but don't show error - user can still use the button
        print('Location permission denied permanently on startup');
      }
    );
  }

  void _handleNetworkScopeAndListener() {
    _scope = NetworkScope.of(context); // save the scope (depends on context) to safely access on dispose.
    _listener = _scope.registerListener(_checkDriverAccountStateListener);
    // Check account state immediately when entering the home page
    _checkDriverAccountStateListener(NetworkScope.statusOf(context));
  }

  void _checkDriverAccountStateListener(ConnectionStatus status) async {
    if (!_didCheckAccount) {
      final connectionStatus =  NetworkScope.statusOf(context);
      if(connectionStatus == ConnectionStatus.checking) return;
      final isConnected =  connectionStatus == ConnectionStatus.online;
      if(isConnected) {
        await _checkDriverAccountState();
        _didCheckAccount = true;
        // Check announcements after account state is verified
        await _checkAnnouncements();
      }
      else {
        await _showNoConnectionDialog();
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
      await SessionManager.instance.save(_driver);
      // Show payment reminder (if applies)
      if(_driver.credit > 0.0 && _driver.paymentDate != null) {
      await _showPaymentReminder();
      }
      switch (_driver.accountState) {
        case DriverAccountState.notConfirmed: await _showNeedsConfirmationDialog();
        case DriverAccountState.canPay: setState(() => _isAccountEnabled = true);
        case DriverAccountState.paymentRequired: break;
        case DriverAccountState.enabled: setState(() => _isAccountEnabled = true);
        case DriverAccountState.disabled: break;
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

  Future<void> _showNeedsConfirmationDialog() async {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => InfoDialog(
            title: localizations.needsApproval,
            bodyMessage: localizations.needsApprovalMessage,
            footerMessage: localizations.weWaitForYou
        )
    );
  }

  Future<void> _showPaymentReminder() async {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final paymentDate = _driver.paymentDate!;
    final today = DateTime(now.year, now.month, now.day);
    final paymentDay = DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
    final difference = paymentDay.difference(today).inDays;
    final formattedPaymentDate = DateFormat("dd-MM-yyyy").format(paymentDate);
    final bool isPaymentSoon = difference > 0 && difference <= 3;
    final isSameDay = paymentDate.year == now.year && paymentDate.month == now.month && paymentDate.day == now.day;

    String title;
    String dynamicMessage;

    // ---- Payment Soon ----
    if (isPaymentSoon) {
      String remainingTimeText;
      if (difference == 3) {
        remainingTimeText = localizations.inThreeDays;
      } else if (difference == 2) {
        remainingTimeText = localizations.dayAfterTomorrow;
      }
      else {
        remainingTimeText = localizations.tomorrow;
      }
      title = localizations.paymentSoon;
      dynamicMessage = localizations.paymentReminderSoon(remainingTimeText);

      // ---- Same Day ----
    } else if (isSameDay) {
      title = localizations.paymentPending;
      dynamicMessage = localizations.paymentReminderToday;

      // ---- The Payment Date Has Already Passed ----
    } else if (!today.isBefore(paymentDay)) {
      final daysSince = today.difference(paymentDay).inDays;
      // Before four days
      if (daysSince < 3) {
        int daysLeft = 3 - daysSince;
        String daysText = daysLeft == 1 ? localizations.day : localizations.days;
        dynamicMessage = localizations.paymentOverdue(formattedPaymentDate, daysLeft.toString(), daysText);
        // Last Day
      } else if(daysSince == 3) {
        dynamicMessage = localizations.paymentLastDay(formattedPaymentDate);
      }
      // Deadline Expired
      else {
        dynamicMessage = localizations.paymentExpired(formattedPaymentDate);
      }
      title = localizations.paymentPending;

      // ---- No Condition Applies, We Don't Show Anything ----
    } else {return;}

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => InfoDialog(
        title: title,
        bodyMessage: "$dynamicMessage${localizations.paymentOfficeInfo}",
        footerMessage: localizations.thanksForAttention,
      ),
    );
  }

  void _startStreamingLocation() async {
    // If already streaming, don't create duplicate markers
    if (_isLocationStreaming) return;
    
    // Clear any existing driver markers to prevent duplicates
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
    _locationStreamSubscription?.cancel();
    
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
      final bearing = mb_util.calculateBearing(
          _lastKnownCoords.lat, _lastKnownCoords.lng,
          coords.lat, coords.lng
      );
      final adjustedBearing = (bearing - _mapBearing + 360) % 360;
      _driverAnnotation!.iconRotate = adjustedBearing;
      _driverAnnotation!.geometry = Point(coordinates: coords);
      _pointAnnotationManager?.update(_driverAnnotation!);
    });
    
    _isLocationStreaming = true;
  }

  void _startSharingLocation() {
    _locationShareSubscription = _locationBroadcast.listen((position) async {
      WebSocketService.instance.send(
        "/app/drivers/${_driver.id}/location",
        {"longitude": position.longitude, "latitude": position.latitude},
      );
      if(!_isLocationStreaming) _startStreamingLocation();
    });
  }

  /// Maps municipality names to their corresponding GeoJSON file paths
  String? _getMunicipalityGeoJsonPath(String municipalityName) {
    final Map<String, String> municipalityMap = {
      'Centro Habana': 'assets/geojson/polygon/CentroHabana.geojson',
      'La Habana Vieja': 'assets/geojson/polygon/LaHabanaVieja.geojson',
      'La Lisa': 'assets/geojson/polygon/LaLisa.geojson',
      'Marianao': 'assets/geojson/polygon/Marianao.geojson',
      'Playa': 'assets/geojson/polygon/Playa.geojson',
      'Plaza': 'assets/geojson/polygon/Plaza.geojson',
      'Regla': 'assets/geojson/polygon/Regla.geojson',
      'San Miguel del Padrón': 'assets/geojson/polygon/SanMiguel.geojson',
      'Cotorro': 'assets/geojson/polygon/Cotorro.geojson',
      'Diez de Octubre': 'assets/geojson/polygon/DiezDeOctubre.geojson',
      'El Cerro': 'assets/geojson/polygon/ElCerro.geojson',
      'Guanabacoa': 'assets/geojson/polygon/Guanabacoa.geojson',
      'Habana del Este': 'assets/geojson/polygon/HabanaDelEste.geojson',
      'Arroyo Naranjo': 'assets/geojson/polygon/ArroyoNaranjo.geojson',
      'Boyeros': 'assets/geojson/polygon/Boyeros.geojson',
    };
    
    return municipalityMap[municipalityName];
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
    if(response.statusCode == 200) {
      // Load marker images
      final originAssetBytes = await rootBundle.load('assets/markers/route/x120/origin.png');
      final destinationAssetBytes = await rootBundle.load('assets/markers/route/x120/destination.png');
      final originMarkerImage = originAssetBytes.buffer.asUint8List();
      final destinationMarkerImage = destinationAssetBytes.buffer.asUint8List();
      
      // Create origin marker
      final originCoords = Position(travel.originCoords[0], travel.originCoords[1]);
      await _pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: originCoords),
          image: originMarkerImage,
          iconAnchor: IconAnchor.BOTTOM,
        ),
      );
      
      // Handle destination based on whether it's a point or municipality
      if (travel.destinationCoords != null) {
        // Destination is a specific point - add marker
        final destinationCoords = Position(travel.destinationCoords![0], travel.destinationCoords![1]);
        await _pointAnnotationManager?.create(
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
          0, 0, null, null,
        );
        
        // Animate camera to show both points
        _mapController.easeTo(
          cameraOptions,
          MapAnimationOptions(duration: 1000)
        );
      } else {
        // Destination is a municipality - add polygon
        final municipalityPath = _getMunicipalityGeoJsonPath(travel.destinationName);
        if (municipalityPath != null) {
          try {
            // Load and add municipality polygon
            final municipalityGeoJson = await turf_util.GeoUtils.loadGeoJsonPolygon(municipalityPath);
            
            // Convert polygon to GeoJSON string
            final geoJsonString = jsonEncode(municipalityGeoJson.toJson());
            
            // Add polygon to map
            await _mapController.style.addSource(GeoJsonSource(
              id: "municipality-polygon",
              data: geoJsonString
            ));
            
            await _mapController.style.addLayer(FillLayer(
              id: "municipality-fill",
              sourceId: "municipality-polygon",
              fillColor: Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.5).value,
              fillOutlineColor: Theme.of(context).colorScheme.tertiary.value,
            ));
            
            // Calculate bounds to include origin and municipality
            // Get the polygon coordinates to calculate proper bounds
            final polygonCoords = municipalityGeoJson.coordinates[0]; // First ring of the polygon
            final List<Position> allCoords = [originCoords];
            
            // Add all polygon coordinates to the bounds calculation
            for (final coord in polygonCoords) {
              if(coord[0] != null && coord[1] != null) {
                allCoords.add(Position(coord[0]!, coord[1]!));
              }
            }
            
            final bounds = mb_util.calculateBounds(allCoords);
            
            // Calculate camera options for the bounds
            final cameraOptions = await _mapController.cameraForCoordinateBounds(
              bounds,
              MbxEdgeInsets(top: 50, bottom: 50, left: 50, right: 50),
              0, 0, null, null,
            );
            
            // Animate camera to show origin and municipality
            _mapController.easeTo(
              cameraOptions,
              MapAnimationOptions(duration: 1000)
            );
          } catch (e) {
            print('Error loading municipality polygon: $e');
            // Fallback to just centering on origin
            _mapController.easeTo(
              CameraOptions(center: Point(coordinates: originCoords)),
              MapAnimationOptions(duration: 500)
            );
          }
        } else {
          // Municipality not found, just center on origin
          _mapController.easeTo(
            CameraOptions(center: Point(coordinates: originCoords)),
            MapAnimationOptions(duration: 500)
          );
        }
      }
      
      _startSharingLocation();
      setState(() => _selectedTravel = travel);
    } else {
      if(mounted) {
        showToast(context: context, message: AppLocalizations.of(context)!.noAssignedTrip);
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
                    icon: Icon(Icons.close),
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



  void _onNewTravel(Travel travel) {
    final travelNotification = TravelNotification(travel);

    // Play notification sound
    SystemSound.play(SystemSoundType.alert);

    // Add new notification
    _newTravels.add(travelNotification);
    
    // Sort by requestedDate (most recent first)
    _newTravels.sort((a, b) => b.travel.requestedDate.compareTo(a.travel.requestedDate));
    
    // Keep maximum 2 notifications, remove the oldest ones
    while(_newTravels.length > 2) {
      final removedNotification = _newTravels.removeLast();
      _notificationTimers[removedNotification.id]?.cancel();
      _notificationTimers.remove(removedNotification.id);
    }

    _notificationTimers[travelNotification.id] = Timer(const Duration(seconds: 10), () {
      _removeNotificationById(travelNotification.id);
    });
    
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _newTravelRequestHandler = TravelRequestHandler(
        driverId: _driver.id,
        onNewTravel: _onNewTravel
    )..activate();
    _locationBroadcast = g.Geolocator.getPositionStream().asBroadcastStream();
    _ticker = Ticker(_onTick);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _handleNetworkScopeAndListener();
      // Automatically try to get driver location on startup
      _autoRequestLocation();
    });
  }

  /// Clears the municipality polygon from the map
  Future<void> _clearMunicipalityPolygon() async {
    try {
      await _mapController.style.removeStyleLayer("municipality-fill");
      await _mapController.style.removeStyleSource("municipality-polygon");
    } catch (e) {
      // Layer or source might not exist, ignore error
      print('Error clearing municipality polygon: $e');
    }
  }

  @override
  void dispose() {
    _scope.removeListener(_listener);
    _travelStateHandler?.deactivate();
    _newTravelRequestHandler.deactivate();
    _ticker.dispose();
    _locationShareSubscription?.cancel();
    _locationStreamSubscription?.cancel();
    _pointAnnotationManager?.deleteAll();
    _clearMunicipalityPolygon();
    
    // Cancel all notification timers
    for (final timer in _notificationTimers.values) {
      timer.cancel();
    }
    _notificationTimers.clear();
    
    super.dispose();
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
              styleUri: MapboxStyles.STANDARD,
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
                _driverMarkerImage = assetBytesA.buffer.asUint8List();
                // Add Fake Drivers Animation.
                // FDA is too heavy for the emulator.
                // As it is a requirement of the app, it will be enabled by default.
                // If you are working in this view or any other flow where you need to go through it, you can
                // disable it if you want (you should).
                // To do that set -dart-define=ALLOW_FDA=FALSE.
                // Just care running "flutter build apk" including this flag as FALSE.
                String definedAllowFDA = const String.fromEnvironment("ALLOW_FDA", defaultValue: "TRUE"); // Temporarily disabled to debug marker overlap
                final fdaAllowed = definedAllowFDA == "TRUE";
                if (fdaAllowed) {
                  for (int i = 1; i <= 5; i++) {
                    final fakeRoute = await GeoUtils.loadGeoJsonFakeRoute("assets/geojson/line/fake_route_$i.geojson");
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
                        routeDuration: Duration(milliseconds: (fakeRoute.duration * 1000).round())
                    ));
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
                if(!_isLocationStreaming) return;
                final bearing = mb_util.calculateBearing(
                    _lastKnownCoords.lat, _lastKnownCoords.lng,
                    _coords.lat, _coords.lng
                );
                final adjusted = (bearing - _mapBearing + 360) % 360;
                _driverAnnotation?.iconRotate = adjusted;
                _pointAnnotationManager?.update(_driverAnnotation!);
              }
            ),
            // FAB group - different behavior based on travel selection
            if(_selectedTravel == null) ...[
              // Show all buttons when no travel is selected
              Positioned(
                right: 20.0, bottom: _shouldShowAvailableTravels ? 150.0 : 20.0,
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
                              if(!_isLocationStreaming) _startStreamingLocation();
                              // Ease to current position (Whether the location is being streaming)
                              _mapController.easeTo(
                                  CameraOptions(center: Point(coordinates: _coords)),
                                  MapAnimationOptions(duration: 500)
                              );
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
                            }
                        );
                      },
                      child: Icon(
                          Icons.my_location_outlined,
                          color: Theme.of(context).iconTheme.color,
                          size: Theme.of(context).iconTheme.size
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
                          size: Theme.of(context).iconTheme.size
                      ),
                    ),
                  ]
                )
              )
            ] else ...[
              // Show only location button when travel is selected
              Positioned(
                right: 20.0, bottom: 150.0,
                child: FloatingActionButton(
                  heroTag: "find-my-location-selected",
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  onPressed: () async {
                    // Ask for location permission
                    await g_util.requestLocationPermission(
                        context: context,
                        onPermissionGranted: () async {
                          // Start streaming location
                          if(!_isLocationStreaming) _startStreamingLocation();
                          // Ease to current position (Whether the location is being streaming)
                          _mapController.easeTo(
                              CameraOptions(center: Point(coordinates: _coords)),
                              MapAnimationOptions(duration: 500)
                          );
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
                        }
                    );
                  },
                  child: Icon(
                      Icons.my_location_outlined,
                      color: Theme.of(context).iconTheme.color,
                      size: Theme.of(context).iconTheme.size
                  ),
                )
              )
            ],
            // Notification area
            Positioned(
                top: 32,
                right: 0.0,
                left: 0.0,
                child: Container(
                    margin: EdgeInsets.all(12.0),
                    child: Column(
                        children: List.generate(
                          _newTravels.length > 2 ? 2 : _newTravels.length, 
                          (index) {
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
                                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                                    child: FadeTransition(opacity: animation, child: child)
                                );
                              },
                              child: TripNotification(
                                      key: ValueKey(_newTravels[index].travel.id),
                                      travel: _newTravels[index].travel,
                                index: index,
                                      createdAt: _newTravels[index].createdAt,
                                      onDismissed: () => _removeNotificationById(_newTravels[index].id),
                                      onTap: () => _showTripDetailsDialog(_newTravels[index].travel)
                              )
                                  ),
                                ),
                              ),
                          );
                          }
                        ),
                    )
                )
            ),
            // Available travels sheet
            if(_shouldShowAvailableTravels)
              Align(
                  alignment: Alignment.bottomCenter,
                  child: AvailableTravelsSheet(onTravelSelected: _onTravelSelected)
              ),
            // Travel info sheet when travel is selected
            if(_selectedTravel != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildTravelInfoSheet()
              )
          ]
        )
      )
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.cardBorderRadiusMedium))
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
                        icon: Icon(Icons.keyboard_double_arrow_up)
                      ),
                      const SizedBox(width: 8.0),
                      Text(localizations.tripDescription, style: textTheme.titleMedium)
                    ]
                  )
                )
              )
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
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall)
                                )
                              ),
                            ]
                          ),
                        )
                      ),
                      // Travel Info Sheet Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: TravelInfoSheet(
                            travel: _selectedTravel!,
                            onPickUpConfirmationRequest: () async {
                              // Clear municipality polygon when starting the trip
                              await _clearMunicipalityPolygon();
                              
                              _travelStateHandler = TravelStateHandler(
                                state: TravelState.inProgress,
                                travelId: _selectedTravel!.id,
                                onMessage: (travel) => context.go(DriverRoutes.navigation, extra: travel)
                              )..activate();
                            }
                          ),
                        ),
                      ),
                    ]
                  )
                )
              )
            )
          ]
        );
      }
    );
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
}

/// Represent a fake driver.
class AnimatedFakeDriver {

  /// Fake route coords.
  final List<List<num>> routeCoords;
  /// The corresponding annotation (marker) in the map.
  final PointAnnotation annotation;
  /// The route's duration in milliseconds estimated by Mapbox API.
  final Duration routeDuration;

  // Total segments to be covered.
  late final int _totalSegments;
  // Keep track of a specific animation.
  Duration startOffset = Duration.zero;

  AnimatedFakeDriver({required this.routeCoords, required this.annotation, required this.routeDuration}) {
    _totalSegments = routeCoords.length - 1;
  }

  /// Updates the geometry and orientation of the [AnimatedFakeDriver.annotation].
  void updatePosition(Duration globalElapsed, double mapBearing) {
    // Time a specific animation has been running
    final elapsed = globalElapsed - startOffset;
    // Real progress based in the suggested mapbox route duration
    double progress = elapsed.inMilliseconds / routeDuration.inMilliseconds;
    // Check total progress, if complete, then restart animation to the origin
    if (progress >= 1.0) {
      startOffset = globalElapsed;
      progress = 0.0;
    }
    // Index of the start point of the current segment
    final segmentIndex = (progress * _totalSegments).floor();
    // Avoid index out of bounds exception
    if (segmentIndex >= _totalSegments) return;
    // Use next coords
    final start = routeCoords[segmentIndex];
    final end = routeCoords[segmentIndex + 1];
    // Adjust bearing
    final bearing = mb_util.calculateBearing(start[1], start[0], end[1], end[0]);
    final adjustedBearing = (bearing - mapBearing + 360) % 360;
    // Linear interpolation
    final localT = (progress * _totalSegments) - segmentIndex;
    final lon = _lerp(start[0], end[0], localT);
    final lat = _lerp(start[1], end[1], localT);
    // Update annotation fields
    annotation
      ..geometry = Point(coordinates: Position(lon, lat))
      ..iconRotate = adjustedBearing;
  }

  // Basic linear interpolation.
  static num _lerp(num a, num b, num t) => a + (b - a) * t;
}