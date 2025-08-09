import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/common/widgets/dialogs/confirm_dialog.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/utils/websocket/impl/driver_location_handler.dart';
import 'package:quber_taxi/utils/map/mapbox.dart' as mb_util;
import 'package:quber_taxi/utils/websocket/impl/pickup_confirmation_handler.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';

class TrackDriverPage extends StatefulWidget {
  final Travel travel;

  const TrackDriverPage({super.key, required this.travel});

  @override
  State<TrackDriverPage> createState() => _TrackDriverPageState();
}

class _TrackDriverPageState extends State<TrackDriverPage> {

  // Map
  late final MapboxMap _mapController;
  late double _mapBearing;
  bool _mapReady = false;
  // Markers
  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotation? _driverAnnotation;
  Uint8List _driverMarkerImage = Uint8List(0);
  // Driver location streaming
  late Position _coords;
  late Position _lastKnownCoords;
  // Websocket Handlers
  late final DriverLocationHandler _locationHandler;
  late final PickUpConfirmationHandler _confirmationHandler;
  final _travelService = TravelService();
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  Future<void> _loadDriverMarkerImage() async {
    final assetBytes = await rootBundle.load('assets/markers/taxi/taxi_hdpi.png');
    _driverMarkerImage = assetBytes.buffer.asUint8List();
    print('TrackDriverPage: Driver marker image loaded, size: ${_driverMarkerImage.length} bytes');
  }

  void _onDriverLocationUpdate(Position coords) async {
    // Check if we have the required components ready
    if (_pointAnnotationManager == null || _driverMarkerImage.isEmpty) {
      return;
    }
    // First time getting location data
    if (_driverAnnotation == null) {
      // Init coords
      _coords = coords;
      _lastKnownCoords = coords;
      // Set the marker
      try {
        _driverAnnotation = await _pointAnnotationManager!.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: coords),
            image: _driverMarkerImage,
            iconAnchor: IconAnchor.CENTER,
          ),
        );
      } catch (e) {
        print('Error creating driver marker: $e');
      }
    } else {
      // Update coord
      _lastKnownCoords = _coords;
      _coords = coords;
      // Adjust bearing
      final bearing = mb_util.calculateBearing(
          _lastKnownCoords.lat, _lastKnownCoords.lng,
          coords.lat, coords.lng
      );
      final adjustedBearing = (bearing - _mapBearing + 360) % 360;
      // Update the marker
      _driverAnnotation!.iconRotate = adjustedBearing;
      _driverAnnotation!.geometry = Point(coordinates: coords);
      _pointAnnotationManager?.update(_driverAnnotation!);
    }
  }

  void _onMapCreated(MapboxMap controller) async {
    // Init class's field references
    _mapController = controller;
    _mapBearing = await _mapController.getCameraState().then((c) => c.bearing);
    _mapReady = true;
    // Update some mapbox component
    await controller.location.updateSettings(LocationComponentSettings(enabled: false));
    await controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    // Create PAM
    _pointAnnotationManager = await controller.annotations.createPointAnnotationManager();
    // Display origin marker
    final originCoords = widget.travel.originCoords;
    final originMarkerBytes = await rootBundle.load('assets/markers/route/x120/origin.png');
    await _pointAnnotationManager?.create(PointAnnotationOptions(
        geometry: Point(coordinates: Position(originCoords[0], originCoords[1])),
        image: originMarkerBytes.buffer.asUint8List(),
        iconAnchor: IconAnchor.BOTTOM
    ));
  }

  void _onCameraChangeListener(CameraChangedEventData cameraData) async {
    _mapBearing = cameraData.cameraState.bearing;
    if(_driverAnnotation != null) {
      final bearing = mb_util.calculateBearing(
          _lastKnownCoords.lat, _lastKnownCoords.lng,
          _coords.lat, _coords.lng
      );
      final adjustedBearing = (bearing - _mapBearing + 360) % 360;
      _driverAnnotation!.iconRotate = adjustedBearing;
      _pointAnnotationManager?.update(_driverAnnotation!);
    }
  }

  @override
  void initState() {
    super.initState();
    // Prepare driver marker and activate handlers
    _loadDriverMarkerImage().then((_) {
      // Activate websocket handlers after image is loaded
      _locationHandler = DriverLocationHandler(
          driverId: widget.travel.driver!.id,
          onLocation: _onDriverLocationUpdate
      )..activate();
    });
    
    _confirmationHandler = PickUpConfirmationHandler(
        travelId: widget.travel.id,
        onConfirmationRequested: () async {
          // ConfirmDialog
          final result = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
              ConfirmDialog(
                title: AppLocalizations.of(context)!.pickupConfirmationTitle,
                message: AppLocalizations.of(context)!.pickupConfirmationMessage,
              )
          );
          // Handle result
          if(result == true) {
            final response = await _travelService.changeState(
                travelId: widget.travel.id, state: TravelState.inProgress
            );
            if(!mounted) return;
            if(response.statusCode == 200) {
              // Navigate to ClientNavigation passing the corresponding travel
              context.go(ClientRoutes.navigation, extra: widget.travel);
            }
          }
        }
    )..activate();
  }

  @override
  void dispose() {
    _locationHandler.deactivate();
    _confirmationHandler.deactivate();
    _draggableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final originCoords = widget.travel.originCoords;
    final center = Point(coordinates: Position(originCoords[0], originCoords[1]));
    final localizations = AppLocalizations.of(context)!;

    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status, useTopSafeArea: true),
      alertPosition: Alignment.topCenter,
      child: Scaffold(
        body: MapWidget(
          styleUri: MapboxStyles.STANDARD,
          cameraOptions: CameraOptions(
            center: center,
            pitch: 45,
            bearing: 0,
            zoom: 17,
          ),
          onMapCreated: _onMapCreated,
          onCameraChangeListener: _onCameraChangeListener
        ),
        bottomSheet: DraggableScrollableSheet(
          controller: _draggableController,
          initialChildSize: 0.25,
          minChildSize: 0.15,
          maxChildSize: 0.3,
          expand: false,
          shouldCloseOnMinExtent: false,
          builder: (context, scrollController) {
            return Stack(
              children: [
                // Background Container
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                  ),
                ),
                // Content
                Positioned.fill(
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.tripAccepted,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                localizations.tripAcceptedDescription,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    if (!_mapReady || _driverAnnotation == null) {
                                      showToast(context: context, message: AppLocalizations.of(context)!.noDriverLocation);
                                      return;
                                    }
                                    _mapController.easeTo(
                                      CameraOptions(center: _driverAnnotation!.geometry),
                                      MapAnimationOptions(duration: 700),
                                    );
                                  },
                                  icon: const Icon(Icons.local_taxi_outlined),
                                  label: Text(AppLocalizations.of(context)!.seeDriverLocation),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}