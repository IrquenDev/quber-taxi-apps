import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/widgets/dialogs/confirm_dialog.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/map/geolocator.dart' as g_util;
import 'package:quber_taxi/utils/runtime.dart';

class TripCard extends StatelessWidget {

  final Travel travel;
  final void Function(Travel) onTravelSelected;

  const TripCard({super.key, required this.travel, required this.onTravelSelected});

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Card(
      elevation: dimensions.elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.borderRadius)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(dimensions.borderRadius))
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(dimensions.borderRadius))),
          tilePadding: dimensions.contentPadding,
          childrenPadding: dimensions.contentPadding,
          collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          backgroundColor: Theme.of(context).colorScheme.primaryFixed,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.0,
            children: [
              _buildIconLabelRow(context, Icons.my_location_outlined, AppLocalizations.of(context)!.from, travel.originName),
              _buildIconLabelRow(context, Icons.location_on_outlined, AppLocalizations.of(context)!.until, travel.destinationName),
            ],
          ),
          children: [
            _buildInfoRow(Icons.straighten, '${AppLocalizations.of(context)!.minDistance} ${travel.minDistance} km'),
            _buildInfoRow(Icons.straighten, '${AppLocalizations.of(context)!.maxDistance} ${travel.maxDistance} km'),
            _buildInfoRow(Icons.attach_money, '${AppLocalizations.of(context)!.minPrice} ${travel.minPrice.toStringAsFixed(0)} CUP'),
            _buildInfoRow(Icons.money, '${AppLocalizations.of(context)!.maxPrice} ${travel.maxPrice.toStringAsFixed(0)} CUP'),
            _buildInfoRow(Icons.people, '${travel.requiredSeats} ${AppLocalizations.of(context)!.people}'),
            _buildInfoRow(Icons.pets, travel.hasPets ? 'Con mascota' : 'Sin mascota'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
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
                        onPermissionGranted: () async => onTravelSelected.call(travel),
                        onPermissionDenied: () => showToast(context: context, message: "Para comenzar a compartir su"
                        " ubicación con el cliente se necesita su acceso explícito"),
                        onPermissionDeniedForever: () => showToast(context: context, message: "Permiso de ubicación "
                        "bloqueado. Habilitar nuevamente en ajustes")
                    );
                  }
                } : null,
                child: const Text('Aceptar')
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildIconLabelRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      spacing: 8.0,
      children: [
        Icon(icon),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        spacing: 8.0,
        children: [Icon(icon), Expanded(child: Text(text))]
      )
    );
  }
}