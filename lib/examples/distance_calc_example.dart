import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';
import 'package:quber_taxi/enums/municipalities.dart';
import 'package:quber_taxi/util/turf.dart';
import 'package:turf/turf.dart' as turf;

class MapGeoJsonCheckPage extends StatefulWidget {
  const MapGeoJsonCheckPage({super.key});

  @override
  State<MapGeoJsonCheckPage> createState() => _MapGeoJsonCheckPageState();
}

class _MapGeoJsonCheckPageState extends State<MapGeoJsonCheckPage> {

  final _defaultOrigin = Point(coordinates: Position(-82.3598, 23.1380));
  final _service = MapboxService();

  Future<void> _handleMapTap(MapContentGestureContext tappedPoint) async {
    final dest = turf.Position(tappedPoint.point.coordinates.lng, tappedPoint.point.coordinates.lat);

    final place = await _service.getLocationName(longitude: dest.lng, latitude: dest.lat);
    if (!mounted) return;
    if (place == null) {
      showToast(context: context, message: "No se pudo determinar la localidad");
      return;
    }
    showToast(context: context, message: place.name, position: Alignment.center);
    final geoJsonPath = Municipalities.resolveGeoJsonRef(place.name);
    if (geoJsonPath == null) {
      showToast(context: context, message: "Municipio no reconocido: ${place.name}");
      return;
    }
    final polygon = await loadGeoJsonPolygon(geoJsonPath);

    final entryPoint = findNearestPointInPolygon(benchmark: _defaultOrigin.coordinates, polygon: polygon);
    final farthestPoint = findFarthestPointInPolygon(benchmark: entryPoint.point, polygon: polygon);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Distancia al municipio(min): ${entryPoint.distance.toStringAsFixed(2)} km"),
        Text("Distancia dentro del municipio: ${farthestPoint.distance.toStringAsFixed(2)} km"),
        Text("Distancia total(max): ${(entryPoint.distance + farthestPoint.distance).toStringAsFixed(2)} km")
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    final cameraOptions = CameraOptions(center: _defaultOrigin, zoom: 13);
    return Scaffold(
      body: MapWidget(
          styleUri: MapboxStyles.STANDARD,
          cameraOptions: cameraOptions,
          onMapCreated: (mapController) {
            // Update some mapbox component
            mapController.location.updateSettings(LocationComponentSettings(enabled: true));
            mapController.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
          },
          onTapListener: (point) => _handleMapTap(point),
        )
    );
  }
}