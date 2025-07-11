import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/enums/asset_dpi.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

class DriverInfoPage extends StatefulWidget {
  final int driverId;

  const DriverInfoPage({super.key, required this.driverId});

  @override
  State<DriverInfoPage> createState() => _DriverInfoPageState();
}

class _DriverInfoPageState extends State<DriverInfoPage> {
  final accountService = AccountService();
  late Future<Driver> futureDriver;

  void _loadDriverInfo() async {
    setState(() {
      // TODO("yapmDev @Fix")
      // - This is not the way to get user info, at this point is enough with Driver.fromJson(loggedInUser)
      // futureDriver = await accountService.findDriver(widget.driverId);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            FutureBuilder<Driver>(
              future: futureDriver,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.37,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.37,
                    child: Center(child: Text('Error al cargar datos del conductor')),
                  );
                }

                final driver = snapshot.data!;
                return Container(
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
                            IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back), color: Theme.of(context).colorScheme.shadow),
                            const SizedBox(width: 15),
                            Text(
                              localizations.driverInfoTitle,
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/splash_driver.png',
                              fit: BoxFit.cover,
                              width: 110,
                              height: 110,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          driver.name,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.shadow,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Cards
            Expanded(
              child: FutureBuilder<Driver>(
                future: futureDriver,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final driver = snapshot.data!;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -40,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            // Card de valoración
                            SizedBox(
                              width: cardWidth,
                              child: Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.zero),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.averageRating,
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildStarRating(driver.rating),
                                          const SizedBox(width: 10),
                                          Text(
                                            driver.rating.toStringAsFixed(1),
                                            style: textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
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
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.zero),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.vehiclePlate,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        driver.taxi.plate,
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
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.zero),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.seatNumber,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        driver.taxi.seats.toString(),
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
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(10)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.vehicleType,
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
                                              TaxiType.nameOf(driver.taxi.type, AppLocalizations.of(context)!),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade800,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            driver.taxi.type.assetRef(AssetDpi.mdpi),
                                            height: 60,
                                          )
                                        ]
                                      )
                                    ]
                                  )
                                )
                              )
                            )
                          ]
                        )
                      )
                    ]
                  );
                }
              )
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
                    AppLocalizations.of(context)!.goBack,
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
