import 'dart:convert';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_handler.dart';

/// A WebSocket handler that listens for real-time location updates of a specific driver.
///
/// This handler subscribes to the topic `/topic/drivers/{driverId}/location` and
/// dispatches decoded [Position] updates via the provided callback.
///
/// Usage:
/// ```dart
/// final handler = DriverLocationHandler(
///   driverId: 42,
///   onLocation: (coords) {
///     // Update UI or state with driver coordinates
///   },
/// );
/// handler.activate();
/// ```
///
/// The messages are expected to be JSON objects with `longitude` and `latitude` fields.
class DriverLocationHandler extends WebSocketHandler<Position> {
  /// ID of the driver whose location updates this handler listens to.
  final int driverId;

  /// Callback executed whenever a new [Position] is received and parsed.
  final void Function(Position coords) onLocation;

  /// Constructs a handler that listens for location updates of [driverId]
  /// and routes them to [onLocation].
  DriverLocationHandler({
    required this.driverId,
    required this.onLocation,
  });

  /// The WebSocket topic for this driver's location updates.
  /// Example: `/topic/drivers/42/location`
  @override
  String get topic => "/topic/drivers/$driverId/location";

  /// Parses a raw JSON string into a [Position] object.
  ///
  /// Expected payload format:
  /// ```json
  /// {
  ///   "longitude": -82.358,
  ///   "latitude": 23.123
  /// }
  /// ```
  @override
  Position parseMessage(String raw) {
    final data = jsonDecode(raw);
    return Position(data["longitude"] as num, data["latitude"] as num);
  }

  /// Forwards the parsed [Position] to the provided [onLocation] callback.
  @override
  void handleMessage(Position parsed) => onLocation(parsed);
}