import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quber_taxi/client-app/pages/navigation/trip_completed.dart';
import 'package:quber_taxi/common/services/admin_service.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/common/widgets/dialogs/confirm_dialog.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/utils/map/mapbox.dart' as mb_util;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/client-app/pages/navigation/trip_info.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/utils/websocket/impl/finish_confirmation_handler.dart';
import 'package:quber_taxi/enums/municipalities.dart';
import 'package:quber_taxi/utils/map/turf.dart' as turf_util;
import 'package:turf/distance.dart' as td;
import 'package:turf/turf.dart' as turf;

class ClientNavigation extends StatefulWidget {

  final Travel travel;
  final bool wasPageRestored;

  const ClientNavigation({super.key, required this.travel, this.wasPageRestored = false});

  @override
  State<ClientNavigation> createState() => _ClientNavigationState();
}

class _ClientNavigationState extends State<ClientNavigation> {
  // Map functionalities
  late final MapboxMap _mapController;
  late double _mapBearing;

  // Markers
  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotation? _taxiMarker;

  // Real time distance calculation
  final List<turf.Position> _realTimeRoute = [];
  StreamSubscription<g.Position>? _locationStream;
  num _distanceInKm = 0;
  double? get _finalPrice => (widget.wasPageRestored || _travelPriceByTaxiType == null) ? null : _distanceInKm * _travelPriceByTaxiType!;
  Stopwatch? _stopwatch;
  late final FinishConfirmationHandler _confirmationHandler;
  final _travelService = TravelService();
  double? _travelPriceByTaxiType;

  int? get _finalDuration => widget.wasPageRestored ? null : _stopwatch?.elapsed.inMinutes;
  bool _isTravelCompleted = false;
  late ScaffoldMessengerState _scaffoldMessenger;

