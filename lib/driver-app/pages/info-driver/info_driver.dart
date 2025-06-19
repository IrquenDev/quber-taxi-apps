import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

class DriverInfoPage extends StatelessWidget {
  const DriverInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9; // Ancho común para todas las cards

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              height: MediaQuery.of(context).size.height * 0.37,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu, color: colorScheme.shadow),
                        const SizedBox(width: 15),
                        Text(
                          AppLocalizations.of(context)!.driverInfoTitle,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.shadow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/driver.png',
                          fit: BoxFit.cover,
                          width: 110,
                          height: 110,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Raúl Gómez',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.shadow,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '+53 55555555',
                      style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.shadow,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido superpuesto (todas las cards juntas)
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40, // Superposición sobre el header
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        // Card de valoración
                        SizedBox(
                          width: cardWidth,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.zero),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.averageRating,
                                    style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey.shade800,
                                        fontSize: 14

                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildStarRating(4.0),
                                      const SizedBox(width: 10),
                                      Text(
                                        '4.0',
                                        style: textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Card de chapa
                        SizedBox(
                          width: cardWidth,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.zero),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.vehiclePlate,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'P56739U',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                      fontSize: 20,

                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Card de asientos
                        SizedBox(
                          width: cardWidth,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.zero),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.seatNumber,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '4',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                      fontSize: 20,

                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Card de tipo de vehículo
                        SizedBox(
                          width: cardWidth,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.vehicleType,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!.familyVehicle,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                            fontSize: 20,
                                          ),

                                        ),
                                      ),
                                      Image.asset(
                                        'assets/images/vehicles/v1/familiar.png',
                                        height: 60,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Botón Aceptar
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.acceptButton,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SvgPicture.asset(
            index < rating.floor()
                ? 'assets/icons/yelow_star.svg'
                : 'assets/icons/gray_star.svg',
            height: 28,
          ),
        );
      }),
    );
  }
}