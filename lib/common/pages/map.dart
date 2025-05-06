import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/util/mapbox.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
    required this.position
  });

  final Position position;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  late MapboxMap mapController;
  late PointAnnotationManager pointAnnotationManager;
  PointAnnotation? pointAnnotation;
  late Uint8List imageData;

  @override
  Widget build(BuildContext context) {

    final cameraOptions = CameraOptions(
        center: Point(coordinates: widget.position),
        pitch: 0,
        bearing: 0,
        zoom: 15
    );

    return MapWidget(
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: cameraOptions,
      onMapCreated: (mapboxMap) async {
        mapController = mapboxMap;
        mapController.annotations.createPointAnnotationManager().then((value) async {
          pointAnnotationManager = value;
          final ByteData bytes = await rootBundle.load('assets/mapbox/location-marker.png');
          imageData = bytes.buffer.asUint8List();
        });
        mapController.location.updateSettings(LocationComponentSettings(enabled: true));
      },
      onTapListener: (mapContext) async {
        final lng = mapContext.point.coordinates.lng;
        final lat = mapContext.point.coordinates.lat;
        var newPoint = Point(coordinates: Position(lng, lat));
        mapController.easeTo(
            cameraOptions.copyWith(center: newPoint),
            MapAnimationOptions(duration: 500) // 1 seg
        );
        if(pointAnnotation == null) {
          pointAnnotationManager.create(PointAnnotationOptions(
              geometry: newPoint,
              image: imageData,
              iconAnchor: IconAnchor.BOTTOM
          )).then((value) => pointAnnotation = value);
        }
        else {
          pointAnnotation!.geometry = newPoint;
          pointAnnotationManager.update(pointAnnotation!);
        }
      }
    );
  }
}