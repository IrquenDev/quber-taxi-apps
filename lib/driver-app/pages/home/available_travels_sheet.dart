import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/models/taxi.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/driver-app/pages/home/trip_card.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart';

class AvailableTravelsSheet extends StatefulWidget {

  final void Function(Travel) onTravelSelected;

  const AvailableTravelsSheet({super.key, required this.onTravelSelected});

  @override
  State<AvailableTravelsSheet> createState() => _AvailableTravelsSheetState();
}

class _AvailableTravelsSheetState extends State<AvailableTravelsSheet> {

  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final travelService = TravelService();
  // Just for simplify alignment - using theme-based dimensions
  late final Widget ghostContainer;
  double _currentSize = 0.15;
  bool _isActionPending = true;

  late Future<List<Travel>> futureTravels;
  late final Taxi taxi;

  Future<void> _refreshTravels() async {
    final newTravels = await travelService.fetchAvailableTravels(taxi.seats, taxi.type);
    if(newTravels.isEmpty) {
      if(_sheetController.isAttached){
        _sheetController.jumpTo(0.15);
      }
    }
    setState(() {
      futureTravels = Future.value(newTravels);
      _isActionPending = false;
    });
  }

  void _loadTravels() {
    setState(() {
      _isActionPending = true;
      futureTravels = travelService.fetchAvailableTravels(taxi.seats, taxi.type).whenComplete(() {
        if (mounted) {
          setState(() => _isActionPending = false);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    taxi = Driver.fromJson(loggedInUser).taxi;
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;
    
    // Initialize ghost container with theme dimensions
    ghostContainer = Container(
      width: 24.0, 
      color: Colors.transparent
    );
    
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
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.cardBorderRadiusMedium))),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          const SizedBox(width: 8.0),
                          Text(localizations.selectTravel, style: textTheme.titleMedium)
                        ]
                    )
                  )
                )
              ),
              // Main Container with Content
              Positioned.fill(
                  child: Padding(
                                                padding: const EdgeInsets.only(top: 24.0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.cardBorderRadiusMedium)),
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
                                                                                          height: 24.0,
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ghostContainer,
                                            Container(
                                                width: 24.0,
                                                height: 8.0,
                                                decoration: BoxDecoration(
                                                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                                                    borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall)
                                                )
                                            ),
                                            !_isActionPending ?
                                            IconButton(
                                                icon: const Icon(Icons.refresh),
                                                tooltip: localizations.updateTravel,
                                                onPressed: hasConnection(context) ? _refreshTravels : null
                                            ) : ghostContainer
                                          ]
                                      ),
                                    )
                                ),
                                // Scrollable Mocked List
                                Expanded(
                                  child: FutureBuilder(
                                      future: futureTravels,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                  return Center(
                                          child: CircularProgressIndicator(
                                            color: colorScheme.primary,
                                          )
                                        );
                                      }
                                      else if(snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                        return Center(
                                          child: Text(
                                            localizations.noTravel,
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        );
                                      }
                                      else {
                                        final travels = snapshot.data!;
                                        return ListView.builder(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            itemCount: travels.length,
                                            controller: scrollController,
                                            itemBuilder: (context, index) => TripCard(
                                                travel: travels[index],
                                                onTravelSelected: widget.onTravelSelected
                                            )
                                        );
                                      }
                                      }
                                  ),
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