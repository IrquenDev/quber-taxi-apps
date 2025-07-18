import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class TripNotification extends StatelessWidget {

  final Travel travel;
  final VoidCallback onDismissed;
  final int index;

  const TripNotification({
    super.key,
    required this.travel,
    required this.onDismissed,
    required this.index
  });

  @override
  Widget build(BuildContext context) {

    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final surface = Theme.of(context).colorScheme.surface;
    final opacity = index == 0 ? 230 : 100;

    return Dismissible(
      key: ValueKey(travel.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) => onDismissed(),
        child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
                    blurRadius: 4,
                    offset: const Offset(1, 4),
                  ),
                ],
                color: surface.withAlpha(opacity),
                borderRadius: BorderRadius.circular(dimensions.borderRadius)
            ),
            child: Row(
                spacing: 4.0,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                        spacing: 8.0,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nuevo Viaje', style: Theme.of(context).textTheme.titleMedium),
                          Row(
                              spacing: 8.0,
                              children: [
                                Icon(
                                    Icons.my_location_outlined,
                                    color: Colors.grey,
                                    size: Theme.of(context).iconTheme.size! * 0.75
                                ),
                                Flexible(
                                  child: RichText(
                                      text: TextSpan(
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          children: [
                                            const TextSpan(text: 'Desde: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(text: travel.originName)
                                          ]
                                      )
                                  )
                                )
                              ]
                          ),
                          Row(
                              spacing: 8.0,
                              children: [
                                Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.grey,
                                    size: Theme.of(context).iconTheme.size! * 0.75
                                ),
                                Flexible(
                                  child: RichText(
                                      text: TextSpan(
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          children: [
                                            const TextSpan(text: 'Hasta: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      children: [Icon(Icons.notifications_outlined), Text("5:59 pm")]
                  )
                ]
            )
        )
    );
  }
}