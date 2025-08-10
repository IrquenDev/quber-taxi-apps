import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/client-app/pages/navigation/trip_completed.dart';
import 'package:quber_taxi/common/services/admin_service.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/common/widgets/dialogs/confirm_dialog.dart';
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

  const ClientNavigation({super.key, required this.travel});

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
  late final StreamSubscription<g.Position> _locationStream;
  num _finalDistance = 0;
  Stopwatch? _stopwatch;
  late final FinishConfirmationHandler _confirmationHandler;
  final _travelService = TravelService();
  double? _travelPriceByTaxiType;

  double get _finalPrice => _finalDistance * _travelPriceByTaxiType!;

  int get _finalDuration => _stopwatch?.elapsed.inMinutes ?? 0;
  late final double _creditForQuber;
  bool _isTravelCompleted = false;

  void _startTrackingDistance() {
    _locationStream =
        g.Geolocator.getPositionStream(locationSettings: g.LocationSettings(distanceFilter: 5)).listen(_onMove);
  }

  void _onMove(g.Position newPosition) {
    _stopwatch ??= Stopwatch()..start();
    _calcRealTimeDistance(newPosition);
    _updateTaxiMarker(newPosition);
    _realTimeRoute.add(turf.Position(newPosition.longitude, newPosition.latitude));
  }

  void _calcRealTimeDistance(g.Position newPosition) {
    final point1 = turf.Point(coordinates: _realTimeRoute.last);
    final point2 = turf.Point(coordinates: turf.Position(newPosition.longitude, newPosition.latitude));
    final segmentDistance = td.distance(point1, point2, Unit.kilometers);
    setState(() => _finalDistance += segmentDistance);
  }

  void _updateTaxiMarker(g.Position newPosition) async {
    if (_pointAnnotationManager != null) {
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
        final bearing = mb_util.calculateBearing(
            _realTimeRoute.last.lat, _realTimeRoute.last.lng, newPosition.latitude, newPosition.longitude);
        final adjustedBearing = (bearing - _mapBearing + 360) % 360;
        _taxiMarker!.iconRotate = adjustedBearing;
        // Then update marker
        _pointAnnotationManager!.update(_taxiMarker!);
      }
    }
  }

  void _onMapCreated(MapboxMap controller) async {
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
        iconAnchor: IconAnchor.BOTTOM
    ));

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
          0, 0, null, null,
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
            fillColor: Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.5).value,
            fillOutlineColor: Theme.of(context).colorScheme.tertiary.value,
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
            0, 0, null, null,
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
    final response = await _travelService.markAsCompleted(
      travelId: widget.travel.id,
      finalDistance: _finalDistance.toInt(),
      finalDuration: _finalDuration,
      finalPrice: _finalPrice,
      quberCredit: (_finalPrice * _creditForQuber) / 100,
    );
    if (response.statusCode == 200) {
      _stopwatch?.stop();
      setState(() {
        _isTravelCompleted = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final quberConfig = await AdminService().getQuberConfig();
      _travelPriceByTaxiType = quberConfig!.travelPrice[widget.travel.taxiType]!;
      _creditForQuber = quberConfig.quberCredit;
    });
    final l10n = AppLocalizations.of(context)!;
    _confirmationHandler = FinishConfirmationHandler(
        travelId: widget.travel.id,
        onConfirmationRequested: () async {
          final result = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
              ConfirmDialog(
                  title: l10n.confirmacionLlegadaDestino,
                  message: l10n.confirmacionLlegadaDestinoMensaje
              )
          );
          if(result == true) {
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
    _locationStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Init camera options
    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(widget.travel.originCoords[0], widget.travel.originCoords[1])),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status, useTopSafeArea: true),
      alertPosition: Alignment.topCenter,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBody: true,
        body: Stack(
          children: [
            MapWidget(
              styleUri: MapboxStyles.STANDARD,
              cameraOptions: cameraOptions,
              onMapCreated: _onMapCreated,
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
                            color: Colors.black.withOpacity(0.1),
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
                        tooltip: l10n.verMiUbicacion,
                      ),
                    ),
                    SizedBox(width: 12),
                    if(!_isTravelCompleted)
                    ElevatedButton.icon(
                      onPressed: hasConnection(context) ? () async {
                        final result = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => ConfirmDialog(
                                title: l10n.confirmacionFinalizacion,
                                message: l10n.confirmacionFinalizacionMensaje
                            )
                        );
                        if(result == true) {
                          _markTravelAsCompleted();
                        }
                      } : null,
                      icon: Icon(Icons.done_outline, color: Colors.white),
                      label: Text(
                        l10n.finalizarViaje,
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
        bottomSheet:  _isTravelCompleted
            ? ClientTripCompleted(
            travel: widget.travel,
            duration: _finalDuration,
            distance: _finalDistance.toInt(),
            travelPriceByTaxiType: _travelPriceByTaxiType!
        )
            : ClientTripInfo(
          distance: _finalDistance.toInt(),
          travelPriceByTaxiType: _travelPriceByTaxiType,
          originName: widget.travel.originName,
          destinationName: widget.travel.destinationName,
          taxiType: widget.travel.taxiType
        )
      )
    );
  }
}
