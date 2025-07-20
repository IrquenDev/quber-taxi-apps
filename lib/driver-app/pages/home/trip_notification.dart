import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class TripNotification extends StatelessWidget {

  final Travel travel;
  final VoidCallback onDismissed;
  final int index;
  final DateTime createdAt;

  TripNotification({
    super.key,
    required this.travel,
    required this.onDismissed,
    required this.index,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;
    final surface = colorScheme.surface;
    final opacity = index == 0 ? 230 : 180;

    return Dismissible(
      key: ValueKey(travel.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) => onDismissed(),
        child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.1),
                    blurRadius: dimensions.elevation,
                    offset: Offset(1, dimensions.elevation),
                  ),
                ],
                color: surface.withAlpha(opacity),
                borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall)
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.newTrip, style: textTheme.titleMedium),
                          Row(
                              children: [
                                Icon(
                                    Icons.my_location_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                    size: (textTheme.bodyMedium?.fontSize ?? 14) * 1.2
                                ),
                                const SizedBox(width: 4.0),
                                Flexible(
                                  child: RichText(
                                      text: TextSpan(
                                          style: textTheme.bodySmall,
                                          children: [
                                            TextSpan(
                                              text: localizations.from, 
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                            ),
                                            TextSpan(text: travel.originName)
                                          ]
                                      )
                                  )
                                )
                              ]
                          ),
                          Row(
                              children: [
                                Icon(
                                    Icons.location_on_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                    size: (textTheme.bodyMedium?.fontSize ?? 14) * 1.2
                                ),
                                const SizedBox(width: 4.0),
                                Flexible(
                                  child: RichText(
                                      text: TextSpan(
                                          style: textTheme.bodySmall,
                                          children: [
                                            TextSpan(
                                              text: localizations.until, 
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                            ),
                                            TextSpan(text: travel.destinationName)
                                          ]
                                      )
                                  ),
                                )
                              ]
                          )
                        ]
                    ),
                  ),
                  Column(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                        ),
                        Text(
                          DateFormat('h:mm a').format(createdAt),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      ]
                  )
                ]
            )
        )
    );
  }
}