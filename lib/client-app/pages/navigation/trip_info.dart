import 'package:flutter/material.dart';
import 'package:quber_taxi/common/widgets/emergency_dialog.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class ClientTripInfo extends StatelessWidget {

  final num distance;

  const ClientTripInfo({super.key, required this.distance});

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final mediaHeight = MediaQuery.of(context).size.height;
    final overlayHeight = mediaHeight * 0.25; // 25% of screen height
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.borderRadius)),
      child: SizedBox(
        height: overlayHeight,
        child: Stack(
          children: [
            // Background Layer
            Positioned.fill(child: Container(color: Theme.of(context).colorScheme.primaryContainer)),
            // Distance & Price Info
            Positioned(
              top: 0.0, right: 0.0, left: 0.0,
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16.0,
                      children:  [
                        Column(
                          spacing: 4.0,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text('DISTANCIA:'), Text('PRECIO:')]
                        ),
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                            child: Column(children: [Text('${distance.toStringAsFixed(2)} Km'), Text('150 CUP')])
                        )
                      ]
                  )
                )
            ),
            // Origin & Destination + SOS Btn
            Positioned(
              bottom: 0.0, right: 0.0, left: 0.0,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.borderRadius)),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryFixed,
                      ),
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12.0,
                        children: [
                          // Icons
                          Column(
                            children: const [
                              Icon(Icons.my_location, size: 20, color: Colors.grey),
                              Icon(Icons.more_vert, size: 14, color: Colors.grey),
                              Icon(Icons.location_on_outlined, size: 20, color: Colors.grey)
                            ]
                          ),
                          // Origin & Destination Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12.0,
                            children: [
                              Text.rich(
                                  TextSpan(
                                      children: [
                                        TextSpan(
                                            text: 'Desde: ',
                                            style: Theme.of(context).textTheme.bodyMedium!
                                                .copyWith(fontWeight: FontWeight.bold)),
                                        TextSpan(text: 'Calle 25 entre Paseo y 2. Vedado')
                                      ]
                                  )
                              ),
                              Text.rich(
                                  TextSpan(
                                      children: [
                                        TextSpan(
                                            text: 'Hasta: ',
                                            style: Theme.of(context).textTheme.bodyMedium!
                                                .copyWith(fontWeight: FontWeight.bold)),
                                        TextSpan(text: 'Playa')
                                      ]
                                  )
                              )
                            ]
                          )
                        ]
                      )
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
                          barrierColor:Theme.of(context).colorScheme.errorContainer.withAlpha(200),
                          builder: (context) => EmergencyDialog()
                        ),
                        child: Text(
                            'Emergencia (SOS)',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSecondary,
                            )
                        )
                      )
                    )
                  ]
                )
              )
            ),
            // Taxi Type Image
            Positioned(
              right: 16, top: 20,
              child: SizedBox(
                height: 80,
                child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(-1.0, 1.0),
                    child: Image.asset('assets/images/vehicles/xhdpi/standard.png')
                )
              )
            )
          ]
        )
      )
    );
  }
}