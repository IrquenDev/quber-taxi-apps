import 'package:quber_taxi/utils/websocket/core/websocket_handler.dart';

class FinishConfirmationHandler extends WebSocketHandler<void> {

  final int travelId;
  final void Function() onConfirmationRequested;

  FinishConfirmationHandler({
    required this.travelId,
    required this.onConfirmationRequested,
  });

  @override
  String get topic => "/topic/travels/$travelId/finish-confirmation";

  @override
  void parseMessage(String raw) {
    return;
  }

  @override
  void handleMessage(void parsed) => onConfirmationRequested();
}