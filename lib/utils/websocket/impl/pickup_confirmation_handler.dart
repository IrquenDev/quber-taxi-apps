import 'package:quber_taxi/utils/websocket/core/websocket_handler.dart';

/// A WebSocket handler that listens for pick-up confirmation requests for a specific travel.
///
/// Subscribes to `/topic/travels/{travelId}/pick-up-confirmation` and triggers
/// a callback when a message is received, indicating that the user should confirm
/// that the passenger has been picked up.
///
/// This is typically used in workflows where the passenger or system must
/// validate that the ride has officially started.
///
/// Usage:
/// ```dart
/// final handler = PickUpConfirmationHandler(
///   travelId: 123,
///   onConfirmationRequested: () {
///     // Show dialog or update UI to confirm pick-up
///   },
/// );
/// handler.activate();
/// ```
class PickUpConfirmationHandler extends WebSocketHandler<void> {

  /// ID of the travel for which the pick-up confirmation is awaited.
  final int travelId;

  /// Callback triggered when a pick-up confirmation message is received.
  final void Function() onConfirmationRequested;

  /// Creates a handler for pick-up confirmation WebSocket events.
  PickUpConfirmationHandler({
    required this.travelId,
    required this.onConfirmationRequested,
  });

  /// The topic for pick-up confirmation messages.
  /// Example: `/topic/travels/123/pick-up-confirmation`
  @override
  String get topic => "/topic/travels/$travelId/pick-up-confirmation";

  /// No message body is expected; just triggers the confirmation logic.
  @override
  void parseMessage(String raw) {
    return;
  }

  /// Executes the [onConfirmationRequested] callback when the topic is received.
  @override
  void handleMessage(void parsed) => onConfirmationRequested();
}