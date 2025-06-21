import 'package:quber_taxi/websocket/core/websocket_handler.dart';

class PickUpConfirmationHandler extends WebSocketHandler<void> {

  final int travelId;
  final void Function() onConfirmationRequested;

  PickUpConfirmationHandler({
    required this.travelId,
    required this.onConfirmationRequested,
  });

  @override
  String get topic => "/topic/travels/$travelId/pick-up-confirmation";

  @override
  void parseMessage(String raw) {
    return;
  }

  @override
  void handleMessage(void parsed) => onConfirmationRequested();
}