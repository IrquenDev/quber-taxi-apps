import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/common/services/admin_service.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/driver-app/pages/navigation/trip_completed.dart';
import 'package:quber_taxi/enums/municipalities.dart';
import 'package:quber_taxi/enums/travel_request_type.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/navigation/backup_navigation_manager.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/storage/session_prefs_manger.dart';
import 'package:quber_taxi/utils/map/mapbox.dart' as mb_util;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';
import 'package:quber_taxi/driver-app/pages/navigation/trip_info.dart';
import 'package:quber_taxi/utils/map/mapbox.dart';
import 'package:quber_taxi/utils/map/turf.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';
import 'package:quber_taxi/utils/websocket/impl/travel_state_handler.dart';
import 'package:turf/distance.dart' as td;
import 'package:turf/turf.dart' as turf;

class DriverNavigationPage extends StatefulWidget {
  final Travel travel;
  final bool wasRestored;

  const DriverNavigationPage({super.key, required this.travel, this.wasRestored = false});

  @override
  State<DriverNavigationPage> createState() => _DriverNavigationPageState();
}

class _DriverNavigationPageState extends State<DriverNavigationPage> {
  // Map functionalities
  final _mapboxService = MapboxService();
  late final MapboxMap _mapController;
  late double _mapBearing;
  // Markers
  PointAnnotationManager? _pointAnnotationManager;
  late Uint8List _destinationMakerImage;
  PointAnnotation? _destinationMarker;
  PointAnnotation? _taxiMarker;
  // LineLayer for drawing route
  final _lineLayer = LineLayer(
      id: "line-layer",
      sourceId: "sourceId", // matches GeoJsonSource.id
      lineColor: 0xFF0000FF,
      lineWidth: 4.0,
      minZoom: 1,
      maxZoom: 24);
  bool _isRouteDrawn = false;
  bool _isGuidedRouteEnabled = false;
  // Real time distance calculation
  final List<turf.Position> _realTimeRoute = [];
  late final StreamSubscription<g.Position> _locationStream;
  num _distanceInKm = 0;
  Stopwatch? _stopwatch;
  int get _duration => _stopwatch?.elapsed.inMinutes ?? 0;
  int? get _finalDuration => widget.wasRestored ? null : _duration;
  // Ignore points outside of selected municipality (when applicable)
  turf.Polygon? _municipalityPolygon;
  // Websocket for travel state changed (Here we must wait for the client to accept the finish confirmation or
  // trigger it be himself).
  late final TravelStateHandler _travelStateHandler;
  bool _isTravelCompleted = false;
  Driver _driver = Driver.fromJson(loggedInUser);
  // Price calculation
  late final double _creditForQuber;
  double? _travelPriceByTaxiType;
  double get _finalPrice => _distanceInKm * (_travelPriceByTaxiType!);
  // Cached route for fixed destination
  List<List<num>>? _fixedRouteCoordinates;
  bool get _isFixedDestination => widget.travel.destinationCoords != null;
  final _travelService = TravelService();
  late ScaffoldMessengerState _scaffoldMessenger;

