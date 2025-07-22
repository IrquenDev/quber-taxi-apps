import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';

class TravelInfoSheet extends StatelessWidget {

  final Travel travel;
  final void Function() onPickUpConfirmationRequest;

  const TravelInfoSheet({super.key, required this.travel, required this.onPickUpConfirmationRequest});

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card Header
          Card(
            margin: EdgeInsets.zero,
            color: colorScheme.surfaceContainer,
            elevation: dimensions.elevation,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Client Profile Image
                  CircleAvatar(
                    radius: 16.8,
                    backgroundColor: colorScheme.primaryContainer,
                                          child: Icon(
                        Icons.person,
                        size: 19.2,
                        color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Client's Name & Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(travel.client.name, style: textTheme.titleMedium),
                        const SizedBox(height: 8.0),
                        Text(
                          travel.client.phone,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      ]
                    )
                  ),
                  // Contact Icon
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.phone,
                      color: colorScheme.primary,
                    ),
                  )
                ]
              )
            )
          ),
          const SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Travel Origin
                Row(
                  children: [
                    Icon(
                      Icons.my_location, 
                      color: colorScheme.primary,
                      size: 19.2,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        travel.originName,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ]
                ),
                const SizedBox(height: 8.0),
                // Travel Destination
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined, 
                      color: colorScheme.error,
                      size: 19.2,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        travel.destinationName,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                // Additional Info
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localizations.countPeople} ${travel.requiredSeats}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${localizations.pet} ${travel.hasPets ? localizations.withPet : localizations.withoutPet}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${localizations.typeVehicle} ${TaxiType.nameOf(travel.taxiType, localizations)}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ]
                  )
                )
              ]
            )
                            ),
                  const SizedBox(height: 12.0),
          // Start Travel Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
              ),
              onPressed: hasConnection(context) ? () {
                WebSocketService.instance.send(
                    "/app/travels/${travel.id}/pick-up-confirmation", null // no body needed
                );
                onPickUpConfirmationRequest.call();
              } : null,
              child: Text(
                localizations.startTrip,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              )
            )
          )
        ]
      )
    );
  }
}