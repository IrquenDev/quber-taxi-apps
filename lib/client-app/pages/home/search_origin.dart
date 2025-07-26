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
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/utils/map/geolocator.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/utils/map/turf.dart';
import 'package:quber_taxi/utils/runtime.dart';
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
  List<MapboxPlace> _popularPlaces = [];
  Timer? _debounce;
  bool isLoading = false;
  bool isLoadingPopularPlaces = false;

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
    _loadPopularPlaces();
  }

  Future<void> _loadHavanaGeoJson() async {
    _havanaPolygon = await loadGeoJsonPolygon("assets/geojson/polygon/CiudadDeLaHabana.geojson");
  }

  Future<void> _loadPopularPlaces() async {
    if (kDebugMode) {
      print('Starting to load popular places...');
    }
    
    setState(() => isLoadingPopularPlaces = true);
    
    try {
      
      final places = await _mapboxService.fetchSuggestions('C');
      
      setState(() {
        _popularPlaces = places.take(15).toList();
        isLoadingPopularPlaces = false;
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('Error loading popular places: $e');
      }
      setState(() => isLoadingPopularPlaces = false);
    }
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
              onChanged: hasConnection(context) ? _onTextChanged : null,
              decoration: InputDecoration(
                fillColor: Theme.of(context).colorScheme.surface,
                hintText: AppLocalizations.of(context)!.writeUbication,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  suffixIcon: _controller.text.isNotEmpty ?
                    IconButton(icon: const Icon(Icons.clear_outlined), onPressed: () {
                      _controller.clear();
                      setState(() => _suggestions = []);
                    }) : null,
              )
            )
        ),
        body: Column(
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Divider(height: 1),
                    ListTile(
                        leading: Icon(Icons.map_outlined),
                        title: Text(AppLocalizations.of(context)!.selectUbication),
                        onTap: () async {
                          final mapboxPlace = await context.push<MapboxPlace>(CommonRoutes.locationPicker);
                          if(mapboxPlace != null) {
                            if(!context.mounted) return;
                            context.pop(mapboxPlace);
                          }
                        }
                    ),
                    Divider(height: 1),
                    ListTile(
                        leading: isLoading ? CircularProgressIndicator() : Icon(Icons.location_on_outlined),
                        title: Text(AppLocalizations.of(context)!.actualUbication),
                        onTap: () async {
                          try {
                            await requestLocationPermission(
                            context: context,
                            onPermissionGranted: () async {
                              setState(() => isLoading = true);
                              try {
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
                                if(!context.mounted) return;
                                setState(() => isLoading = false);
                                context.pop(mapboxPlace);
                              } catch (e) {
                                if (kDebugMode) {
                                  print('Error getting location: $e');
                                }
                                if(context.mounted) {
                                  setState(() => isLoading = false);
                                  showToast(
                                    context: context,
                                    message: AppLocalizations.of(context)!.locationError
                                  );
                                }
                              }
                            },
                            onPermissionDenied: () {
                              setState(() => isLoading = false);
                              showToast(context: context, message: AppLocalizations.of(context)!.permissionsDenied);
                            },
                            onPermissionDeniedForever: () {
                              setState(() => isLoading = false);
                              showToast(context: context, message: AppLocalizations.of(context)!.permissionDeniedPermanently);
                            }
                            );
                          } catch (e) {
                            if (kDebugMode) {
                              print('Error requesting permission: $e');
                            }
                            setState(() => isLoading = false);
                          }
                        }),
                  ],
                ),
              ),
              if(_suggestions.isNotEmpty || (_suggestions.isEmpty && _controller.text.isEmpty && _popularPlaces.isNotEmpty))
                Expanded(
                    child: ListView.builder(
                        itemCount: _suggestions.isNotEmpty ? _suggestions.length : _popularPlaces.length,
                        itemBuilder: (context, index) {
                          final mapboxPlace = _suggestions.isNotEmpty ? _suggestions[index] : _popularPlaces[index];
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
              if(_suggestions.isEmpty && _controller.text.isEmpty && _popularPlaces.isEmpty && isLoadingPopularPlaces)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ]
        )
      ),
    );
  }
}