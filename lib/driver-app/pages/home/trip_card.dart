import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/widgets/dialogs/confirm_dialog.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/map/geolocator.dart' as g_util;

class TripCard extends StatefulWidget {
  final Travel travel;
  final void Function(Travel) onTravelSelected;

  const TripCard({super.key, required this.travel, required this.onTravelSelected});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isConnected = NetworkScope.statusOf(context) == ConnectionStatus.online;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;

    return Card(
      elevation: dimensions.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
      ),
      child: Padding(
        padding: dimensions.contentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parte superior (siempre visible)
            GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Column(

                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconLabelRow(
                      context,
                      'assets/icons/radio_button_checked_line.svg',
                      _buildDashedLine(),
                      AppLocalizations.of(context)!.from,
                      widget.travel.originName
                  ),
                  _buildIconLabelRow(
                      context,
                      'assets/icons/location_line.svg',
                      null,
                      AppLocalizations.of(context)!.until,
                      widget.travel.destinationName
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 0),
                  //   child: AnimatedRotation(
                  //     duration: const Duration(milliseconds: 300),
                  //     turns: isExpanded ? 0.5 : 0,
                  //     child: const Icon(Icons.keyboard_arrow_down, size: 24),
                  //   ),
                  // ),

                  if(!isExpanded)
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: isConnected ? () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => const ConfirmDialog(
                                  title: 'Aceptar Viaje',
                                  message: "Se le notificará al cliente que se ha aceptado su solicitud de viaje. Su ubicación se"
                                      " comenzará a compartir solo con él.",
                                ),
                              );

                              if (result == true) {
                                if(!context.mounted) return;
                                await g_util.requestLocationPermission(
                                  context: context,
                                  onPermissionGranted: () async => widget.onTravelSelected.call(widget.travel),
                                  onPermissionDenied: () => showToast(
                                      context: context,
                                      message: "Para comenzar a compartir su ubicación con el cliente se necesita su acceso explícito"
                                  ),
                                  onPermissionDeniedForever: () => showToast(
                                      context: context,
                                      message: "Permiso de ubicación bloqueado. Habilitar nuevamente en ajustes"
                                  ),
                                );
                              }
                            } : null,
                            child: const Text('Aceptar'),
                          ),
                        ),
                      ],
                    )
                ],

              ),
            ),

            // Parte expandible (detalles)
            if (isExpanded)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow(
                      'assets/icons/t_guiones.svg',
                      _buildDashedLine(),
                      '${AppLocalizations.of(context)!.minDistance} ${widget.travel.minDistance} km'
                  ),
                  _buildInfoRow(
                      'assets/icons/t_guiones.svg',
                      _buildDashedLine(),
                      '${AppLocalizations.of(context)!.maxDistance} ${widget.travel.maxDistance} km'
                  ),
                  _buildInfoRow(
                      'assets/icons/t_guiones.svg',
                      _buildDashedLine(),
                      '${AppLocalizations.of(context)!.minPrice} ${widget.travel.minPrice.toStringAsFixed(0)} CUP'
                  ),
                  _buildInfoRow(
                      'assets/icons/t_guiones.svg',
                      null,
                      '${AppLocalizations.of(context)!.maxPrice} ${widget.travel.maxPrice.toStringAsFixed(0)} CUP'
                  ),
                  const SizedBox(height: 8),
                  _buildIconRow(
                      'assets/icons/people.svg',
                      null,
                      '${widget.travel.requiredSeats} ${AppLocalizations.of(context)!.people}'
                  ),
                  const SizedBox(height: 12),
                  _buildIconRow(
                      'assets/icons/pets.svg',
                      null,
                      widget.travel.hasPets ? 'Con mascota' : 'Sin mascota'
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: isConnected ? () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => const ConfirmDialog(
                            title: 'Aceptar Viaje',
                            message: "Se le notificará al cliente que se ha aceptado su solicitud de viaje. Su ubicación se"
                                " comenzará a compartir solo con él.",
                          ),
                        );

                        if (result == true) {
                          if(!context.mounted) return;
                          await g_util.requestLocationPermission(
                            context: context,
                            onPermissionGranted: () async => widget.onTravelSelected.call(widget.travel),
                            onPermissionDenied: () => showToast(
                                context: context,
                                message: "Para comenzar a compartir su ubicación con el cliente se necesita su acceso explícito"
                            ),
                            onPermissionDeniedForever: () => showToast(
                                context: context,
                                message: "Permiso de ubicación bloqueado. Habilitar nuevamente en ajustes"
                            ),
                          );
                        }
                      } : null,
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconLabelRow(BuildContext context, String icon, Widget? dashedLine, String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Container(
                      width: 34.0,
                      height: 34.0,
                      child: SvgPicture.asset(
                        icon,
                      ),
                    ),
                Expanded(
                   child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.shadow,
                          ),
                        ),
                        Text(
                          value,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ),
              ],
            ),
    );
  }

  Widget _buildDashedLine() {
    return Container(
      margin: const EdgeInsets.only(left: 0, right: 1.0, top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
                (index) => Container(
                  width: 1.5,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildInfoRow(String icon, Widget? dashedLine, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 24.0,
                child: SvgPicture.asset(
                  icon,
                ),
              ),
            ],
          ),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildIconRow(String icon, Widget? dashedLine, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 34.0,
            height: 24.0,
            child: Center(
              child: SvgPicture.asset(
                icon,
                height: 18.0,
                width: 18.0,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}