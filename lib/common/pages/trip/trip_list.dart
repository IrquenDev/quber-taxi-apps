import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quber_taxi/common/widgets/dashed_line.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({Key? key}) : super(key: key);

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with overlapping cards
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Header container
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.surfaceDim,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0, bottom: 120),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.shadow),
                          const SizedBox(width: 16),
                          Text(
                            AppLocalizations.of(context)!.tripsPageTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.shadow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Trip cards starting from the header
                Positioned(
                  top: 170,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      // First expanded trip card
                      _buildTripCard(
                        index: 0,
                        dateTime: '2023-12-21 15:43:21',
                        distance: '0.3km',
                        price: '35 CUP',
                        duration: '12 minutos',
                        clientName: 'María Espinosa González',
                        clientPhone: '55648484',
                        driverName: 'Alfonzo Pérez Espinosa',
                        driverPhone: '55648484',
                        driverPlate: 'B4344',
                        isExpanded: expandedIndex == 0,
                      ),
                      const SizedBox(height: 12),
                      // Second trip card
                      _buildTripCard(
                        index: 1,
                        dateTime: '2023-12-21 15:43:21',
                        distance: '0.3km',
                        price: '35 CUP',
                        isExpanded: expandedIndex == 1,
                      ),
                      const SizedBox(height: 12),
                      // Third trip card
                      _buildTripCard(
                        index: 2,
                        dateTime: '2023-12-21 15:43:21',
                        distance: '0.3km',
                        price: '35 CUP',
                        isExpanded: expandedIndex == 2,
                      ),
                      const SizedBox(height: 12),
                      // Fourth trip card
                      _buildTripCard(
                        index: 3,
                        dateTime: '2023-12-21 15:43:21',
                        distance: '0.3km',
                        price: '35 CUP',
                        isExpanded: expandedIndex == 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40), // Space for the overlapping cards
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard({
    required int index,
    required String dateTime,
    required String distance,
    required String price,
    String? duration,
    String? clientName,
    String? clientPhone,
    String? driverName,
    String? driverPhone,
    String? driverPlate,
    required bool isExpanded,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surface,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main trip info (always visible)
          InkWell(
            onTap: () {
              setState(() {
                expandedIndex = expandedIndex == index ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date and distance row
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateTime,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.route_sharp,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        distance,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price row
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.of(context)!.tripPrice} $price',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Duration row (only for first card when expanded)
                  if (isExpanded && duration != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${AppLocalizations.of(context)!.tripDuration} $duration',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.shadow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Expanded content (client and driver info)
          if (isExpanded && clientName != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client section
                  DashedLine(height: 1, color: Theme.of(context).colorScheme.surfaceDim),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.clientSectionTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        "assets/icons/list_icon.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        AppLocalizations.of(context)!.clientName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),

                      Text(
                        clientName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        "assets/icons/list_icon.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        AppLocalizations.of(context)!.clientPhone,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                      Text(
                        clientPhone ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DashedLine(height: 1, color: Theme.of(context).colorScheme.surfaceDim),
                  const SizedBox(height: 8),
                  // Driver section
                  Text(
                    AppLocalizations.of(context)!.driverSectionTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.shadow,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        "assets/icons/list_icon.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        AppLocalizations.of(context)!.driverName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                      Text(
                        driverName ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        "assets/icons/list_icon.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        AppLocalizations.of(context)!.driverPhone,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                      Text(
                        driverPhone ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        "assets/icons/list_icon.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        AppLocalizations.of(context)!.driverPlate,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                      Text(
                        driverPlate ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

}