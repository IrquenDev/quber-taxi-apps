import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_service.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelInfoSheet extends StatelessWidget {

  final Travel travel;
  final void Function() onPickUpConfirmationRequest;

  const TravelInfoSheet({super.key, required this.travel, required this.onPickUpConfirmationRequest});

  /// Opens the system phone dialer with the client's phone number.
  Future<void> _launchPhoneDialer(String phoneNumber) async {
    try {
      // Clean the phone number - remove any non-digit characters except +
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      print('Original phone number: $phoneNumber');
      print('Clean phone number: $cleanPhone');
      
      final Uri url = Uri(scheme: 'tel', path: cleanPhone);
      print('Attempting to launch phone dialer with URL: $url');
      
      // Try with external application mode
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        print('Phone dialer launched successfully');
      } else {
        print('Failed to launch phone dialer');
        
        // Try alternative approach with canLaunchUrl
        if (await canLaunchUrl(url)) {
          print('canLaunchUrl returned true, trying again...');
          await launchUrl(url);
          print('Phone dialer launched successfully on second attempt');
        } else {
          print('canLaunchUrl also returned false');
          throw 'Could not launch dialer with number $cleanPhone';
        }
      }
    } catch (e) {
      print('Error launching phone dialer: $e');
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
                              text: '${travel.hasPets ? localizations.withPet : localizations.withoutPet}',
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
                              text: '${TaxiType.nameOf(travel.taxiType, localizations)}',
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
              onPressed: hasConnection(context) ? () {
                WebSocketService.instance.send(
                    "/app/travels/${travel.id}/pick-up-confirmation", null // no body needed
                );
                onPickUpConfirmationRequest.call();
              } : null,
              child: Text(
                localizations.startTrip,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              )
            )
          )
        ]
      )
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