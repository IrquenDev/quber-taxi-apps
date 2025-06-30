import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
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
                  onPressed: () => setState(() => isExpanded[index] = !expanded),
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Container(color: Colors.white),

          // Header
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(dimensions.borderRadius)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.createAccountTitle,
                        style: textTheme.titleLarge?.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.only(top: 60, bottom: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -50,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: colorScheme.onPrimary,
                                    child: SvgPicture.asset(
                                      "assets/icons/taxi.svg",
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: colorScheme.surface,
                                      child: SvgPicture.asset(
                                        "assets/icons/camera.svg",
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Column(
                          children: [
                            const SizedBox(height: 70), // Espacio para el avatar
                            _buildTextField(AppLocalizations.of(context)!.nameLabel, AppLocalizations.of(context)!.nameHint,),
                            _buildTextField(AppLocalizations.of(context)!.plateLabel, AppLocalizations.of(context)!.plateHint,),
                            _buildTextField(AppLocalizations.of(context)!.phoneLabel, AppLocalizations.of(context)!.phoneHint,),
                            _buildTextField(AppLocalizations.of(context)!.seatsLabel,AppLocalizations.of(context)!.seatsHint,),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                        AppLocalizations.of(context)!.licenseLabel,
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                              color: colorScheme.secondary),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            side: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () {},
                          child: Text(
                              AppLocalizations.of(context)!.attachButton,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        AppLocalizations.of(context)!.vehicleTypeLabel,,
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                              color: colorScheme.secondary),
                        ),
                        const SizedBox(height: 12),
                        _vehicleCard(
                          index: 0,
                          name: AppLocalizations.of(context)!.standardVehicle,
                          description:
                          AppLocalizations.of(context)!.standardDescription,
                          imageAsset: 'assets/images/vehicles/xhdpi/standard.png',
                        ),
                        _vehicleCard(
                          index: 1,
                          name: AppLocalizations.of(context)!.familyVehicle,
                          description:
                          AppLocalizations.of(context)!.familyDescription,
                          imageAsset: 'assets/images/vehicles/xhdpi/familiar.png',
                        ),
                        _vehicleCard(
                          index: 2,
                          name: AppLocalizations.of(context)!.comfortVehicle,
                          description:
                            AppLocalizations.of(context)!.comfortDescription,
                          imageAsset: 'assets/images/vehicles/xhdpi/comfort.png',
                        ),
                      ],
                    ),
                  ),


                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildPasswordField(AppLocalizations.of(context)!.passwordLabel, passwordVisible,
                                (v) => setState(() => passwordVisible = v)),
                        const SizedBox(height: 12),
                        _buildPasswordField(
    AppLocalizations.of(context)!.confirmPasswordLabel,
                            confirmPasswordVisible,
                                (v) => setState(() => confirmPasswordVisible = v)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero),
          ),
          onPressed: () {},
          child: Text(
    AppLocalizations.of(context)!.finishButton,
            style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer),
          ),
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
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 18,
                color: Colors.black),
          ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Theme.of(context).colorScheme.onPrimary,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: Colors.white54,
                      width: 0.1
                  )
              ),
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
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        TextField(
          obscureText: !visible,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.onPrimary,
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
              ),
              onPressed: () => onToggle(!visible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.surfaceDim,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
