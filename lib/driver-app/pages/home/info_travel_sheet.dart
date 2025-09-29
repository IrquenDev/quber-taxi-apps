import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/driver_service.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelInfoSheet extends StatelessWidget {

  final Travel travel;
  final void Function() onPickUpConfirmationRequest;
  final VoidCallback onReportClient;

  const TravelInfoSheet({
    super.key,
    required this.travel,
    required this.onPickUpConfirmationRequest,
    required this.onReportClient
  });

  /// Opens the system phone dialer with the client's phone number.
  Future<void> _launchPhoneDialer(String phoneNumber) async {
    try {
      // Clean the phone number - remove any non-digit characters except +
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri url = Uri(scheme: 'tel', path: cleanPhone);
      // Try with external application mode
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Try alternative approach with canLaunchUrl
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
        else {
          throw 'Could not launch dialer with number $cleanPhone';
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching phone dialer: $e');
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card Header
          Card(
            margin: EdgeInsets.zero,
            color: colorScheme.surfaceContainer,
            elevation: dimensions.elevation,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Client Profile Image
                  CircleAvatar(
                    radius: 24.0,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 28.0,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Client's Name & Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(travel.client.name, style: textTheme.titleMedium),
                        const SizedBox(height: 8.0),
                        Text(
                          travel.client.phone,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      ]
                    )
                  ),
                  // Contact Icon
                  IconButton(
                    onPressed: () async {
                      try {

                        await _launchPhoneDialer(travel.client.phone);
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error in phone button: $e');
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${localizations.couldNotOpenPhoneDialer}: $e'),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      Icons.phone,
                      color: colorScheme.primary,
                    ),
                  )
                ]
              )
            )
          ),
          const SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Travel Origin
                Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: colorScheme.onSurfaceVariant,
                      size: 24.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        travel.originName,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ]
                ),
                // Vertical dotted line between origin and destination
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24.0, // Same width as icon
                        height: 16.0, // Fixed height for the line
                        child: CustomPaint(
                          painter: DottedLinePainter(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0), // Same spacing as after icon
                      Expanded(
                        child: Container(), // Empty space to maintain layout
                      ),
                    ],
                  ),
                ),
                // Travel Destination
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 24.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        travel.destinationName,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                // Additional Info
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: '${localizations.countPeople} ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${travel.requiredSeats}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      RichText(
                        text: TextSpan(
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: '${localizations.pet} ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: travel.hasPets ? localizations.withPet : localizations.withoutPet,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      RichText(
                        text: TextSpan(
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: '${localizations.typeVehicle} ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: TaxiType.nameOf(travel.taxiType, localizations),
                            ),
                          ],
                        ),
                      ),
                    ]
                  )
                )
              ]
            )
          ),
          const SizedBox(height: 12.0),
          // Start Travel Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
              ),
              onPressed:  () => onPickUpConfirmationRequest.call(),
              child: Text(
                localizations.startTrip,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              )
            )
          ),
          const SizedBox(height: 20.0),
          // Report Client
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿El cliente nunca apareció ni hizo más contacto?'),
              TextButton(
                onPressed: hasConnection(context) ? () async {
                  var reason = await _showReportClientDialog(context);
                  if (reason != null) {
                    final response = await DriverService().reportClient(
                      driverId: loggedInUser['id'],
                      clientId: travel.client.id,
                      reason: reason
                    );
                    if(!context.mounted) return;
                    if(response.statusCode == 200) {
                      onReportClient();
                    } else {
                      showToast(context: context, message: "No se pudo llevar a acabo el reporte");
                    }
                  }
                } : null,
                child: Text(
                  'Reportar',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          )
        ]
      )
    );
  }

  Future<String?> _showReportClientDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final dims = Theme.of(context).extension<DimensionExtension>()!;
    final reasonTFController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setState) {
            final canSubmit = reasonTFController.text.trim().isNotEmpty;

            return AlertDialog(
              title: Text(
                "Reportar cliente",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                      "Continuar solo si el cliente tuvo un mal comportamiento real, "
                          "pues se tomarán medidas severas con el mismo."
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reasonTFController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Agregue el motivo de este reporte",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(dims.borderRadius),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(null),
                  child: Text(localizations.cancelButton),
                ),
                OutlinedButton(
                  onPressed: canSubmit
                      ? () => context.pop(reasonTFController.text.trim())
                      : null,
                  child: Text(localizations.acceptButton),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Custom painter to draw a vertical dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;
  
  DottedLinePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    const double dotSize = 3.0;
    const double spacing = 3.0;
    final double centerX = size.width / 2; // Center in the SizedBox
    
    for (double y = 0; y < size.height; y += spacing + dotSize) {
      canvas.drawLine(
        Offset(centerX, y),
        Offset(centerX, y + dotSize),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}