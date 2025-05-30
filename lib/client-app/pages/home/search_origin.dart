import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:quber_taxi/common/models/mapbox_place.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';
import 'package:quber_taxi/common/widgets/location_picker.dart';
import 'package:quber_taxi/util/geolocator.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/util/turf.dart';
import 'package:turf/turf.dart' as turf;

class SearchOriginPage extends StatefulWidget {
  const SearchOriginPage({super.key});

  @override
  State<SearchOriginPage> createState() => _SearchOriginPageState();
}

class _SearchOriginPageState extends State<SearchOriginPage> {

  final _controller = TextEditingController();
  final _mapboxService = MapboxService();

  List<MapboxPlace> _suggestions = [];
  Timer? _debounce;
  bool isLoading = false;

  void _onTextChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final suggestions = await _mapboxService.fetchSuggestions(query);
      setState(() {_suggestions = suggestions;});
    });
  }

  late turf.Polygon _havanaPolygon;

  @override
  void initState() {
    super.initState();
    _loadHavanaGeoJson();
  }

  Future<void> _loadHavanaGeoJson() async {
    _havanaPolygon = await loadGeoJsonPolygon("assets/geojson/CiudadDeLaHabana.geojson");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: TextField(
            controller: _controller,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
                hintText: 'Escribe una ubicación...',
                suffixIcon: _controller.text.isNotEmpty ?
                  IconButton(icon: const Icon(Icons.clear_outlined), onPressed: () {
                    _controller.clear();
                    setState(() => _suggestions = []);
                  }) : null
            )
          )
      ),
      body: Column(
          children: [
            ListTile(
                leading: Icon(Icons.map_outlined),
                title: Text("Seleccione ubicación desde el mapa"),
                onTap: () async {
                  final mapboxPlace = await Navigator.of(context).push<MapboxPlace>(
                      MaterialPageRoute(builder: (context)=> LocationPicker())
                  );
                  if(mapboxPlace != null) {
                    if(!context.mounted) return;
                    Navigator.of(context).pop(mapboxPlace);
                  }
                }
            ),
            ListTile(
                leading: Icon(Icons.location_on_outlined),
                title: Text("Usar mi ubicación actual"),
                onTap: () async {
                  await requestLocationPermission(
                  context: context,
                  onPermissionGranted: () async {
                    setState(() => isLoading = true);
                    final position = await g.Geolocator.getCurrentPosition();
                    // Check if inside of Havana
                    final isInside = isPointInPolygon(position.longitude, position.latitude, _havanaPolygon);
                    if(!context.mounted) return;
                    if(!isInside) {
                      showToast(
                          context: context,
                          message: "Su ubicacion actual esta fuera de los limites de La"" Habana"
                      );
                      return;
                    }
                    final mapboxPlace = await _mapboxService.getMapboxPlace(
                        longitude: position.longitude, latitude: position.latitude
                    );
                    setState(() => isLoading = false);
                    if(!context.mounted) return;
                    Navigator.of(context).pop(mapboxPlace);
                  },
                  onPermissionDenied: () => showToast(context: context, message: "Permiso de ubicación denegado"),
                  onPermissionDeniedForever: () =>
                      showToast(context: context, message: "Permiso de ubicación denegado permanentemente")
                  );
                }),
            if(_suggestions.isNotEmpty)
              Expanded(
                  child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final mapboxPlace = _suggestions[index];
                        return ListTile(
                          titleTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          title: Text(mapboxPlace.text),
                          subtitle: Text(mapboxPlace.placeName),
                          onTap: () => Navigator.of(context).pop(mapboxPlace),
                        );
                      }
                  )
              ),
            if(_suggestions.isEmpty && _controller.text.isNotEmpty)
              Padding(padding: const EdgeInsets.all(20.0), child: Text("Sin resultados"),
              ),
            if(isLoading)
              CircularProgressIndicator()
          ]
      )
    );
  }
}