import 'package:flutter/material.dart';
import 'package:network_checker/network_checker.dart';

Widget customNetworkAlert(BuildContext context, ConnectionStatus status, [bool useTopSafeArea = false]) {
  return SafeArea(
    top: useTopSafeArea,
    child: Container(
        margin: const EdgeInsets.all(12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).colorScheme.error,
        ),
        child: Row(
            spacing: 12.0,
            children: [
              Icon(Icons.wifi_off_outlined, color: Theme.of(context).colorScheme.onError),
              Flexible(
                  child: Text(
                      "La app está offline, algunas funciones podrian verse afectadas",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onError
                      )
                  )
              )
            ]
        )
    ),
  );
}