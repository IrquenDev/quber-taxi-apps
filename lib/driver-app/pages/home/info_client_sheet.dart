import 'package:flutter/material.dart';
import 'package:quber_taxi/driver-app/pages/home/home.dart';

class InfoClientSheet extends StatelessWidget {
  final String nombreCompleto;
  final String telefono;
  final String direccionDesde;
  final String direccionHasta;
  final int cantidadPersonas;
  final bool conMascota;
  final String tipoVehiculo;
  final String urlImagen; // Puede ser local o de red

  const InfoClientSheet({
    super.key,
    required this.nombreCompleto,
    required this.telefono,
    required this.direccionDesde,
    required this.direccionHasta,
    required this.cantidadPersonas,
    required this.conMascota,
    required this.tipoVehiculo,
    required this.urlImagen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Card con foto y datos
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Foto
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(urlImagen), // O AssetImage
                  ),
                  const SizedBox(width: 12),
                  // Nombre y teléfono
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombreCompleto,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(telefono, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  // Icono llamar
                  IconButton(
                    onPressed: () {
                      // Acción para llamar
                    },
                    icon: const Icon(Icons.call, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dirección desde
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.my_location, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text(direccionDesde)),
            ],
          ),

// Puntos verticales decorativos alineados a la izquierda
          Row(
            children: [
              const SizedBox(width: 4),
              // Mismo ancho que el ícono + su padding
              Column(
                children: List.generate(
                  3,
                  (index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Icon(Icons.more_vert, size: 14, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),

// Dirección hasta
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text(direccionHasta)),
            ],
          ),

          const SizedBox(height: 16),

          // Info adicional
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cantidad de personas que viajan: $cantidadPersonas'),
                Text('Mascota: ${conMascota ? 'Sí' : 'No'}'),
                Text('Tipo de vehículo: $tipoVehiculo'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botón Iniciar Viaje
          WideYellowButton(
            text: 'Iniciar Viaje',
            onPressed: () {
              // Acción al iniciar viaje
            },
          ),
        ],
      ),
    );
  }
}
