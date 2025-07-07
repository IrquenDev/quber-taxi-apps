import 'dart:convert';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_handler.dart';

/// A WebSocket handler that listens for new travel requests directed to a specific driver.
///
/// This handler subscribes to `/topic/new-travel-request/{driverId}` and emits
/// a [Travel] object when a new travel request is received in real time.
///
/// Useful for implementing driver-side functionality that reacts to new ride offers.
///
/// Usage:
/// ```dart
/// final handler = TravelRequestHandler(
///   driverId: driver.id,
///   onNewTravel: (travel) {
///     // Show modal, accept/reject UI, etc.
///   },
/// );
/// handler.activate();
/// ```
///
/// The expected message format is a JSON-encoded `Travel` object.
class TravelRequestHandler extends WebSocketHandler<Travel> {

  /// ID of the driver this handler is listening for.
  final int driverId;

  /// Callback executed when a new [Travel] request is received.
  final void Function(Travel coords) onNewTravel;

  /// Creates a new handler to listen for travel requests for the given [driverId].
  TravelRequestHandler({
    required this.driverId,
    required this.onNewTravel,
  });

  /// The WebSocket topic for receiving travel requests.
  /// Example: `/topic/new-travel-request/42`
  @override
  String get topic => "/topic/new-travel-request/$driverId";

  /// Parses the incoming raw JSON string into a [Travel] object.
  @override
  Travel parseMessage(String raw) {
    final data = jsonDecode(raw);
    return Travel.fromJson(data);
  }

  /// Dispatches the parsed [Travel] object to the provided callback.
  @override
  void handleMessage(Travel parsed) => onNewTravel(parsed);
}