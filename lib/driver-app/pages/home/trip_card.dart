import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/widgets/dialogs/confirm_dialog.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/map/geolocator.dart' as g_util;
import 'package:quber_taxi/utils/runtime.dart';

class TripCard extends StatefulWidget {

  final Travel travel;
  final void Function(Travel) onTravelSelected;

  const TripCard({super.key, required this.travel, required this.onTravelSelected});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: dimensions.elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusMedium)),
      color: _isExpanded 
        ? Theme.of(context).colorScheme.primaryFixed 
        : Theme.of(context).colorScheme.surfaceContainerHigh,
      child: InkWell(
        borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusMedium),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Always visible: Origin and Destination
                    Padding(
                      padding: const EdgeInsets.only(right: 24.0), // Space for the icon
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Origin - Large icon
                          _buildIconTextRow(
                              context,
                              'assets/icons/radio_button_checked_line.svg',
                              localizations.fromLocation(widget.travel.originName),
                              iconSize: 40
                          ),
                          // Destination - Large icon  
                          _buildIconTextRow(
                              context,
                              'assets/icons/location_line.svg',
                              localizations.toLocation(widget.travel.destinationName),
                              iconSize: 40
                          ),
                        ],
                      ),
                    ),
                    // Expandable content
                    if (_isExpanded) ...[
                      // Distance Fixed - Standard icon
                      if(widget.travel.fixedDistance != null)
                        _buildIconTextRow(
                            context,
                            'assets/icons/t_guiones.svg',
                            localizations.distanceFixed(widget.travel.fixedDistance.toString()),
                            startPadding: 8
                        ),
                      // Distance Min - Standard icon
                      if(widget.travel.minDistance != null)
                      _buildIconTextRow(
                          context,
                          'assets/icons/t_guiones.svg',
                          localizations.distanceMinimum(widget.travel.minDistance.toString()),
                          startPadding: 8
                      ),
                      // Distance Max - Standard icon
                      if(widget.travel.maxDistance != null)
                      _buildIconTextRow(
                          context,
                          'assets/icons/t_guiones.svg',
                          localizations.distanceMaximum(widget.travel.maxDistance.toString()),
                          startPadding: 8
                      ),
                      // Price Fixed - Standard icon
                      if(widget.travel.fixedPrice != null)
                        _buildIconTextRow(
                            context,
                            'assets/icons/t_guiones.svg',
                            localizations.priceFixedCost(widget.travel.fixedPrice.toString()),
                            startPadding: 8
                        ),
                      // Price Min - Standard icon
                      if(widget.travel.minPrice != null)
                      _buildIconTextRow(
                          context,
                          'assets/icons/t_guiones.svg',
                          localizations.priceMinimumCost(widget.travel.minPrice!.toStringAsFixed(0)),
                          startPadding: 8
                      ),
                      // Price Max - Standard icon
                      if(widget.travel.maxPrice != null)
                      _buildIconTextRow(
                          context,
                          'assets/icons/t_guiones.svg',
                          localizations.priceMaximumCost(widget.travel.maxPrice!.toStringAsFixed(0)),
                          startPadding: 8
                      ),
                      // People - Standard icon row
                      _buildStandardIconRow(
                          context, Icons.people,
                          localizations.peopleCount(widget.travel.requiredSeats.toString())
                      ),
                      // Pets - Standard icon row
                      _buildStandardIconRow(
                          context, Icons.pets,
                          widget.travel.hasPets ? localizations.withPet : localizations.withoutPet
                      ),
                      const SizedBox(height: 12.0),
                      // Accept button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                            ),
                          ),
                          onPressed: hasConnection(context) ? () async {
                            // ConfirmDialog
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => ConfirmDialog(
                                title: localizations.acceptTrip,
                                message: localizations.acceptTripConfirmMessage,
                              )
                            );

                            if (result == true) {
                              if(!context.mounted) return;
                              // Ask for location permission
                              await g_util.requestLocationPermission(
                                  context: context,
                                  onPermissionGranted: () async => widget.onTravelSelected.call(widget.travel),
                                  onPermissionDenied: () => showToast(context: context, message: localizations.locationPermissionRequired),
                                  onPermissionDeniedForever: () => showToast(context: context, message: localizations.locationPermissionBlocked)
                              );
                            }
                          } : null,
                          child: Text(localizations.accept)
                        )
                      ),
                    ],
                  ],
                ),
              ),
              
              // Expansion indicator - Always positioned at top right
              Positioned(
                          top: 8.0,
          right: 8.0,
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.expand_more,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconTextRow(BuildContext context, String svgAsset, String text, {double iconSize = 24, double startPadding = 0}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: startPadding),
        // Fixed width container to align all icons
        Center(
          child: SvgPicture.asset(
            svgAsset,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStandardIconRow(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Fixed width container to align with SVG icons
        SizedBox(
          width: 24.0,
          height: 24.0,
          child: Center(
            child: Icon(
              icon,
              size: 19.2,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}