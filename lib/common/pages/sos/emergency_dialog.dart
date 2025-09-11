import 'package:flutter/material.dart';
import 'package:quber_taxi/common/services/sos_alert_service.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:url_launcher/url_launcher.dart';

/// A modal dialog used to confirm an emergency SOS alert.
///
/// This dialog displays a warning message and requires user confirmation.
/// If the user confirms, it triggers a phone call to emergency services (dial `106`)
/// and registers the emergency alert in the backend API.
///
/// This dialog is intended for real emergencies only.
/// When confirmed, the app launches the native phone dialer with the emergency number
/// and sends the alert data to the API in the background.
///
/// The dialog automatically extracts travel data from BackupNavigationManager.
///
/// Example usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => const EmergencyDialog(),
/// );
/// ```
class EmergencyDialog extends StatelessWidget {
  /// Creates the SOS emergency confirmation dialog.
  const EmergencyDialog({super.key});

  /// Opens the system phone dialer with the given [phoneNumber] and registers the SOS alert.
  ///
  /// This method performs two actions:
  /// 1. Launches the phone dialer with the emergency number
  /// 2. Sends the SOS alert data to the backend API in the background
  ///
  /// If the dialer cannot be launched, throws an exception.
  void _launchPhoneDialer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch dialer with number $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24.0,
        children: [
          // Circular SOS icon
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onErrorContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'SOS',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Theme.of(context).colorScheme.errorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Title
          Text(
            '¿Confirmar Alerta\nSOS?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.surface,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Warning message
          Text(
            'Este botón debe utilizarse únicamente\n'
                'en situaciones de emergencia reales,\n'
                'ya que al activarlo se notificará de\n'
                'inmediato a las autoridades\ncorrespondientes.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.surface,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Confirm button
          SizedBox(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(dimensions.borderRadius * 0.75),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              ),
              onPressed: () async {
                _launchPhoneDialer('106');
                if(hasConnection(context)) {
                  await SosAlertService().createSosAlert();
                }
                // send data to api
              },
              child: Text(
                'CONFIRMAR SOS',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCELAR',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}