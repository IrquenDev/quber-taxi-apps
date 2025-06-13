import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/websocket/impl/travel_accepted_handler.dart';

class SearchDriver extends StatefulWidget {

  const SearchDriver({super.key, required this.travelId});

  final int travelId;

  @override
  State<SearchDriver> createState() => _SearchDriverState();
}

class _SearchDriverState extends State<SearchDriver> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late final Timer _timeoutTimer;
  late final TravelAcceptedHandler _handler;

  @override
  void initState() {
    super.initState();
    // handling radar animation
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); // infinity loop
    // connect to websocket in order to see if any driver took the trip
    _handler = TravelAcceptedHandler(
      travelId: widget.travelId,
      onMessage: (travel) => context.pop(travel)
    );
    _handler.activate();
    // schedule timeout in 3 min
    _timeoutTimer = Timer(const Duration(minutes: 3), () {
      if (mounted) {
        context.pop(null);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _handler.deactivate();
    _timeoutTimer.cancel();
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD48E1E),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final centeredCircleSize = MediaQuery.of(context).size.width /2;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text('Buscando Conductores...', style: Theme.of(context).textTheme.titleMedium),
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
                  ///TODO("yapmDev")
                  /// - Replace the custom centered circle with the one provided in the assets.
                  Container(
                    width: centeredCircleSize,
                    height: centeredCircleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryFixed
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: centeredCircleSize * 0.20,
                        backgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
                        child: Icon(
                            Icons.directions_car_outlined,
                            color: Theme.of(context).colorScheme.primaryFixedDim,
                            size: Theme.of(context).iconTheme.size! * 2
                        )
                      )
                    )
                  )
                ]
              )
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: GestureDetector(
                  onTap: () => context.pop(null),
                  ///TODO("yapmDev")
                  /// - Replace the custom circle for cancel with the one provided in the assets.
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(80),
                    child: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  )
              )
            )
          ]
        )
      )
    );
  }
}