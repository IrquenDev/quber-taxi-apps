import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart' show CircleStack;
import 'package:quber_taxi/common/models/travel.dart';

class DriverTripCompleted extends StatefulWidget {

  final Travel travel;
  final int duration;
  final num distance;
  const DriverTripCompleted({super.key, required this.travel, required this.duration, required this.distance});

  @override
  State<DriverTripCompleted> createState() => _DriverTripCompletedState();
}

class _DriverTripCompletedState extends State<DriverTripCompleted> {

  final double _horizontalPadding = 20.0;
  final double _highHorizontalPadding = 40.0;

  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
            child: Column(
                spacing: 16.0,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8.0,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header Section
                          Column(
                              spacing: 8.0,
                              children: [
                                // Client & Driver Profile Images
                                CircleStack(
                                    count: 2, radius: 40.0, offset: 20.0,
                                    prototypeBuilder: (index) =>
                                        Image.asset('assets/images/splash_driver.png', fit: BoxFit.cover)
                                ),
                                // Title
                                Text(
                                    'Viaje Finalizado',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                                // Timestamp
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: _highHorizontalPadding),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        spacing: 8.0,
                                        children: [
                                          Text(
                                              'Fecha',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.bold
                                              )
                                          ),
                                          Text('Martes, 20 de mayo de 2025'),
                                        ]
                                    )
                                )
                              ]
                          ),
                          const Divider(),
                          // Comment & Reviews Section
                          Column(
                              spacing: 8.0,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TripDetailRow(
                                    label: 'Precio del Viaje',
                                    text: '${(widget.distance * 100).toStringAsFixed(0)} CUP'
                                ),
                                TripDetailRow(
                                    label: 'Tiempo Transcurrido',
                                    text: '${widget.duration.toStringAsFixed(0)} minutos'
                                ),
                                TripDetailRow(
                                    label: 'Distancia Recorrida',
                                    text: '${widget.distance.toStringAsFixed(0)} Km'
                                ),
                                TripDetailRow(label: 'Origen', text: widget.travel.originName),
                                TripDetailRow(label: 'Destino', text: widget.travel.destinationName),
                                const TripDetailRow(label: 'Comisión para Quber', text: '90 CUP'),
                              ]
                          )
                        ]
                    ),
                  ),
                  // Accept Button
                  SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                          style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder())
                          ),
                          onPressed: () {},
                          child:  Text(
                            'Aceptar',
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16),
                          )
                      )
                  )
                ]
            )
        )
    );
  }
}

class TripDetailRow extends StatelessWidget {

  final String label;
  final String text;

  const TripDetailRow({super.key, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
        spacing: 8.0,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(text)
        ]
    );
  }
}
