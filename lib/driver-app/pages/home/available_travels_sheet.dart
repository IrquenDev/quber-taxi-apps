import 'package:flutter/material.dart';
import 'package:quber_taxi/driver-app/pages/home/trip_card.dart';

class AvailableTravelsSheet extends StatefulWidget {
  const AvailableTravelsSheet({super.key});

  @override
  State<AvailableTravelsSheet> createState() => _AvailableTravelsSheetState();
}

class _AvailableTravelsSheetState extends State<AvailableTravelsSheet> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  double _currentSize = 0.15;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(() {
      _currentSize = _sheetController.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      expand: false,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final dragAmount = -details.primaryDelta! / screenHeight;
                  final newSize = (_currentSize + dragAmount).clamp(0.1, 0.9);
                  _sheetController.jumpTo(newSize);
                },
                child: Column(
                  children: [
                    // Draggable Header
                    ClipPath(
                      clipper: DoubleTopCurvedClipper(),
                      child: Container(
                        height: 80,
                        color: Colors.amber.shade600,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8.0,
                          children: const [
                            Icon(Icons.keyboard_double_arrow_down, color: Colors.black),
                            Text(
                              "Seleccione un viaje", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                            )
                          ]
                        )
                      )
                    ),
                    // Drag Handler
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))
                    )
                  ]
                )
              ),
              // Scrollable Mocked List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: const [
                    TripCard(
                      desde: 'Calle 25 entre Paseo y 2. Vedado',
                      hasta: 'La Lisa',
                      distanciaMin: 3,
                      distanciaMax: 15,
                      precioMin: 150,
                      precioMax: 1150,
                      personas: 2,
                      conMascota: true,
                    ),
                    SizedBox(height: 12),
                    TripCard(
                      desde: 'Calle 3 y 4. Centro Habana',
                      hasta: 'Playa',
                      distanciaMin: 4,
                      distanciaMax: 12,
                      precioMin: 200,
                      precioMax: 950,
                      personas: 3,
                      conMascota: false,
                    ),
                    TripCard(
                      desde: 'Calle 25 entre Paseo y 2. Vedado',
                      hasta: 'La Lisa',
                      distanciaMin: 3,
                      distanciaMax: 15,
                      precioMin: 150,
                      precioMax: 1150,
                      personas: 2,
                      conMascota: true,
                    ),
                    SizedBox(height: 12),
                    TripCard(
                      desde: 'Calle 3 y 4. Centro Habana',
                      hasta: 'Playa',
                      distanciaMin: 4,
                      distanciaMax: 12,
                      precioMin: 200,
                      precioMax: 950,
                      personas: 3,
                      conMascota: false,
                    ),
                    TripCard(
                      desde: 'Calle 25 entre Paseo y 2. Vedado',
                      hasta: 'La Lisa',
                      distanciaMin: 3,
                      distanciaMax: 15,
                      precioMin: 150,
                      precioMax: 1150,
                      personas: 2,
                      conMascota: true,
                    ),
                    SizedBox(height: 12),
                    TripCard(
                      desde: 'Calle 3 y 4. Centro Habana',
                      hasta: 'Playa',
                      distanciaMin: 4,
                      distanciaMax: 12,
                      precioMin: 200,
                      precioMax: 950,
                      personas: 3,
                      conMascota: false,
                    ),
                  ],
                ),
              ),
            ]
          )
        );
      }
    );
  }
}

// 🔁 Clipper que hace que tanto el borde superior como el inferior sean "superiores"
class DoubleTopCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 20.0;
    final path = Path();

    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    path.lineTo(size.width, size.height - radius);

    path.quadraticBezierTo(size.width, size.height - 2 * radius, size.width - radius, size.height - 2 * radius);
    path.lineTo(radius, size.height - 2 * radius);
    path.quadraticBezierTo(0, size.height - 2 * radius, 0, size.height - radius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}