  void _showRestoredBanner() {
    _scaffoldMessenger.showMaterialBanner(
      MaterialBanner(
        padding: EdgeInsets.all(8.0),
        content: Text(
          'Vista restaurada: Las métricas del viaje ya no son confiables. Guíese por la app del conductor.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        surfaceTintColor: Theme.of(context).colorScheme.errorContainer,
        leading: Icon(
          Icons.warning_outlined,
          color: Theme.of(context).colorScheme.onErrorContainer,
          size: 24,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _scaffoldMessenger.hideCurrentMaterialBanner();
            },
            child: Text(
              'CERRAR',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startTrackingDistance() {
    if (!widget.wasPageRestored) {
      _locationStream =
          g.Geolocator.getPositionStream(locationSettings: g.LocationSettings(distanceFilter: 5)).listen(_onMove);
    }
  }

  void _onMove(g.Position newPosition) {
    if (widget.wasPageRestored) return; // Skip tracking if restored
    _stopwatch ??= Stopwatch()..start();
    _calcRealTimeDistance(newPosition);
    _updateTaxiMarker(newPosition);
    _realTimeRoute.add(turf.Position(newPosition.longitude, newPosition.latitude));
  }

  void _calcRealTimeDistance(g.Position newPosition) {
    if (widget.wasPageRestored || _realTimeRoute.isEmpty) return;
    final point1 = turf.Point(coordinates: _realTimeRoute.last);
    final point2 = turf.Point(coordinates: turf.Position(newPosition.longitude, newPosition.latitude));
    final segmentDistance = td.distance(point1, point2, Unit.kilometers);
    setState(() => _distanceInKm += segmentDistance);
  }

  void _updateTaxiMarker(g.Position newPosition) async {
    if (widget.wasPageRestored || _pointAnnotationManager == null) return;
    final point = Point(coordinates: Position(newPosition.longitude, newPosition.latitude));
    if (_taxiMarker == null) {
      // Display marker
      final taxiMarkerBytes = await rootBundle.load('assets/markers/taxi/taxi_pin_x172.png');
      await _pointAnnotationManager!
          .create(PointAnnotationOptions(
              geometry: point, image: taxiMarkerBytes.buffer.asUint8List(), iconAnchor: IconAnchor.BOTTOM))
          .then((value) => _taxiMarker = value);
    } else {
      // Update geometry point
      _taxiMarker!.geometry = point;
      // Update icon rotation (orientation)
      if (_realTimeRoute.isNotEmpty) {
        final bearing = mb_util.calculateBearing(
            _realTimeRoute.last.lat, _realTimeRoute.last.lng, newPosition.latitude, newPosition.longitude);
        final adjustedBearing = (bearing - _mapBearing + 360) % 360;
        _taxiMarker!.iconRotate = adjustedBearing;
      }
      // Then update marker
      _pointAnnotationManager!.update(_taxiMarker!);
    }
  }

  void _onMapCreated(MapboxMap controller, ColorScheme colorScheme) async {
    // Init fields
    _mapController = controller;
    _mapBearing = await _mapController.getCameraState().then((c) => c.bearing);
    _pointAnnotationManager = await _mapController.annotations.createPointAnnotationManager();
    // Update some mapbox component
    _mapController.location.updateSettings(LocationComponentSettings(enabled: false));
    _mapController.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    final position = Position(widget.travel.originCoords[0], widget.travel.originCoords[1]);
    // Display origin marker
    final originMarkerBytes = await rootBundle.load('assets/markers/route/x120/origin.png');
    await _pointAnnotationManager!.create(PointAnnotationOptions(
        geometry: Point(coordinates: position),
        image: originMarkerBytes.buffer.asUint8List(),
        iconAnchor: IconAnchor.BOTTOM));

    // Render destination: marker for exact point or polygon for municipality
    try {
      // Exact destination point
      if (widget.travel.destinationCoords != null) {
        final destinationMarkerBytes = await rootBundle.load('assets/markers/route/x120/destination.png');
        final destinationCoords = Position(
          widget.travel.destinationCoords![0],
          widget.travel.destinationCoords![1],
        );
        await _pointAnnotationManager!.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: destinationCoords),
            image: destinationMarkerBytes.buffer.asUint8List(),
            iconAnchor: IconAnchor.BOTTOM,
          ),
        );

        // Fit camera to show both origin and destination
        final bounds = mb_util.calculateBounds([position, destinationCoords]);
        final cameraOptions = await _mapController.cameraForCoordinateBounds(
          bounds,
          MbxEdgeInsets(top: 50, bottom: 50, left: 50, right: 50),
          0,
          0,
          null,
          null,
        );
        _mapController.easeTo(cameraOptions, MapAnimationOptions(duration: 1000));
      } else {
        // Municipality polygon
        final path = Municipalities.resolveGeoJsonRef(widget.travel.destinationName);
        if (path != null) {
          final polygon = await turf_util.GeoUtils.loadGeoJsonPolygon(path);
          final geoJsonString = jsonEncode(polygon.toJson());
          await _mapController.style.addSource(GeoJsonSource(
            id: 'destination-municipality-polygon',
            data: geoJsonString,
          ));
          await _mapController.style.addLayer(FillLayer(
            id: 'destination-municipality-fill',
            sourceId: 'destination-municipality-polygon',
            fillColor: colorScheme.onTertiaryContainer.withValues(alpha: 0.5).toARGB32(),
            fillOutlineColor: colorScheme.tertiary.toARGB32(),
          ));

          // Fit camera to include origin and polygon bounds
          final polygonCoords = polygon.coordinates[0];
          final List<Position> allCoords = [position];
          for (final coord in polygonCoords) {
            if (coord[0] != null && coord[1] != null) {
              allCoords.add(Position(coord[0]!, coord[1]!));
            }
          }
          final bounds = mb_util.calculateBounds(allCoords);
          final cameraOptions = await _mapController.cameraForCoordinateBounds(
            bounds,
            MbxEdgeInsets(top: 50, bottom: 50, left: 50, right: 50),
            0,
            0,
            null,
            null,
          );
          _mapController.easeTo(cameraOptions, MapAnimationOptions(duration: 1000));
        }
      }
    } catch (e) {
      // In case of any error, keep map centered at origin silently
      // print('Error rendering destination: $e');
    }
  }

  void _onCameraChangeListener(CameraChangedEventData camera) {
    _mapBearing = camera.cameraState.bearing;
    if (_taxiMarker != null) {
      final bearing = mb_util.calculateBearing(_realTimeRoute.last.lat, _realTimeRoute.last.lng,
          _realTimeRoute[_realTimeRoute.length - 1].lat, _realTimeRoute[_realTimeRoute.length - 1].lng);
      final adjustedBearing = (bearing - _mapBearing + 360) % 360;
      _taxiMarker!.iconRotate = adjustedBearing;
      _pointAnnotationManager!.update(_taxiMarker!);
    }
  }

  void _markTravelAsCompleted() async {
    final response = await _travelService.changeState(travelId: widget.travel.id, state: TravelState.completed);
    if(response.statusCode == 200) {
      setState(() {
        _isTravelCompleted = true; // show completed travel metrics (bottom sheet)
      });
      _stopwatch?.stop();
      _locationStream?.cancel();
      _confirmationHandler.deactivate();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(widget.wasPageRestored) {
        _showRestoredBanner();
      } else {
        final quberConfig = await AdminService().getQuberConfig();
        _travelPriceByTaxiType = quberConfig!.travelPrice[widget.travel.taxiType]!;
      }
    });
    _confirmationHandler = FinishConfirmationHandler(
        travelId: widget.travel.id,
        onConfirmationRequested: () async {
          // ConfirmDialog
          final result = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => const ConfirmDialog(
                  title: 'Confirmación de finalización',
                  message: "El conductor ha notificado que se ha llegado al destino. Acepte solo si esto es correcto"));
          // Handle result
          if (result == true) {
            _markTravelAsCompleted();
          }
        })
      ..activate();
    _realTimeRoute.add(turf.Position(widget.travel.originCoords[0], widget.travel.originCoords[1]));
    _startTrackingDistance();
  }

