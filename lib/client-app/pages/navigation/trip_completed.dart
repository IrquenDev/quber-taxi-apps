import 'package:flutter/material.dart';

class TripCompletedBottomSheet extends StatefulWidget {
  const TripCompletedBottomSheet({super.key});

  @override
  State<TripCompletedBottomSheet> createState() => _TripCompletedBottomSheetState();
}

class _TripCompletedBottomSheetState extends State<TripCompletedBottomSheet> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme
            .surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            SizedBox(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children:  [
                  Transform.translate(
                    offset: Offset(18, 0),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage('assets/images/vehicles/v1/standard.png'),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(-18, 0),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage
                        ('assets/images/vehicles/v1/comfort.png'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text('Viaje Finalizado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Fecha',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme
                        .secondary)),
                SizedBox(width: 8),
                Text('Martes, 20 de mayo de 2025',
                    style: TextStyle(color: Theme.of(context).colorScheme
                        .secondary)),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            const Text(
              'Tu opinión nos ayuda a mejorar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('(Califica el viaje con 1 a 5 estrellas)',
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme
                    .secondary)),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Theme.of(context).colorScheme
                        .primaryContainer,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Ayúdanos a mejorar dejando tu opinión',
                filled: true,
                fillColor: Theme.of(context).colorScheme
                    .surface,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.grey),
                  onPressed: () {
                    print('Comentario enviado: ${commentController.text}');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: const [
                      Positioned(
                        left: 48,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                          AssetImage('assets/images/vehicles/v1/standard.png'),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                          AssetImage('assets/images/vehicles/v1/standard.png'),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                          AssetImage('assets/images/vehicles/v1/standard.png'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  '3 comentarios',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const Divider(height: 32, thickness: 1),
            const SizedBox(height: 24),

            const TripDetailRow(title: 'Precio del Viaje', value: '1150 CUP'),
            const TripDetailRow(title: 'Tiempo del Recorrido', value: '35 minutos'),
            const TripDetailRow(title: 'Distancia Recorrida', value: '50 Km'),
            const TripDetailRow(title: 'Origen', value: 'Calle 25 entre Paseo y 2. Vedado'),
            const TripDetailRow(title: 'Destino', value: 'Calle 31 entre 43 y 45. Playa'),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme
                      .primaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  print('Estrellas: $selectedRating');
                  print('Comentario: ${commentController.text}');
                  Navigator.pop(context);
                },
                child:  Text(
                  'Aceptar',
                  style: TextStyle(color: Theme.of(context).colorScheme
                      .secondary, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TripDetailRow extends StatelessWidget {
  final String title;
  final String value;

  const TripDetailRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme
                  .secondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
