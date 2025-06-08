import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/driver-app/pages/home/trip_card.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class AvailableTravelsSheet extends StatefulWidget {

  final void Function(Travel) onTravelSelected;

  const AvailableTravelsSheet({super.key, required this.onTravelSelected});

  @override
  State<AvailableTravelsSheet> createState() => _AvailableTravelsSheetState();
}

class _AvailableTravelsSheetState extends State<AvailableTravelsSheet> {

  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final travelService = TravelService();
  // Just for simplify alignment
  final ghostContainer = Container(width: 40, color: Colors.transparent);

  late Future<List<Travel>> futureTravels;

  double _currentSize = 0.15;
  bool _isActionPending = true;

  Future<void> _refreshTravels() async {
    /// TODO("yapmDev": Static params)
    final newTravels = await travelService.findAvailableTravels(4, TaxiType.standard);
    if(newTravels.isEmpty) {
      _sheetController.jumpTo(0.15);
    }
    setState(() {
      futureTravels = Future.value(newTravels);
      _isActionPending = false;
    });
  }

  void _loadTravels() {
    setState(() {
      _isActionPending = true;
      /// TODO("yapmDev": Static params)
      futureTravels = travelService.findAvailableTravels(4, TaxiType.standard).whenComplete(() {
        if (mounted) {
          setState(() => _isActionPending = false);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.addListener(() {
        setState(() {
          _currentSize = _sheetController.size;
        });
      });
    });
    _loadTravels();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      expand: false,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return Stack(
            children: [
              // Background Container With Header
              Positioned.fill(
                child: Container(decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.borderRadius))),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8.0,
                        children: [
                          IconButton(
                              onPressed: () {
                                if (!_sheetController.isAttached) return;
                                _sheetController.jumpTo(_currentSize >= 0.15 && _currentSize <= 0.45 ? 0.9 : 0.15);
                              },
                              icon: Icon(_currentSize >= 0.15 && _currentSize <= 0.45
                                  ? Icons.keyboard_double_arrow_up
                                  : Icons.keyboard_double_arrow_down
                              )
                          ),
                          Text("Seleccione un viaje", style: Theme.of(context).textTheme.titleMedium)
                        ]
                    )
                  )
                )
              ),
              // Main Container with Content
              Positioned.fill(
                  child: Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.borderRadius)),
                          ),
                          child: Column(
                              children: [
                                // Drag Handler + Refresh Button
                                GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onVerticalDragUpdate: (details) {
                                      if (!_sheetController.isAttached) return;
                                      final screenHeight = MediaQuery.of(context).size.height;
                                      final dragAmount = -details.primaryDelta! / screenHeight;
                                      final newSize = (_currentSize + dragAmount).clamp(0.1, 0.9);
                                      _sheetController.jumpTo(newSize);
                                    },
                                    child: SizedBox(
                                      height: 40.0,
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ghostContainer,
                                            Container(
                                                width: 40,
                                                height: 8.0,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade400,
                                                    borderRadius: BorderRadius.circular(12)
                                                )
                                            ),
                                            !_isActionPending ?
                                            IconButton(
                                                icon: const Icon(Icons.refresh),
                                                tooltip: 'Actualizar viajes',
                                                onPressed: _refreshTravels
                                            ) : ghostContainer
                                          ]
                                      ),
                                    )
                                ),
                                // Scrollable Mocked List
                                FutureBuilder(
                                    future: futureTravels,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      else if(snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                        return Center(child: Text("Sin viajes disponibles"),);
                                      }
                                      else {
                                        final travels = snapshot.data!;
                                        return Expanded(
                                            child: ListView.builder(
                                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                                itemCount: travels.length,
                                                controller: scrollController,
                                                itemBuilder: (context, index) => TripCard(
                                                    travel: travels[index],
                                                    onTravelSelected: widget.onTravelSelected
                                                )
                                            )
                                        );
                                      }
                                    }
                                )
                              ]
                          )
                      )
                  )
              )
            ]
        );
      }
    );
  }
}