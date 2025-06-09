import 'package:flutter/material.dart';
import 'package:quber_taxi/client-app/pages/navigation/trip_completed.dart';

void showEmergencyDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor:Theme.of(context).colorScheme.errorContainer.withOpacity(0.8),
    builder: (context) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.errorContainer,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  '¿Confirmar Alerta\nSOS?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Este botón debe utilizarse únicamente\n'
                      'en situaciones de emergencia reales,\n'
                      'ya que al activarlo se notificará de\n'
                      'inmediato a las autoridades\ncorrespondientes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                     // Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const TripCompletedBottomSheet(),
                      );
                    },
                    child: Text(
                      'CONFIRMAR SOS',
                      style: TextStyle(color: Theme.of(context).colorScheme
                          .onSecondary, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
          ),
        ),
      );
    },
  );
}
