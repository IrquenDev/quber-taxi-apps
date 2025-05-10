import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart' show StatusBarController;
import 'package:geolocator/geolocator.dart' as g;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/models/mapbox_place.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';
import 'package:quber_taxi/enums/mapbox_place_type.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.position});

  final Position position;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  final _mapboxService = const MapboxService();
  final _lineLayer = LineLayer(
      id: "line-layer",
      sourceId: "sourceId", // matches GeoJsonSource.id
      lineColor: 0xFF0000FF,
      lineWidth: 4.0,
      minZoom: 1,
      maxZoom: 24
  );
  final _originQueryController = TextEditingController();
  final _destinationQueryController = TextEditingController();

  MapboxMap? _mapController;
  MapboxPlace? _origin;
  MapboxPlace? _destination;

  late PointAnnotationManager _pointAnnotationManager;
  late PointAnnotation _pointAnnotation;
  late Uint8List _imageData;

  var isLocationSelectedOnce = false;

  Future<void> _zoomToFitRoute(List<List<num>> coords) async {
    final lats = coords.map((e) => e[1]);
    final lngs = coords.map((e) => e[0]);
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    
    final cameraOptions = await _mapController?.cameraForCoordinateBounds(
        CoordinateBounds(
            southwest: Point(coordinates: Position(minLng, minLat)),
            northeast: Point(coordinates: Position(maxLng, maxLat)),
            infiniteBounds: true
        ),
        MbxEdgeInsets(top: 50, bottom: 50, left: 30, right: 30), 0, 0, null, null
    );

    _mapController?.easeTo(
        cameraOptions!,
        MapAnimationOptions(duration: 500)
    );
  }

  @override
  Widget build(BuildContext context) {

    final cameraOptions = CameraOptions(
        center: Point(coordinates: widget.position),
        pitch: 0,
        bearing: 0,
        zoom: 15
    );

    return StatusBarController(
      systemUiMode: SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      builder: (statusBarHeight) => Scaffold(
          body: Stack(
              children: [
                Positioned.fill(
                  child: MapWidget(
                      styleUri: MapboxStyles.STANDARD,
                      cameraOptions: cameraOptions,
                      onMapCreated: (mapboxMap) async {
                        // Init fields
                        final pointManager = await mapboxMap.annotations.createPointAnnotationManager();
                        final bytes = await rootBundle.load('assets/mapbox/location-marker.png');
                        final origin = await _mapboxService.searchLocationName(
                            longitude: widget.position.lng, latitude: widget.position.lat,
                            types: [MapboxPlaceType.place, MapboxPlaceType.address]
                        );
                        // Update some mapbox component
                        mapboxMap.location.updateSettings(LocationComponentSettings(enabled: true));
                        mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
                        // Re-build with new field values.
                        setState(() {
                          _mapController = mapboxMap;
                          _origin = origin;
                          _pointAnnotationManager = pointManager;
                          _imageData = bytes.buffer.asUint8List();
                        });
                      },
                      onTapListener: (mapContext) async {
                        // Updating point
                        final lng = mapContext.point.coordinates.lng;
                        final lat = mapContext.point.coordinates.lat;
                        var newPoint = Point(coordinates: Position(lng, lat));
                        // Getting route
                        final route = await _mapboxService.getRoute(
                            originLat: widget.position.lat,
                            originLng: widget.position.lng,
                            destinationLat: lat,
                            destinationLng: lng
                        );
                        // Applying dynamic zoom to fully expose the route.
                        _zoomToFitRoute(route.coordinates);
                        // Create or update destination marker
                        if(isLocationSelectedOnce) {
                          _pointAnnotation.geometry = newPoint;
                          _pointAnnotationManager.update(_pointAnnotation);
                        }
                        else {
                          _pointAnnotationManager.create(PointAnnotationOptions(
                              geometry: newPoint,
                              image: _imageData,
                              iconAnchor: IconAnchor.BOTTOM
                          )).then((value) => _pointAnnotation = value);
                        }
                        // Drowning the rute
                        if(isLocationSelectedOnce) {
                          final coordinates = route.coordinates
                              .map((position) => Position(position[0], position[1]))
                              .toList();
                          await _mapController?.style.updateGeoJSONSourceFeatures(
                              "sourceId", "dataId", [Feature(id: "featureId", geometry: LineString(coordinates: coordinates))]
                          );
                          await _mapController?.style.updateLayer(_lineLayer);
                        }
                        else {
                          final geoJsonData = {
                            "type": "Feature",
                            "id": "featureId",
                            "geometry": {
                              "type": "LineString",
                              "coordinates": route.coordinates
                            }
                          };
                          await _mapController?.style.addSource(
                              GeoJsonSource(id: "sourceId", data: jsonEncode(geoJsonData))
                          );
                          await _mapController?.style.addLayer(_lineLayer);
                        }
                        // Updating destination
                        final destination = await _mapboxService.searchLocationName(
                            longitude: lng, latitude: lat,
                            types: [MapboxPlaceType.place, MapboxPlaceType.address]
                        );
                        setState(() => _destination = destination);
                        // If all instructions are completed correctly, it's safe to set that a location has been
                        // selected.
                        // This is necessary to decide whether to create/update markers or routes.
                        isLocationSelectedOnce = true;
                        // Example Modal
                        if (!context.mounted) return;
                        showModalBottomSheet(
                            context: context,
                            builder: (_) => Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 20.0,
                                    children: [
                                      Text(
                                          "Los datos tienen una alta presición pero siguen siendo aproximados",
                                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.amber),
                                          textAlign: TextAlign.center
                                      ),
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text("Duración: ${(route.duration/60).toStringAsFixed(0)} min",
                                                          style: Theme.of(context).textTheme.bodyLarge
                                                      ),
                                                      Text("Distancia: ${(route.distance/1000).toStringAsFixed(2)} km",
                                                          style: Theme.of(context).textTheme.bodyLarge
                                                      )
                                                    ]
                                                )
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("Hacer Viaje"),
                                            )
                                          ]
                                      )
                                    ]
                                )
                            )
                        );
                      }
                  )
                ),

                // Find my location
                Positioned(
                    right: 20, bottom: 20,
                    child: FloatingActionButton(
                        onPressed: () async {
                          final position = await g.Geolocator.getCurrentPosition();
                          _mapController!.easeTo(CameraOptions(center: Point(coordinates:
                          Position(position.longitude, position.latitude))),
                              MapAnimationOptions(duration: 500)
                          );
                        },
                        child: Icon(Icons.not_listed_location_outlined)
                    )
                ),

                // Example Search Input (Origin - Destination)
                Positioned(
                    top: statusBarHeight, right: 12.0, left: 12.0,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8.0,
                        children: [
                          TextFormField(
                            controller: _originQueryController,
                            decoration: InputDecoration(
                                hintText: _origin?.placeName ?? "Origen",
                                suffixIcon: Icon(Icons.search_outlined)
                            ),
                          ),
                          TextFormField(
                              controller: _destinationQueryController,
                              decoration: InputDecoration(
                                  hintText: _destination?.placeName ?? "Destino",
                                  suffixIcon: IconButton(
                                    onPressed: () async {
                                      final queryString = _destinationQueryController.text;
                                      if(queryString.isEmpty) return;
                                      final destination = await _mapboxService.searchLocationCoords(
                                          query: queryString,
                                          proximity: widget.position,
                                          types: [
                                            MapboxPlaceType.place, MapboxPlaceType.address, MapboxPlaceType.locality
                                          ]
                                      );
                                      if(destination != null) {
                                        _mapController!.easeTo(CameraOptions(center: Point(coordinates:
                                            Position(destination.coordinates[0], destination.coordinates[1]))),
                                            MapAnimationOptions(duration: 500)
                                        );
                                        setState(() => _destination = destination);
                                      }
                                    },
                                    icon: Icon(Icons.search_outlined),
                                  )
                              )
                          )
                        ]
                    )
                )
              ]
          )
      ),
    );
  }
}