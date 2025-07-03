import 'package:flutter/material.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';

class TravelInfoSheet extends StatelessWidget {

  final Travel travel;
  final void Function() onPickUpConfirmationRequest;

  const TravelInfoSheet({super.key, required this.travel, required this.onPickUpConfirmationRequest});

  @override
  Widget build(BuildContext context) {
    final isConnected = NetworkScope.statusOf(context) == ConnectionStatus.online;
    final dimension = Theme.of(context).extension<DimensionExtension>()!;
    final localizations = AppLocalizations.of(context)!;
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
                      Text('${localizations.standardVehicle} ${travel.requiredSeats}'),
                      Text('${localizations.pet} ${travel.hasPets ? 'Sí' : 'No'}'),
                      Text('${localizations.typeVehicle} ${TaxiType.nameOf(travel.taxiType, localizations)
                      }'),
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
              onPressed: isConnected ? () {
                WebSocketService.instance.send(
                    "/app/travels/${travel.id}/pick-up-confirmation", null // no body needed
                );
                onPickUpConfirmationRequest.call();
              } : null,
              child: Text(localizations.startTrip)
            )
          )
        ]
      )
    );
  }
}