import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/utils/runtime.dart' as runtime;
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/utils/websocket/impl/travel_state_handler.dart';

class SearchDriverPage extends StatefulWidget {
  const SearchDriverPage(
      {super.key, required this.travelId, this.wasPageRestored = false, required this.travelRequestedDate});

  final int travelId;
  final bool wasPageRestored;
  final DateTime travelRequestedDate;

  @override
  State<SearchDriverPage> createState() => _SearchDriverPageState();
}

class _SearchDriverPageState extends State<SearchDriverPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final Timer _timeoutTimer;
  Timer? _ticker;
  late final TravelStateHandler _handler;
  final _travelService = TravelService();
  static const Duration _timeout = Duration(minutes: 3);
  DateTime? _requestedAt;
  DateTime? _startedAt;
  Duration _remaining = _timeout;

  @override
  void initState() {
    super.initState();
    // if page was restored, use the original travel requested date
    if (widget.wasPageRestored) {
      _requestedAt = widget.travelRequestedDate;
    }
    // record local start time, useful for non-restored flows
    _startedAt = DateTime.now();
    // connect to websocket in order to see if any driver took the trip
    _handler = TravelStateHandler(
        state: TravelState.accepted,
        travelId: widget.travelId,
        onMessage: (travel) async {
          if (widget.wasPageRestored) {
            context.go(ClientRoutes.trackDriver, extra: travel);
          } else {
            context.pop(travel);
          }
        })
      ..activate();
    _setupAnimation();
    _setupTicker();
    _setupTimer();
  }

  void _setupAnimation() {
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  void _setupTicker() {
    _remaining = _computeRemainingDuration();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = _computeRemainingDuration();
      if (mounted) {
        setState(() => _remaining = next);
      }
    });
  }

  void _setupTimer() {
    final remaining = _computeRemainingDuration();
    _timeoutTimer = Timer(remaining, () async {
      if (widget.wasPageRestored) {
        context.go(ClientRoutes.home);
      } else {
        context.pop();
      }
    });
  }

  Duration _computeRemainingDuration() {
    final baseline = _requestedAt ?? _startedAt;
    if (baseline == null) return _timeout;
    final elapsed = DateTime.now().difference(baseline);
    final remaining = _timeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  void dispose() {
    _controller.dispose();
    _handler.deactivate();
    _timeoutTimer.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  Widget _buildRadarPulse(double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 200,
          height: 200,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD48E1E)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centeredCircleSize = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              AppLocalizations.of(context)!.searchDrivers,
              style: TextStyle(color: Theme.of(context).colorScheme.shadow, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                child: Text(
                  _formatRemaining(_remaining),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (index) {
                    final delay = index * 0.6;
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) {
                        final progress = (_controller.value + delay) % 1;
                        final scale = 1 + progress * 2;
                        final opacity = (1 - progress).clamp(0.0, 1.0);
                        return _buildRadarPulse(scale, opacity);
                      },
                    );
                  }),
                  // TODO("yapmDev": @Reminder)
                  // - Replace the custom centered circle with the one provided in the assets.
                  Container(
                    width: centeredCircleSize,
                    height: centeredCircleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryFixed,
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: centeredCircleSize * 0.20,
                        backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
                        child: Icon(
                          Icons.directions_car_outlined,
                          color: Theme.of(context).colorScheme.primaryFixedDim,
                          size: Theme.of(context).iconTheme.size! * 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: GestureDetector(
                onTap: () async {
                  if (widget.wasPageRestored) {
                    // Attempt to cancel on backend when user cancels restored flow
                    if (runtime.hasConnection(context)) {
                      await _travelService.changeState(travelId: widget.travelId, state: TravelState.canceled);
                    }
                    if (!context.mounted) return;
                    context.go(ClientRoutes.home);
                  } else {
                    context.pop();
                  }
                },
                // TODO("yapmDev": @Reminder)
                // - Replace the custom circle for cancel with the one provided in the assets.
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(80),
                  child: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRemaining(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