  @override
  void dispose() {
    _confirmationHandler.deactivate();
    _locationStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    // Init camera options
    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(widget.travel.originCoords[0], widget.travel.originCoords[1])),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return Scaffold(
        resizeToAvoidBottomInset: true,
        extendBody: true,
        body: Stack(
          children: [
            MapWidget(
              styleUri: MapboxStyles.STANDARD,
              cameraOptions: cameraOptions,
              onMapCreated: (controller) => _onMapCreated(controller, colorScheme),
              onCameraChangeListener: _onCameraChangeListener,
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () async {
                          final position = await g.Geolocator.getCurrentPosition();
                          _mapController.easeTo(
                            CameraOptions(
                              center: Point(
                                coordinates: Position(position.longitude, position.latitude),
                              ),
                              zoom: 17,
                            ),
                            MapAnimationOptions(duration: 1000),
                          );
                        },
                        icon: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary),
                        tooltip: 'Ver mi ubicación',
                      ),
                    ),
                    SizedBox(width: 12),
                    if (!_isTravelCompleted)
                      ElevatedButton.icon(
                        onPressed: hasConnection(context)
                            ? () async {
                                // Confirmation dialog
                                final result = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const ConfirmDialog(
                                        title: 'Confirmación de finalización',
                                        message:
                                            "Se le notificará inmediatamente al conductor que desea terminar el viaje. Acepte solo "
                                            "si esto es correcto."));
                                if (result == true) {
                                  _markTravelAsCompleted();
                                }
                              }
                            : null,
                        icon: Icon(Icons.done_outline, color: Colors.white),
                        label: Text(
                          'Finalizar viaje',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          ],
        ),
        bottomSheet: _isTravelCompleted
            ? ClientTripCompleted(
                travel: widget.travel,
                duration: _finalDuration,
                distance: widget.wasPageRestored ? null : _distanceInKm.toInt(),
                price: _finalPrice)
            : ClientTripInfo(
                distance: widget.wasPageRestored ? null : _distanceInKm.toInt(),
                travelPriceByTaxiType: _travelPriceByTaxiType,
                travel: widget.travel));
  }
}
