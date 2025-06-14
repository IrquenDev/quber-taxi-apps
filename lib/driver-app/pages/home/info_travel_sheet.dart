import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class TravelInfoSheet extends StatelessWidget {

  final Travel travel;

  const TravelInfoSheet({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {
    final dimension = Theme.of(context).extension<DimensionExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, right: 12.0, left: 12.0),
      child: Column(
        spacing: 16.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card Header
          Card(
            margin: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.surfaceContainer,
            elevation: dimension.elevation,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimension.borderRadius * 0.5)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                spacing: 24.0, // matches left padding
                children: [
                  // @Temporal Client Profile Image
                  CircleAvatar(radius: 28.0),
                  // Client's Name & Phone
                  Expanded(
                    child: Column(
                      spacing: 4.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(travel.client.name, style: Theme.of(context).textTheme.titleMedium),
                        Text(travel.client.phone)
                      ]
                    )
                  ),
                  // Contact Icon
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset("assets/icons/phone.png"),
                  )
                ]
              )
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              spacing: 8.0,
              children: [
                // Travel Origin
                Row(
                  spacing: 8.0,
                  children: [const Icon(Icons.my_location), Text(travel.originName)]
                ),
                // Travel Destination
                Row(
                  spacing: 8.0,
                  children: [const Icon(Icons.location_on_outlined), Text(travel.destinationName),],
                ),
                // Additional Info
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    spacing: 4.0,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${AppLocalizations.of(context)!.countPeople} ${travel.requiredSeats}'),
                      Text('${AppLocalizations.of(context)!.pet} ${travel.hasPets ? 'Sí' : 'No'}'),
                      Text('${AppLocalizations.of(context)!.typeVehicle} ${travel.taxiType.displayText}'),
                    ]
                  )
                )
              ]
            )
          ),
          // Start Travel Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: Text(AppLocalizations.of(context)!.startTrip),
              onPressed: () => showToast(context: context, message: "Iniciara el viaje: Dialog -> Vista de Navegacion")
            ),
          )
        ]
      )
    );
  }
}