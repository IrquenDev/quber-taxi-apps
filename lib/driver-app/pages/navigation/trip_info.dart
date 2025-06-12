import 'package:flutter/material.dart';
import 'package:quber_taxi/driver-app/pages/navigation/emergency_dialog.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class TripInfoBottomOverlay extends StatefulWidget {
  const TripInfoBottomOverlay({super.key});

  @override
  State<TripInfoBottomOverlay> createState() => _TripInfoBottomOverlayState();
}

class _TripInfoBottomOverlayState extends State<TripInfoBottomOverlay> {
  bool isGuidedRouteEnabled = false;

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final mediaHeight = MediaQuery.of(context).size.height;
    final overlayHeight = isGuidedRouteEnabled
        ? mediaHeight * 0.45
        : mediaHeight * 0.35;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.borderRadius)),
      child: SizedBox(
        height: overlayHeight,
        child: Stack(
          children: [
            // Background Layer
            Positioned.fill(
              child: Container(color: Theme.of(context).colorScheme.primaryContainer),
            ),

            // Distance & Price Info
            Positioned(
              top: 0.0,
              right: 0.0,
              left: 0.0,
              child: Padding(
                padding: EdgeInsets.only(top: 16.0, left: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text('DISTANCIA:'), Text('PRECIO:')],
                    ),
                    SizedBox(width: 16.0),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      child: Column(children: [Text('20,3 Km'), Text('150 CUP')]),
                    ),
                  ],
                ),
              ),
            ),

            // Origin & Destination + SOS Btn + Guided Route Section
            Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.borderRadius)),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryFixed,
                      ),
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: const [
                                  Icon(Icons.my_location, size: 20, color: Colors.grey),
                                  Icon(Icons.more_vert, size: 14, color: Colors.grey),
                                  Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                                ],
                              ),
                              SizedBox(width: 12.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Desde: ',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(text: 'Calle 25 entre Paseo y 2. Vedado'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.0),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Hasta: ',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(text: 'Playa'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.0),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ruta guiada',
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: isGuidedRouteEnabled,
                                activeColor: Theme.of(context).colorScheme.primaryFixedDim,
                                onChanged: (val) => setState(() => isGuidedRouteEnabled = val),
                              ),
                            ],
                          ),
                          if (isGuidedRouteEnabled) ...[
                            Text('Ruta exacta', style: Theme.of
                              (context).textTheme.bodyMedium),
                            SizedBox(height: 8.0),
                            TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.location_on_outlined),
                                hintText: 'Seleccione la direccion de destino',
                                suffixIcon: Icon(Icons.search),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          padding: dimensions.contentPadding,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Theme.of(context).colorScheme.errorContainer.withAlpha(200),
                          builder: (context) => EmergencyDialog(),
                        ),
                        child: Text(
                          'Emergencia (SOS)',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Taxi Type Image
            Positioned(
              right: 16,
              top: 20,
              child: SizedBox(
                height: 80,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0),
                  child: Image.asset('assets/images/vehicles/v3/standard.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
