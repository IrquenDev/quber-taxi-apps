import 'package:quber_taxi/utils/websocket/core/websocket_handler.dart';

/// A WebSocket handler that listens for finish confirmation requests for a specific travel.
///
/// This handler subscribes to `/topic/travels/{travelId}/finish-confirmation`
/// and triggers a callback when a finish confirmation message is received.
///
/// Use this when the system or another user (e.g., driver or admin) needs to
/// notify the client that a travel requires confirmation to be finalized.
///
/// Usage:
/// ```dart
/// final handler = FinishConfirmationHandler(
///   travelId: 123,
///   onConfirmationRequested: () {
///     // Prompt user for finish confirmation
///   },
/// );
/// handler.activate();
/// ```
class FinishConfirmationHandler extends WebSocketHandler<void> {

  /// ID of the travel to listen for finish confirmation requests.
  final int travelId;

  /// Callback triggered when a confirmation request message is received.
  final void Function() onConfirmationRequested;

  /// Creates a handler for listening to finish confirmation WebSocket events.
  FinishConfirmationHandler({
    required this.travelId,
    required this.onConfirmationRequested,
  });

  /// The topic that signals when a travel requires finish confirmation.
  /// Example: `/topic/travels/123/finish-confirmation`
  @override
  String get topic => "/topic/travels/$travelId/finish-confirmation";

  /// This handler does not parse any message content — the presence of the message
  /// itself is considered sufficient to trigger the confirmation logic.
  @override
  void parseMessage(String raw) {
    return;
  }

  /// Executes the [onConfirmationRequested] callback.
  @override
  void handleMessage(void parsed) => onConfirmationRequested();
}