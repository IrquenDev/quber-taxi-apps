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
import 'package:quber_taxi/common/services/driver_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/common/widgets/dialogs/info_dialog.dart';
import 'package:quber_taxi/driver-app/pages/home/available_travels_sheet.dart';
import 'package:quber_taxi/driver-app/pages/home/info_travel_sheet.dart';
import 'package:quber_taxi/driver-app/pages/home/trip_notification.dart';
import 'package:quber_taxi/enums/driver_account_state.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/storage/session_manger.dart';
import 'package:quber_taxi/utils/map/geolocator.dart' as g_util;
import 'package:quber_taxi/utils/map/mapbox.dart' as mb_util;
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';
import 'package:quber_taxi/utils/websocket/impl/travel_request_handler.dart';
import 'package:quber_taxi/utils/websocket/impl/travel_state_handler.dart';

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
  final List<Travel> _newTravels = [];

  // Websocket for travel state changed (Here we must wait for the client to accept the pickup confirmation).
  TravelStateHandler? _travelStateHandler;

  // LoggedIn Driver
  Driver _driver = Driver.fromJson(loggedInUser);
  bool _didCheckAccount = false;
  bool _isAccountEnabled = false;

  // Network Checker
  late void Function() _listener;
  late final NetworkScope _scope;

  bool get _shouldShowAvailableTravels => _isAccountEnabled && _selectedTravel == null;

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
    
    // Get current position
    final position = await g.Geolocator.getCurrentPosition();
    final coords = Position(position.longitude, position.latitude);
    // Update class's field coord references
    _coords = coords;
    _lastKnownCoords = coords;
    
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
    
    // Cancel existing subscription to avoid duplicates
    _locationStreamSubscription?.cancel();
    
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

  void _onTravelSelected(Travel travel) async {
    final response = await _driverService.acceptTravel(driverId: _driver.id, travelId: travel.id);
    if(response.statusCode == 200) {
      final assetBytes = await rootBundle.load('assets/markers/route/x120/origin.png');
      final originMarkerImage = assetBytes.buffer.asUint8List();
      final originCoords = Position(travel.originCoords[0], travel.originCoords[1]);
      await _pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: originCoords),
          image: originMarkerImage,
          iconAnchor: IconAnchor.BOTTOM,
        ),
      );
      _mapController.easeTo(
          CameraOptions(center: Point(coordinates: originCoords)),
          MapAnimationOptions(duration: 500)
      );
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

  void _onNewTravel(Travel travel) {
    if(_newTravels.isEmpty || _newTravels.length < 2) {
      _newTravels.add(travel);
    }
    else {
      _newTravels.removeLast();
      _newTravels.insert(0, travel);
    }
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
    });
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
                String definedAllowFDA = const String.fromEnvironment("ALLOW_FDA", defaultValue: "FALSE"); // Temporarily disabled to debug marker overlap
                final fdaAllowed = definedAllowFDA == "TRUE";
                if (fdaAllowed) {
                  for (int i = 1; i <= 5; i++) {
                    final fakeRoute = await mb_util.loadGeoJsonFakeRoute("assets/geojson/line/fake_route_$i.geojson");
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
            // FAB group (my location + travel info)
            Positioned(
              right: 20.0, bottom: _shouldShowAvailableTravels ? 150.0 : 20.0,
              child: Column(
                spacing: 8.0,
                children: [
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
                  // Find my location
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
                  // Show travel info bottom sheet
                  if(_selectedTravel != null)
                    FloatingActionButton(
                        heroTag: "show-travel-info",
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        onPressed: () => showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            builder: (sheetContext) => TravelInfoSheet(
                              travel: _selectedTravel!,
                              onPickUpConfirmationRequest: () {
                                  _travelStateHandler = TravelStateHandler(
                                      state: TravelState.inProgress,
                                      travelId: _selectedTravel!.id,
                                      onMessage: (travel) => sheetContext.go(DriverRoutes.navigation, extra:
                                      travel)
                                  )..activate();
                              }
                            )
                        ),
                        child: Icon(
                            Icons.info_outline,
                            color: Theme.of(context).iconTheme.color,
                            size: Theme.of(context).iconTheme.size
                        )
                    )
                ]
              )
            ),
            // Notification area
            Positioned(
                top: 32,
                right: 0.0,
                left: 0.0,
                child: Container(
                    margin: EdgeInsets.all(12.0),
                    child: Column(
                        children: List.generate(_newTravels.length, (index) {
                          return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              switchInCurve: Curves.easeInOut,
                              transitionBuilder: (child, animation) {
                                return SlideTransition(
                                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                                    child: FadeTransition(opacity: animation, child: child)
                                );
                              },
                              child: TripNotification(
                                key: ValueKey(_newTravels[index].id),
                                travel: _newTravels[index],
                                index: index,
                                onDismissed: () => setState(() => _newTravels.removeAt(index)),
                              )
                          );
                        })
                    )
                )
            ),
            // Available travels sheet
            if(_shouldShowAvailableTravels)
              Align(
                  alignment: Alignment.bottomCenter,
                  child: AvailableTravelsSheet(onTravelSelected: _onTravelSelected)
              )
          ]
        )
      )
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