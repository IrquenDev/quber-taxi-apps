import 'package:flutter/material.dart';
import 'package:quber_taxi/client-app/pages/navigation/trip_completed.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class EmergencyDialog extends StatelessWidget {

  const EmergencyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24.0,
            children: [
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
                      )
                  )
              ),
              Text(
                  '¿Confirmar Alerta\nSOS?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold
                  )
              ),
              Text(
                  'Este botón debe utilizarse únicamente\n'
                      'en situaciones de emergencia reales,\n'
                      'ya que al activarlo se notificará de\n'
                      'inmediato a las autoridades\ncorrespondientes.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold
                  )
              ),
              SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(dimensions.borderRadius * 0.75))
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0)
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      isDismissible: false,
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (context) => const ClientTripCompleted(),
                    );
                  },
                  child: Text(
                    'CONFIRMAR SOS',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                      'CANCELAR',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none
                      )
                  )
              )
            ]
        )
    );
  }
}