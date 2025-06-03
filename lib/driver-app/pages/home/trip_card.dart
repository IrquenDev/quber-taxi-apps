import 'package:flutter/material.dart';
import 'package:quber_taxi/driver-app/pages/home/info_client_sheet.dart';

class TripCard extends StatefulWidget {
  final String desde;
  final String hasta;
  final double distanciaMin;
  final double distanciaMax;
  final double precioMin;
  final double precioMax;
  final int personas;
  final bool conMascota;

  const TripCard({
    super.key,
    required this.desde,
    required this.hasta,
    required this.distanciaMin,
    required this.distanciaMax,
    required this.precioMin,
    required this.precioMax,
    required this.personas,
    required this.conMascota,
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Línea de íconos con puntos
            Column(
              children: [
                const Icon(Icons.my_location,size: 20, color: Colors.grey),
                ...List.generate(
                  2,
                      (index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Icon(Icons.more_vert, size: 12, color: Colors.grey),
                  ),
                ),
                const Icon(Icons.location_on_outlined,size: 20, color: Colors.grey),
                if (isExpanded)
                  ...List.generate(
                    9,
                        (index) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Icon(Icons.more_vert, size: 12, color: Colors.grey),
                    ),
                  ),
                if (isExpanded) const Icon(Icons.people, size: 20, color: Colors.black),
                if (isExpanded) const Icon(Icons.pets, size: 20, color: Colors.black),
              ],
            ),
            const SizedBox(width: 12),

            // Columna de texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desde + botón expandir
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Desde: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: widget.desde,
                                style: const TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      text: 'Hasta: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: widget.hasta,
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),

                  if (isExpanded) ...[
                    const SizedBox(height: 8),
                    Text('Distancia Mínima: ${widget.distanciaMin} km'),
                    Text('Distancia Máxima: ${widget.distanciaMax} km'),
                    Text('Precio mínimo que puede costar: ${widget.precioMin.toStringAsFixed(0)} CUP'),
                    Text('Precio máximo que puede costar: ${widget.precioMax.toStringAsFixed(0)} CUP'),
                    const SizedBox(height: 4),
                    Text('${widget.personas} personas'),
                    Text(widget.conMascota ? 'Con mascota' : 'Sin mascota'),
                  ],

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const InfoClientSheet(
                            nombreCompleto: 'Esmeralda Pérez',
                            telefono: '+53 56748383',
                            direccionDesde: 'Calle 25 entre Paseo y 2. Vedado',
                            direccionHasta: 'Playa',
                            cantidadPersonas: 2,
                            conMascota: true,
                            tipoVehiculo: 'Confort',
                            urlImagen: 'https://cristypalacios.com/wp-content/uploads/2022/11/10-Poses-para-foto-de-Perfil-Profesional-Mujer-04-2022-11-819x1024.jpg', // o 'assets/avatar.png'
                          ),
                        );

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
