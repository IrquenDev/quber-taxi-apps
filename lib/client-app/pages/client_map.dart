import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as g;
import 'package:quber_taxi/util/geolocator.dart';

class ClientMap extends StatefulWidget {

  const ClientMap({super.key, this.position});

  final Position? position;

  @override
  State<ClientMap> createState() => _ClientMapState();
}

class _ClientMapState extends State<ClientMap> {

  // Default m3  BottomAppBar height. The length of the curved space under a centered FAB coincides with this value.
  final _bottomAppBarHeight = 80.0;
  late Position _position;
  MapboxMap? _mapController;

  @override
  void initState() {
    super.initState();
    _position = widget.position ?? Position(-82.3598, 23.1380); // National Capitol
  }

  @override
  Widget build(BuildContext context) {

    final cameraOptions = CameraOptions(
      center: Point(coordinates: _position),
      pitch: 45,
      bearing: 0,
      zoom: 17,
    );

    return StatusBarController(
      systemUiMode: SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      builder: (_) => Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            MapWidget(
              styleUri: MapboxStyles.STANDARD,
              cameraOptions: cameraOptions,
              onMapCreated: (mapboxMap) {
                // Update some mapbox component
                mapboxMap.location.updateSettings(LocationComponentSettings(enabled: true));
                mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
                _mapController = mapboxMap;
              },
            ),
            // Find my location
            Positioned(
                right: 20.0, bottom: _bottomAppBarHeight + 20.0,
                child: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () async {
                      await requestLocationPermission(
                        context: context,
                        onPermissionGranted: () async {
                          final position = await g.Geolocator.getCurrentPosition();
                          _mapController!.easeTo(
                              CameraOptions(center: Point(coordinates: Position(position.longitude, position.latitude))),
                              MapAnimationOptions(duration: 500)
                          );
                        },
                        onPermissionDenied: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Permiso de ubicación denegado")),
                          );
                        },
                        onPermissionDeniedForever: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Permiso de ubicación denegado permanentemente")),
                          );
                        },
                      );
                    },
                    child: Icon(
                        Icons.my_location_outlined,
                        color: Theme.of(context).iconTheme.color,
                        size: Theme.of(context).iconTheme.size
                    )
                )
            )
          ]
        ),
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              // Declaración fuera del builder para conservar el estado
              final fromController = TextEditingController();
              final toController = TextEditingController();
              final passengerCount = ValueNotifier<int>(1);
              final selectedVehicle = ValueNotifier<String>('Estándar');
              final hasPet = ValueNotifier<bool>(false);

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pestaña superior fija
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              margin: const EdgeInsets.only(top: 8, bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          // Botón cerrar arriba a la derecha
                          Row(
                            children: [
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),

                          // Fila con íconos y campos de texto
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Íconos verticales
                              Column(
                                children: [
                                  const Icon(Icons.my_location, color: Colors.grey),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.location_on_outlined, color: Colors.grey),
                                ],
                              ),
                              const SizedBox(width: 10),

                              // Campos de texto
                              Expanded(
                                child: Column(
                                  children: [
                                    // Origen
                                    ValueListenableBuilder(
                                      valueListenable: fromController,
                                      builder: (context, value, _) {
                                        return TextField(
                                          controller: fromController,
                                          decoration: InputDecoration(
                                            hintText: "Seleccione el municipio de origen",
                                            border: InputBorder.none,
                                            suffixIcon: fromController.text.isNotEmpty
                                                ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () => fromController.clear(),
                                            )
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                    const Divider(height: 1),
                                    // Destino
                                    TextField(
                                      controller: toController,
                                      decoration: const InputDecoration(
                                        hintText: "Seleccione el municipio de destino",
                                        border: InputBorder.none,
                                        suffixIcon: Icon(Icons.search),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Encabezado
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "¿Qué tipo de vehículo prefiere?",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 10),

// Lista horizontal de cards
                          SizedBox(
                            height: 150, // Altura suficiente para el texto y la imagen
                            child: ValueListenableBuilder<String>(
                              valueListenable: selectedVehicle,
                              builder: (context, selected, _) {
                                final vehicles = [
                                  {'type': 'Estándar', 'image': 'assets/images/v1/estandar_car.png'},
                                  {'type': 'Familiar', 'image': 'assets/images/v1/family_car.png'},
                                  {'type': 'Confort', 'image': 'assets/images/v1/confort_car.png'},
                                ];

                                return ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: vehicles.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 30),
                                  itemBuilder: (context, index) {
                                    final vehicle = vehicles[index];
                                    final isSelected = selected == vehicle['type'];

                                    return GestureDetector(
                                      onTap: () => selectedVehicle.value = vehicle['type']!,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          border: isSelected
                                              ? Border.all(color: Colors.amber, width: 2)
                                              : Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Título
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text("vehículo", style: TextStyle(fontSize: 12, color: Colors.black54)),
                                                if (isSelected)
                                                  Container(
                                                    decoration: const BoxDecoration(
                                                      color: Colors.amber,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    padding: const EdgeInsets.all(2),
                                                    child: const Icon(Icons.check, size: 14, color: Colors.black),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            // Tipo
                                            Text(
                                              vehicle['type']!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            // Imagen
                                            Expanded(
                                              child: Image.asset(
                                                vehicle['image']!,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Cuántas personas viajan
                          Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Text("¿Cuántas personas viajan?", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (passengerCount.value > 1) {
                                          passengerCount.value--;
                                        }
                                      },
                                      icon: const Icon(Icons.remove_circle_outline),
                                    ),
                                    ValueListenableBuilder<int>(
                                      valueListenable: passengerCount,
                                      builder: (context, value, _) {
                                        return Text(
                                          "$value",
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () => passengerCount.value++,
                                      icon: const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ¿Lleva mascota?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("¿Lleva mascota?", style: TextStyle(fontWeight: FontWeight.bold)),
                              ValueListenableBuilder<bool>(
                                valueListenable: hasPet,
                                builder: (context, value, _) {
                                  return Switch(
                                    value: value,
                                    activeColor: Colors.amber,
                                    onChanged: (v) => hasPet.value = v,
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Estimaciones
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Distancia mínima:"),
                              Text("8km", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Distancia máxima:"),
                              Text("15km", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Precio mínimo que puede costar:"),
                              Text("600 CUP", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Precio máximo que puede costar:"),
                              Text("1100 CUP", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Botón "Pedir taxi"
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Aquí va tu lógica para enviar la solicitud
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.amber,
                              ),
                              child: const Text("Pedir taxi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Icon(
              Icons.local_taxi,
              color: Theme.of(context).iconTheme.color,
              size: Theme.of(context).iconTheme.size
          )
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 12.0,
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            spacing: _bottomAppBarHeight,
            children: [
              Flexible(flex: 1, child: Center(child: _BottomBarItem(icon: Icons.location_on, label: 'Mapa'))),
              Flexible(flex: 1, child: Center(child: _PointsDisplay())),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {

  final IconData icon;
  final String label;

  const _BottomBarItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        Text(label)
      ]
    );
  }
}

class _PointsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('56'),
        Text('Puntos Quber')
      ]
    );
  }
}