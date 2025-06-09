import 'package:flutter/material.dart';
import 'package:quber_taxi/common/widgets/circle_stack.dart';

class TripCompletedBottomSheet extends StatefulWidget {
  const TripCompletedBottomSheet({super.key});

  @override
  State<TripCompletedBottomSheet> createState() => _TripCompletedBottomSheetState();
}

class _TripCompletedBottomSheetState extends State<TripCompletedBottomSheet> {

  final TextEditingController _commentController = TextEditingController();

  // Profile Image
  final double _profileImagesRadius = 40.0;
  final double _circleIntersection = 20.0;

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
                          overlayDirection: OverlayDirection.rightToLeft,
                          count: 2, radius: 40.0, offset: 20.0,
                          prototypeBuilder: (index) =>
                              Image.asset('assets/images/vehicles/v1/standard.png', fit: BoxFit.cover)
                      ),
                      // Title
                      Text(
                          'Viaje Finalizado',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
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
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
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
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.0,
                    children: [
                      Text(
                        'Tu opinión nos ayuda a mejorar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                          '(Califica el viaje con 1 a 5 estrellas)',
                          style: Theme.of(context).textTheme.bodySmall
                      ),
                      // Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < selectedRating ? Icons.star : Icons.star_border,
                              color: Theme.of(context).colorScheme.primaryContainer
                            ),
                            onPressed: () {
                              setState(() => selectedRating = index + 1);
                            }
                          );
                        }),
                      ),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Ayúdanos a mejorar dejando tu opinión',
                          suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: () {})
                        )
                      ),
                      // Comment history
                      Padding(
                        padding: EdgeInsets.only(left: _horizontalPadding),
                        child: Row(
                          spacing: 20.0,
                          children: [
                            // People who commented
                            CircleStack(
                              count: 4,
                              radius: 16,
                              offset: 8,
                              prototypeBuilder: (index) =>
                                  Image.asset('assets/images/vehicles/v1/standard.png', fit: BoxFit.cover)
                            ),
                            Text(
                              '3 comentarios',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            )
                          ]
                        )
                      )
                    ]
                  ),
                  const Divider(),
                  Column(
                    spacing: 8.0,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TripDetailRow(label: 'Precio del Viaje', text: '1150 CUP'),
                      const TripDetailRow(label: 'Tiempo del Recorrido', text: '35 minutos'),
                      const TripDetailRow(label: 'Distancia Recorrida', text: '50 Km'),
                      const TripDetailRow(label: 'Origen', text: 'Calle 25 entre Paseo y 2. Vedado'),
                      const TripDetailRow(label: 'Destino', text: 'Calle 31 entre 43 y 45. Playa'),
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
