import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/utils/map/geolocator.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/utils/map/turf.dart';

class MapView extends StatefulWidget {
  const MapView({super.key, this.usingExtendedScaffold = false});

  final bool usingExtendedScaffold;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapboxMap? _mapController;
  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotation? _currentMarker;
  String _selectedOption = 'origin'; // Default to origin

  void _onMapCreated(MapboxMap controller) async {
    // Update some mapbox component
    controller.location
        .updateSettings(LocationComponentSettings(enabled: true));
    controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    _mapController = controller;

    // Create point annotation manager
    _pointAnnotationManager =
        await controller.annotations.createPointAnnotationManager();
  }

  void _onLongTapListener(MapContentGestureContext mapContext) async {
    try {
      // Remove previous marker if exists
      if (_currentMarker != null) {
        await _pointAnnotationManager?.delete(_currentMarker!);
      }

      // Load marker image
      final bytes =
          await rootBundle.load('assets/markers/route/x60/pin_select.png');
      final imageData = bytes.buffer.asUint8List();

      // Create marker options
      final options = PointAnnotationOptions(
          geometry: mapContext.point,
          image: imageData,
          iconAnchor: IconAnchor.BOTTOM);

      // Add new marker
      _currentMarker = await _pointAnnotationManager?.create(options);

      // Show selection menu as popup
      if (mounted) {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;

        final result = await showMenu<String>(
          context: context,
          position: RelativeRect.fromRect(
            Rect.fromPoints(
              Offset(mapContext.touchPosition.x, mapContext.touchPosition.y),
              Offset(mapContext.touchPosition.x, mapContext.touchPosition.y),
            ),
            Offset.zero & overlay.size,
          ),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          items: [
            PopupMenuItem<String>(
              enabled: false,
              height: 6,
              child: Text(
                AppLocalizations.of(context)!.select,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            const PopupMenuDivider(
              indent: 5,
              endIndent: 5,
            ),
            _buildMenuItem(
              title: AppLocalizations.of(context)!.origin,
              value: 'origin',
            ),
            const PopupMenuDivider(
              indent: 5,
              endIndent: 5,
            ),
            _buildMenuItem(
              title: AppLocalizations.of(context)!.destination,
              value: 'destination',
            ),
            const PopupMenuDivider(
              indent: 5,
              endIndent: 5,
            ),
            _buildMenuItem(
              title: AppLocalizations.of(context)!.myMarkers,
              value: 'markers',
            ),
          ],
        );

        if (result != null) {
          setState(() {
            _selectedOption = result;
          });
        }
      }
    } catch (e) {
      debugPrint('Error handling map long tap: $e');
    }
  }

  PopupMenuEntry<String> _buildMenuItem({
    required String title,
    required String value,
  }) {
    final isSelected = _selectedOption == value;
    return PopupMenuItem<String>(
      height: 26,
      value: value,
              child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (isSelected)
              SvgPicture.asset(
                'assets/icons/yellow_check.svg',
                width: 16,
                height: 16,
              ),
          ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraOptions = CameraOptions(
      center: Point(coordinates: Position(-82.3598, 23.1380)),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );
    return Stack(children: [
      MapWidget(
        styleUri: MapboxStyles.STANDARD,
        cameraOptions: cameraOptions,
        onMapCreated: _onMapCreated,
        onLongTapListener: _onLongTapListener,
      ),
      // Find my location
      Positioned(
          right: 20.0,
          bottom: widget.usingExtendedScaffold ? 100.0 : 20.0,
          child: FloatingActionButton(
              heroTag: "fab2",
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              onPressed: () async {
                await requestLocationPermission(
                    context: context,
                    onPermissionGranted: () async {
                      final position = await g.Geolocator.getCurrentPosition();
                      // Check if inside of Havana
                      if (!kDebugMode) {
                        final isInside = GeoBoundaries.isPointInHavana(
                            position.longitude, position.latitude);
                        if (!context.mounted) return;
                        if (!isInside) {
                          showToast(
                              context: context,
                              message: AppLocalizations.of(context)!
                                  .ubicationFailed);
                          return;
                        }
                      }
                      _mapController!.easeTo(
                          CameraOptions(
                              center: Point(
                                  coordinates: Position(
                                      position.longitude, position.latitude))),
                          MapAnimationOptions(duration: 500));
                    },
                    onPermissionDenied: () => showToast(
                        context: context,
                        message:
                            AppLocalizations.of(context)!.permissionsDenied),
                    onPermissionDeniedForever: () => showToast(
                        context: context,
                        message: AppLocalizations.of(context)!
                            .permissionDeniedPermanently));
              },
              child: Icon(Icons.my_location_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: Theme.of(context).iconTheme.size))),
    ]);
  }
}
