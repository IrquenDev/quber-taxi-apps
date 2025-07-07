import 'dart:convert';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/utils/websocket/core/websocket_handler.dart';

/// A WebSocket handler that listens for state changes on a specific travel.
///
/// Subscribes to `/topic/travels/{travelId}/state/{state}` and triggers
/// a callback when a travel enters the specified [state].
///
/// This is useful for reacting to transitions, allowing UI or business logic to be synchronized with backend-driven
/// updates in real time.
///
/// Usage:
/// ```dart
/// final handler = TravelStateHandler(
///   travelId: 101,
///   state: TravelState.ACCEPTED,
///   onMessage: (travel) {
///     // Update UI or notify user of the travel state change
///   },
/// );
/// handler.activate();
/// ```
///
/// Messages are expected to be JSON-encoded `Travel` objects.
class TravelStateHandler extends WebSocketHandler<Travel> {

  /// The unique ID of the travel to observe.
  final int travelId;

  /// The [TravelState] that this handler listens for.
  final TravelState state;

  /// Callback triggered when a matching state update is received.
  final void Function(Travel travel) onMessage;

  /// Constructs a [TravelStateHandler] for a specific travel and state transition.
  TravelStateHandler({
    required this.travelId,
    required this.onMessage,
    required this.state,
  });

  /// The topic for this travel state update.
  /// Example: `/topic/travels/101/state/ACCEPTED`
  @override
  String get topic => '/topic/travels/$travelId/state/${state.apiValue}';

  /// Parses the incoming message as a [Travel] object.
  @override
  Travel parseMessage(String raw) => Travel.fromJson(jsonDecode(raw));

  /// Passes the parsed [Travel] object to the provided callback.
  @override
  void handleMessage(Travel parsed) => onMessage(parsed);
}