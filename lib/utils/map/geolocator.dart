import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Requests location permission from the user and handles different outcomes.
///
/// This function prompts the user to grant location permission using the
/// [Geolocator] package. Depending on the user's response, it triggers one of
/// the provided callbacks:
///
/// - [onPermissionGranted]: Called if the permission is granted.
/// - [onPermissionDenied]: Called if the permission is denied but not permanently.
/// - [onPermissionDeniedForever]: Called if the permission is permanently denied.
///
/// The [context] is used to ensure the widget is still mounted before
/// calling [onPermissionGranted].
///
/// Example usage:
/// ```dart
/// await requestLocationPermission(
///   context: context,
///   onPermissionGranted: () {
///     // Proceed with location-based functionality
///   },
///   onPermissionDenied: () {
///     // Show snack-bar or dialog
///   },
///   onPermissionDeniedForever: () {
///     // Redirect user to settings or explain why permission is needed
///   },
/// );
/// ```
///
/// See also:
/// - [Geolocator.requestPermission]
/// - [LocationPermission]
Future<void> requestLocationPermission({
  required BuildContext context,
  required void Function() onPermissionGranted,
  void Function()? onPermissionDenied,
  void Function()? onPermissionDeniedForever
}) async {
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    onPermissionDenied?.call();
    return;
  } else if (permission == LocationPermission.deniedForever) {
    onPermissionDeniedForever?.call();
    return;
  } else {
    if (!context.mounted) {
      return;
    } else {
      onPermissionGranted.call();
      return;
    }
  }
}