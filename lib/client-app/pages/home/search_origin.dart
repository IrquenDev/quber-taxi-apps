import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class SearchOriginPage extends StatefulWidget {
  const SearchOriginPage({super.key});

  @override
  State<SearchOriginPage> createState() => _SearchOriginPageState();
}

class _SearchOriginPageState extends State<SearchOriginPage> {
  final _controller = TextEditingController();
  final _mapboxService = MapboxService();

  List<MapboxPlace> _places = [];
  Timer? _debounce;
  bool _isLoading = false;
  bool _isLoadingCurrentLocation = false;

  // Use a 500ms debounce to slow down multiple requests to the Mapbox API during writing.
  void _onTextChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // The case where the query is empty is already being handled. Leaving it here would be a double call with an
      // empty query, for which Mapbox would not return any suggestions.
      if (query.isNotEmpty) {
        _fetchSuggestions(query);
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    // Always check connection status
    if (!hasConnection(context)) return;
    setState(() => _isLoading = true);
    // Fetch Mapbox API suggestions
    final places = await _mapboxService.fetchSuggestions(query);
    if (!mounted) return;
    // Filter places to only show those within Havana boundaries
    final filteredPlaces =
        places.where((place) => GeoBoundaries.isPointInHavana(place.coordinates[0], place.coordinates[1])).toList();
    // Update UI
    setState(() {
      _places = filteredPlaces;
      _isLoading = false;
    });
  }

  Future<void> _loadDefaultSuggestions() async {
    setState(() => _isLoading = true);
    // Load GeoJson Data
    final data = await rootBundle.loadString('assets/geojson/suggestions.json');
    final geoJsonList = json.decode(data) as List<dynamic>;
    // Convert to List<MapboxPlace>
    final suggestions = geoJsonList.map((json) => MapboxPlace.fromJson(json as Map<String, dynamic>)).toList();
    if (!mounted) return;
    // Update UI with the loaded suggestions
    setState(() {
      _places = suggestions;
      _isLoading = false;
    });
  }

  Future<void> _handleCurrentLocationTap() async {
    await requestLocationPermission(
      context: context,
      onPermissionGranted: () async {
        setState(() => _isLoadingCurrentLocation = true);
        try {
          final position = await g.Geolocator.getCurrentPosition();
          if (!kDebugMode) {
            final isInside = GeoBoundaries.isPointInHavana(position.longitude, position.latitude);
            if (!mounted) return;
            if (!isInside) {
              showToast(context: context, message: AppLocalizations.of(context)!.ubicationFailed);
              return;
            }
          }
          final place = await _mapboxService.getMapboxPlace(longitude: position.longitude, latitude: position.latitude);
          if (!mounted) return;
          context.pop(place);
        } catch (e) {
          if (kDebugMode) print('Error getting location: $e');
          if (context.mounted) {
            setState(() => _isLoadingCurrentLocation = false);
            showToast(context: context, message: AppLocalizations.of(context)!.locationError);
          }
        }
      },
      onPermissionDenied: () {
        showToast(context: context, message: AppLocalizations.of(context)!.permissionsDenied);
      },
      onPermissionDeniedForever: () {
        showToast(context: context, message: AppLocalizations.of(context)!.permissionDeniedPermanently);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Use the general suggestions whenever the query is left blank
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        _loadDefaultSuggestions();
      }
    });
    // Fetch general suggestions initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaultSuggestions();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;
    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: colorScheme.surface,
          title: TextField(
            controller: _controller,
            onChanged: hasConnection(context) ? _onTextChanged : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: colorScheme.surface,
              hintText: AppLocalizations.of(context)!.writeUbication,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_outlined),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _places = []);
                      },
                    )
                  : null,
            ),
          ),
          titleSpacing: 0.0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2.0,
          children: [
            // Other Options
            Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(),
              color: colorScheme.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Divider
                  const Divider(height: 1),
                  // Select location from map
                  ListTile(
                    minTileHeight: 48.0,
                    onTap: () async {
                      final mapboxPlace = await context.push<MapboxPlace>(CommonRoutes.locationPicker, extra: true);
                      if (mapboxPlace != null && context.mounted) {
                        context.pop(mapboxPlace);
                      }
                    },
                    contentPadding: const EdgeInsets.only(left: 12.0),
                    minVerticalPadding: 0.0,
                    leading: const Icon(Icons.map_outlined),
                    title: Text(AppLocalizations.of(context)!.selectUbication, style: textTheme.bodyLarge),
                  ),
                  // Use Current Location
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(),
                  ),
                  ListTile(
                    minTileHeight: 48.0,
                    onTap: _isLoadingCurrentLocation ? null : _handleCurrentLocationTap,
                    contentPadding: const EdgeInsets.only(left: 12.0),
                    minVerticalPadding: 0.0,
                    leading: _isLoadingCurrentLocation
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.location_on_outlined),
                    title: Text(AppLocalizations.of(context)!.actualUbication, style: textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
            // Suggestions Section
            Expanded(
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(child: Image.asset("assets/images/background_map.jpg", fit: BoxFit.fill)),
                  // Opacity Shader
                  Positioned.fill(child: ColoredBox(color: Colors.white.withAlpha(200))),
                  // Dynamic Context
                  if (_isLoading)
                    const Positioned.fill(child: Center(child: CircularProgressIndicator()))
                  // Show Suggestions
                  else if (_places.isNotEmpty)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _places.length,
                            itemBuilder: (context, index) {
                              final place = _places[index];
                              return ListTile(
                                titleTextStyle:
                                    Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                title: Text(place.text),
                                subtitle: Text(place.placeName),
                                onTap: () {
                                  context.pop(place);
                                },
                              );
                            }),
                      ),
                    )
                  // No Results
                  else if (_controller.text.isNotEmpty)
                    Positioned.fill(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8.0,
                            children: [
                              Text(localizations.noResultsTitle,
                                  textAlign: TextAlign.center, style: textTheme.bodyLarge),
                              Text(localizations.noResultsMessage,
                                  textAlign: TextAlign.center, style: textTheme.bodyLarge),
                              Text(localizations.noResultsHint, textAlign: TextAlign.center, style: textTheme.bodyLarge)
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