  void _showRestoredBanner() {
    _scaffoldMessenger.showMaterialBanner(
      MaterialBanner(
        padding: EdgeInsets.all(8.0),
        content: Text(
          'Vista restaurada: Las métricas del viaje ya no son confiables. Se le aplicará una penalización al '
              'finalizar el viaje'
              '${!_isFixedDestination ? " y se asumirá el precio máximo para calcular el crédito a descontar." : "."}',
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

  Future<void> _loadMunicipalityGeoJson() async {
    final munPath = Municipalities.resolveGeoJsonRef(widget.travel.destinationName);
    if (munPath == null) return;
    _municipalityPolygon = await GeoUtils.loadGeoJsonPolygon(munPath);
  }

  void _onMove(g.Position newPosition) {
    if(widget.wasRestored) {
      _updateTaxiMarker(newPosition);
    } else {
      _stopwatch ??= Stopwatch()..start();
      _calcRealTimeDistance(newPosition);
      _updateTaxiMarker(newPosition);
      _realTimeRoute.add(turf.Position(newPosition.longitude, newPosition.latitude));
    }
  }

  void _calcRealTimeDistance(g.Position newPosition) {
    final point1 = turf.Point(coordinates: _realTimeRoute.last);
    final point2 = turf.Point(coordinates: turf.Position(newPosition.longitude, newPosition.latitude));
    final segmentDistance = td.distance(point1, point2, Unit.kilometers);
    setState(() => _distanceInKm += segmentDistance);
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

  Future<void> _getAndDrownRoute(num originLng, num originLat, num destinationLng, num destinationLat) async {
    // Getting route and drown
    final route = await _mapboxService.getRoute(
        originLng: originLng, originLat: originLat, destinationLng: destinationLng, destinationLat: destinationLat);
    _fixedRouteCoordinates ??= _isFixedDestination ? route.coordinates : _fixedRouteCoordinates;
    await _drawRouteFromCoordinates(route.coordinates, destinationLng, destinationLat);
  }

  Future<void> _drawRouteFromCoordinates(
      List<List<num>> coordinates, num destinationLng, num destinationLat) async {
    // Applying dynamic zoom to fully expose the route.
    zoomToFitRoute(_mapController, coordinates);
    // Create or update destination marker
    final point = Point(coordinates: Position(destinationLng, destinationLat));
    if (_destinationMarker == null) {
      _pointAnnotationManager!
          .create(PointAnnotationOptions(geometry: point, image: _destinationMakerImage, iconAnchor: IconAnchor.BOTTOM))
          .then((value) => _destinationMarker = value);
    } else {
      _destinationMarker!.geometry = point;
      _pointAnnotationManager!.update(_destinationMarker!);
    }
    // Drawing the route
    if (!_isRouteDrawn) {
      final geoJsonData = {
        "type": "Feature",
        "id": "featureId",
        "geometry": {"type": "LineString", "coordinates": coordinates}
      };
      await _mapController.style.addSource(GeoJsonSource(id: "sourceId", data: jsonEncode(geoJsonData)));
      await _mapController.style.addLayer(_lineLayer);
      _isRouteDrawn = true;
    } else {
      final coords = coordinates.map((p) => Position(p[0], p[1])).toList();
      await _mapController.style.updateGeoJSONSourceFeatures(
          "sourceId", "dataId", [Feature(id: "featureId", geometry: LineString(coordinates: coords))]);
      await _mapController.style.updateLayer(_lineLayer);
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
    // Load destination marker image
    final destinationMarkerBytes = await rootBundle.load('assets/markers/route/x120/destination.png');
    _destinationMakerImage = destinationMarkerBytes.buffer.asUint8List();

    // Render destination initially (marker or municipality polygon) and fit camera
    try {
      if (widget.travel.destinationCoords != null) {
        // Exact destination point
        final dest = Position(widget.travel.destinationCoords![0], widget.travel.destinationCoords![1]);
        await _pointAnnotationManager!
            .create(PointAnnotationOptions(
              geometry: Point(coordinates: dest),
              image: _destinationMakerImage,
              iconAnchor: IconAnchor.BOTTOM,
            ))
            .then((value) => _destinationMarker = value);

        final bounds = mb_util.calculateBounds([position, dest]);
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
          final municipality = await GeoUtils.loadGeoJsonPolygon(path);
          final geoJsonString = jsonEncode(municipality.toJson());
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

          final polygonCoords = municipality.coordinates[0];
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
    } catch (_) {
      // silently ignore
    }
  }

  void _onLongTapListener(MapContentGestureContext mapContext) async {
    if (_isFixedDestination) return;
    if (!_isGuidedRouteEnabled) return;
    // Getting coords
    final lng = mapContext.point.coordinates.lng;
    final lat = mapContext.point.coordinates.lat;
    // Check if inside of selected municipality
    final hasPolygon = _municipalityPolygon != null;
    final isInside = hasPolygon ? GeoBoundaries.isPointInPolygon(lng, lat, _municipalityPolygon!) : true;
    if (!isInside) {
      final loc = AppLocalizations.of(context)!;
      showToast(context: context, message: loc.destinationsLimited(widget.travel.destinationName));
      return;
    }
    await _getAndDrownRoute(widget.travel.originCoords[0], widget.travel.originCoords[1], lng, lat);
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

  void _onGuidedRouteSwitched(bool isEnabled) async {
    if (!isEnabled && _isRouteDrawn) {
      await _mapController.style.removeStyleLayer("line-layer");
      await _mapController.style.removeStyleSource("sourceId");
      // Restore bookmark according to destination type
      if (_isFixedDestination) {
        final point = Point(
          coordinates: Position(
            widget.travel.destinationCoords![0],
            widget.travel.destinationCoords![1],
          ),
        );
        if (_destinationMarker == null) {
          _destinationMarker = await _pointAnnotationManager!.create(
            PointAnnotationOptions(
              geometry: point,
              image: _destinationMakerImage,
              iconAnchor: IconAnchor.BOTTOM,
            ),
          );
        } else {
          _destinationMarker!.geometry = point;
          await _pointAnnotationManager!.update(_destinationMarker!);
        }
      } else {
        // Municipality: delete destination marker if it existed
        if (_destinationMarker != null) {
          await _pointAnnotationManager!.delete(_destinationMarker!);
          _destinationMarker = null;
        }
      }
      _isRouteDrawn = false;
    }
    if (isEnabled && _isFixedDestination) {
      // Draw from cache if available; otherwise prefetch once and cache
      if (_fixedRouteCoordinates != null) {
        await _drawRouteFromCoordinates(
          _fixedRouteCoordinates!,
          widget.travel.destinationCoords![0],
          widget.travel.destinationCoords![1],
        );
      } else {
        await _getAndDrownRoute(
          widget.travel.originCoords[0],
          widget.travel.originCoords[1],
          widget.travel.destinationCoords![0],
          widget.travel.destinationCoords![1],
        );
      }
    }
    setState(() => _isGuidedRouteEnabled = isEnabled);
  }

  void _completeTravel(Travel travel) async {
    // Cancel stopwatch
    _stopwatch?.stop();
    // Mark this travel as completed (or with issues) in the api
    late http.Response response;
    if(widget.wasRestored) {
      response = await _travelService.markAsCompletedWithIssue(travelId: widget.travel.id);
    } else {
      response = await _travelService.markAsCompleted(
        travelId: widget.travel.id,
        finalDistance: _distanceInKm.toInt(),
        finalDuration: _duration,
        finalPrice: _finalPrice,
        quberCredit: (_finalPrice * _creditForQuber) / 100,
      );
    }
    if (response.statusCode == 200) {
      // In any case (was page restored) the API has already applied discounts, penalties, etc. It's safe to
      // clear the redirect backup right here.
      await BackupNavigationManager.instance.clear();
      // Get the updated driver data and save it locally
      final driverResponse = await AccountService().findDriver(_driver.id);
      if (!mounted) return;
      if (driverResponse.statusCode == 200) {
        _driver = Driver.fromJson(jsonDecode(driverResponse.body));
        final savedFlag = await SessionPrefsManager.instance.save(_driver);
        if (savedFlag) {
          setState(() => _isTravelCompleted = true); // show completed travel metrics (bottom sheet)
          _locationStream.cancel();
          _travelStateHandler.deactivate();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // ALWAYS RUNS ON START UP
    // Websocket handler waiting for travel state changes (completed)
    _travelStateHandler = TravelStateHandler(
        state: TravelState.completed,
        travelId: widget.travel.id,
        onMessage: _completeTravel
    )..activate();
    // Load municipality polygon if destination is a municipality (useful to limit the driver into the destination
    // municipality boxing when selecting a guided route directly from map);
    if (!_isFixedDestination) {
      _loadMunicipalityGeoJson();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Prefetch route for fixed destination to avoid delays when toggling
      if (_isFixedDestination && hasConnection(context)) {
        final route = await _mapboxService.getRoute(
          originLng: widget.travel.originCoords[0],
          originLat: widget.travel.originCoords[1],
          destinationLng: widget.travel.destinationCoords![0],
          destinationLat: widget.travel.destinationCoords![1],
        );
        _fixedRouteCoordinates = route.coordinates;
      }
      // Start streaming location (_onMove behavior depends on wasPageRestored)
      _locationStream = g.Geolocator
          .getPositionStream(locationSettings: g.LocationSettings(distanceFilter: 5))
          .listen(_onMove);
      // DEPENDS ON WAS PAGE RESTORED
      if(widget.wasRestored) {
        _showRestoredBanner();
      } else {
        // Set redirection fallback to this page.
        await BackupNavigationManager.instance.save(route: DriverRoutes.navigation, travel: widget.travel);
        // Get travel price (base on driver's taxi) and percentage of credit to discount from REST API.
        final quberConfig = await AdminService().getQuberConfig();
        _travelPriceByTaxiType = quberConfig!.travelPrice[widget.travel.taxiType]!;
        _creditForQuber = quberConfig.quberCredit;
        // Set first coords (travel origin coords).
        _realTimeRoute.add(turf.Position(widget.travel.originCoords[0], widget.travel.originCoords[1]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dims = Theme.of(context).extension<DimensionExtension>()!;
    final loc = AppLocalizations.of(context)!;
    // Init camera options
    final position = Position(widget.travel.originCoords[0], widget.travel.originCoords[1]);
    final cameraOptions = CameraOptions(
      center: Point(coordinates: position),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            MapWidget(
                styleUri: MapboxStyles.STANDARD,
                cameraOptions: cameraOptions,
                onMapCreated: (controller) => _onMapCreated(controller, colorScheme),
                onLongTapListener: _onLongTapListener,
                onCameraChangeListener: _onCameraChangeListener),
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
                        color: colorScheme.surface,
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
                        icon: Icon(Icons.my_location, color: colorScheme.primary),
                        tooltip: loc.showMyLocation,
                      ),
                    ),
                    SizedBox(width: 12),
                    if (!_isTravelCompleted)
                      ElevatedButton.icon(
                        onPressed: () {
                          if(widget.travel.requestType == TravelRequestType.online) {
                            if(hasConnection(context)) {
                              WebSocketService.instance.send(
                                  "/app/travels/${widget.travel.id}/finish-confirmation",
                                  null
                              );
                            }
                            else {
                              showToast(context: context, message: "Por favor revise su conexión a internet");
                            }
                          }
                          else {
                            _completeTravel(widget.travel);
                          }
                        },
                        icon: Icon(Icons.done_outline, color: colorScheme.onPrimary),
                        label: Text(
                          loc.finishTrip,
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: dims.contentPadding,
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
            ? DriverTripCompleted(
                travel: widget.travel,
                driver: _driver,
                duration: _finalDuration,
                distance: widget.wasRestored ? null : _distanceInKm.toInt(),
                finalPrice: widget.wasRestored
                    ? _isFixedDestination ? widget.travel.fixedPrice! : widget.travel.maxPrice!
                    : _finalPrice
              )
            : DriverTripInfo(
                originName: widget.travel.originName,
                destinationName: widget.travel.destinationName,
                distance: widget.wasRestored ? null : _distanceInKm.toInt(),
                taxiType: widget.travel.taxiType,
                travelPriceByTaxiType: _travelPriceByTaxiType,
                isFixedDestination: _isFixedDestination,
                onGuidedRouteSwitched: _onGuidedRouteSwitched,
              ));
  }
}