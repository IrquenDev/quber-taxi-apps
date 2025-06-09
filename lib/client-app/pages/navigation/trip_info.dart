import 'package:flutter/material.dart';
import 'package:quber_taxi/client-app/pages/navigation/show_emergency_dialog.dart';

class TripInfoBottomOverlay extends StatelessWidget {
  const TripInfoBottomOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        elevation: 12,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Row(
                          children: [
                            Text('DISTANCIA',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme
                                        .secondary)),
                            SizedBox(width: 6),
                            Text('20,3 Km',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme
                                        .secondary)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('PRECIO',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.secondary)),
                            SizedBox(width: 6),
                            Text('150 CUP',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme
                                    .secondary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryFixed,
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: const [
                            Icon(Icons.my_location, size: 20, color: Colors.grey),
                            Icon(Icons.more_vert, size: 14, color: Colors.grey),
                            Icon(Icons.location_on_outlined,
                                size: 20, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Desde: ',
                                    style: TextStyle(fontWeight: FontWeight
                                        .bold, color: Theme.of(context).colorScheme.secondary)),
                                TextSpan(text: 'Calle 25 entre Paseo y 2. '
                                    'Vedado', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                              ])),
                              SizedBox(height: 10),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: 'Hasta: ',
                                    style: TextStyle(fontWeight: FontWeight
                                        .bold, color: Theme.of(context).colorScheme.secondary)),
                                TextSpan(text: 'Playa', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                              ])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () {
                        showEmergencyDialog(context);
                      },
                      child: Text(
                        'Emergencia (SOS)',
                        style: TextStyle(color: Theme.of(context).colorScheme
                            .onSecondary),
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                right: 16,
                top: 50,
                child: SizedBox(
                  height: 90,
                  child: Image.asset(
                    'assets/images/vehicles/v3/standard.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}