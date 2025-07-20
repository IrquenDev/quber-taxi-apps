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
    final localizations = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: dimensions.elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.borderRadius)),
      color: _isExpanded 
        ? Theme.of(context).colorScheme.primaryFixed 
        : Theme.of(context).colorScheme.surfaceContainerHigh,
      child: InkWell(
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
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
                padding: dimensions.contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Always visible: Origin and Destination
                    Padding(
                      padding: const EdgeInsets.only(right: 40), // Space for the icon
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Origin - Large icon
                          _buildIconTextRow(context, 'assets/icons/radio_button_checked_line.svg', 'Desde: ${widget.travel.originName}', iconSize: 40),
                          
                          // Destination - Large icon  
                          _buildIconTextRow(context, 'assets/icons/location_line.svg', 'Hasta: ${widget.travel.destinationName}', iconSize: 40),
                        ],
                      ),
                    ),
                    
                    // Expandable content
                    if (_isExpanded) ...[
                      // Distance Min - Standard icon
                      _buildIconTextRow(context, 'assets/icons/t_guiones.svg', 'Distancia Mínima: ${widget.travel.minDistance}km', startPadding: 8),
                      
                      // Distance Max - Standard icon
                      _buildIconTextRow(context, 'assets/icons/t_guiones.svg', 'Distancia Máxima: ${widget.travel.maxDistance}km', startPadding: 8),
                      
                      // Price Min - Standard icon
                      _buildIconTextRow(context, 'assets/icons/t_guiones.svg', 'Precio mínimo que puede costar: ${widget.travel.minPrice.toStringAsFixed(0)} CUP', startPadding: 8),
                      
                      // Price Max - Standard icon
                      _buildIconTextRow(context, 'assets/icons/t_guiones.svg', 'Precio máximo que puede costar: ${widget.travel.maxPrice.toStringAsFixed(0)} CUP', startPadding: 8),
                      
                      // People - Standard icon row
                      _buildStandardIconRow(context, Icons.people, '${widget.travel.requiredSeats} personas'),
                      
                      // Pets - Standard icon row
                      _buildStandardIconRow(context, Icons.pets, widget.travel.hasPets ? 'Con mascota' : 'Sin mascota'),
                      
                      const SizedBox(height: 16),
                      
                      // Accept button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: hasConnection(context) ? () async {
                            // ConfirmDialog
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => const ConfirmDialog(
                                title: 'Aceptar Viaje',
                                message: "Se le notificará al cliente que se ha aceptado su solicitud de viaje. Su ubicación se"
                                    " comenzará a compartir solo con él.",
                              )
                            );

                            if (result == true) {
                              if(!context.mounted) return;
                              // Ask for location permission
                              await g_util.requestLocationPermission(
                                  context: context,
                                  onPermissionGranted: () async => widget.onTravelSelected.call(widget.travel),
                                  onPermissionDenied: () => showToast(context: context, message: "Para comenzar a compartir su"
                                  " ubicación con el cliente se necesita su acceso explícito"),
                                  onPermissionDeniedForever: () => showToast(context: context, message: "Permiso de ubicación "
                                  "bloqueado. Habilitar nuevamente en ajustes")
                              );
                            }
                          } : null,
                          child: const Text('Aceptar')
                        )
                      ),
                    ],
                  ],
                ),
              ),
              
              // Expansion indicator - Always positioned at top right
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurface,
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
              Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStandardIconRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Fixed width container to align with SVG icons
        SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}