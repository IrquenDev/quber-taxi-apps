import 'package:flutter/material.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class CreateDriverAccountPage extends StatefulWidget {
  const CreateDriverAccountPage({super.key});

  @override
  State<CreateDriverAccountPage> createState() => _CreateDriverAccountPageState();
}

class _CreateDriverAccountPageState extends State<CreateDriverAccountPage> {
  int selectedVehicle = 0;
  List<bool> isExpanded = [true, false, false];
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  Widget _vehicleCard({
    required int index,
    required String name,
    required String description,
    required String imageAsset,
  }) {
    bool expanded = isExpanded[index];
    bool selected = selectedVehicle == index;

    return GestureDetector(
      onTap: () => setState(() => selectedVehicle = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryFixed
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(imageAsset, width: 60),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () =>
                      setState(() => isExpanded[index] = !expanded),
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              Text(
                description,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 160, bottom: 80),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surface,
                            child: const Icon(Icons.local_taxi,
                                size: 50, color: Colors.grey),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surface,
                              child: Icon(Icons.add_a_photo,
                                  color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                          'Nombre:', 'Introduzca su nombre y apellidos'),
                      _buildTextField(
                          'Chapa:', 'Escriba la chapa de su vehículo'),
                      _buildTextField('Num. teléfono:', 'Ej: 5566XXXX'),
                      _buildTextField('Número de asientos:', 'Ej: 4'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Licencia de conducción',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      TextButton(
                          onPressed: () {}, child: Text('Adjuntar',style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seleccione su tipo de vehículo:',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(height: 12),
                      _vehicleCard(
                        index: 0,
                        name: 'Estándar',
                        description:
                            'Vehículo compacto con transmisión manual, ideal para traslados cortos. Cuenta con 5 asientos y espacio limitado para equipaje.',
                        imageAsset: 'assets/images/vehicles/xhdpi/standard.png',
                      ),
                      _vehicleCard(
                        index: 1,
                        name: 'Familiar',
                        description:
                            'Vehículo espacioso ideal para familias y traslados grupales. Cuenta con amplio espacio y confort.',
                        imageAsset: 'assets/images/vehicles/xhdpi/familiar.png',
                      ),
                      _vehicleCard(
                        index: 2,
                        name: 'Confort',
                        description:
                            'Vehículo cómodo con características premium, perfecto para traslados ejecutivos.',
                        imageAsset: 'assets/images/vehicles/xhdpi/comfort.png',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildPasswordField('Contraseña', passwordVisible,
                          (v) => setState(() => passwordVisible = v)),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                          'Confirme contraseña:',
                          confirmPasswordVisible,
                          (v) => setState(() => confirmPasswordVisible = v)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular
    (Theme.of(context).extension<DimensionExtension>()!.borderRadius)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.menu),
                      SizedBox(width: 8),
                      Text('Crear Cuenta',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.secondary),),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          onPressed: () {},
          child: Text('Finalizar registro',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
      String label, bool visible, Function(bool) onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          obscureText: !visible,
          decoration: InputDecoration(
            hintText: 'Introduzca la contraseña deseada',
            fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: IconButton(
              icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => onToggle(!visible),
            ),
          ),
        ),
      ],
    );
  }
}
