import 'package:flutter/material.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class Driver {
  final String name;
  final String phone;
  final String image;
  final DriverStatus status;

  Driver({
    required this.name,
    required this.phone,
    required this.image,
    required this.status,
  });
}

enum DriverStatus { approved, pending, blocked }

class DriversListPage extends StatelessWidget {
  const DriversListPage({super.key});

  Icon _buildStatusIcon(DriverStatus status, BuildContext context) {
    final color = Theme.of(context).colorScheme.primaryContainer;
    switch (status) {
      case DriverStatus.approved:
        return Icon(Icons.verified_user, color: color);
      case DriverStatus.pending:
        return Icon(Icons.access_time, color: color);
      case DriverStatus.blocked:
        return Icon(Icons.lock, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = Theme.of(context).extension<DimensionExtension>()?.borderRadius ?? 20.0;
    final colorScheme = Theme.of(context).colorScheme;

    final List<Driver> drivers = [
      Driver(name: 'Alejandro', phone: '+53557555575', image: 'assets/images/vehicles/hdpi/comfort.png', status: DriverStatus.approved),
      Driver(name: 'José', phone: '+53557555575', image: 'assets/images/vehicles/hdpi/comfort.png', status: DriverStatus.approved),
      Driver(name: 'Manuel', phone: '+53557555575', image: 'assets/images/vehicles/hdpi/comfort.png', status: DriverStatus.blocked),
      Driver(name: 'Pedro', phone: '+53557555575', image: 'assets/images/vehicles/hdpi/comfort.png', status: DriverStatus.pending),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 140, left: 16, right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: drivers.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage(driver.image),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          driver.name,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      _buildStatusIcon(driver.status, context),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    driver.phone,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Aprobar',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Bloquear',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          Container(
            height: 140,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
              boxShadow: const [
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
                    const Icon(Icons.menu),
                    const SizedBox(width: 12),
                    Text(
                      'Conductores',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}