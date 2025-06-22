import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/mapbox_place.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/routes/route_paths.dart';
import 'package:quber_taxi/util/geolocator.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/util/turf.dart';
import 'package:turf/turf.dart' as turf;

class SearchOrigin extends StatefulWidget {
  const SearchOrigin({super.key});

  @override
  State<SearchOrigin> createState() => _SearchOriginState();
}

class _SearchOriginState extends State<SearchOrigin> {

  final _controller = TextEditingController();
  final _mapboxService = MapboxService();
  late bool isConnected;

  List<MapboxPlace> _suggestions = [];
  Timer? _debounce;
  bool isLoading = false;

  void _onTextChanged(String query) {
    if(query.isEmpty) return;
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

  @override
  void didChangeDependencies() {
    isConnected = NetworkScope.statusOf(context) == ConnectionStatus.online;
    super.didChangeDependencies();
  }

  Future<void> _loadHavanaGeoJson() async {
    _havanaPolygon = await loadGeoJsonPolygon("assets/geojson/polygon/CiudadDeLaHabana.geojson");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status),
      child: Scaffold(
        appBar: AppBar(
            title: TextField(
              controller: _controller,
              onChanged: isConnected ? _onTextChanged : null,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.writeUbication,
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
                  title: Text(AppLocalizations.of(context)!.selectUbication),
                  onTap: () async {
                    final mapboxPlace = await context.push<MapboxPlace>(RoutePaths.locationPicker);
                    if(mapboxPlace != null) {
                      if(!context.mounted) return;
                      context.pop(mapboxPlace);
                    }
                  }
              ),
              ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text(AppLocalizations.of(context)!.actualUbication),
                  onTap: () async {
                    await requestLocationPermission(
                    context: context,
                    onPermissionGranted: () async {
                      setState(() => isLoading = true);
                      final position = await g.Geolocator.getCurrentPosition();
                      if (!kDebugMode) {
                        // Check if inside of Havana
                        final isInside = isPointInPolygon(position.longitude, position.latitude, _havanaPolygon);
                        if(!context.mounted) return;
                        if(!isInside) {
                          showToast(
                              context: context,
                              message: AppLocalizations.of(context)!.ubicationFailed
                          );
                          setState(() => isLoading = false);
                          return;
                        }
                      }
                      final mapboxPlace = await _mapboxService.getMapboxPlace(
                          longitude: position.longitude, latitude: position.latitude
                      );
                      setState(() => isLoading = false);
                      if(!context.mounted) return;
                      context.pop(mapboxPlace);
                    },
                    onPermissionDenied: () => showToast(context: context, message: AppLocalizations.of(context)!.permissionsDenied),
                    onPermissionDeniedForever: () =>
                        showToast(context: context, message: AppLocalizations.of(context)!.permissionDeniedPermanently)
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
                            onTap: () => context.pop(mapboxPlace),
                          );
                        }
                    )
                ),
              if(_suggestions.isEmpty && _controller.text.isNotEmpty)
                Padding(padding: const EdgeInsets.all(20.0), child: Text(AppLocalizations.of(context)!.noResults),
                ),
              if(isLoading)
                CircularProgressIndicator()
            ]
        )
      ),
    );
  }
}