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
  
  // Pagination state
  List<Travel> _allTravels = [];
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  bool _initialLoadComplete = false;

  Future<void> _refreshTravels() async {
    _currentPage = 0;
    _hasMoreData = true;
    _initialLoadComplete = false;
    final travelPage = await travelService.fetchAvailableTravels(taxi.seats, taxi.type, page: 0, size: 20);
    final newTravels = travelPage.content;
    
    if(newTravels.isEmpty) {
      if(_sheetController.isAttached){
        _sheetController.jumpTo(0.15);
      }
    }
    
    setState(() {
      _allTravels = newTravels;
      _hasMoreData = !travelPage.last;
      _isActionPending = false;
      _initialLoadComplete = true;
    });
  }

  void _loadTravels() {
    setState(() {
      _isActionPending = true;
      _currentPage = 0;
      _hasMoreData = true;
      _allTravels.clear();
      _initialLoadComplete = false;
      
      futureTravels = travelService.fetchAvailableTravels(taxi.seats, taxi.type, page: 0, size: 20).then((travelPage) {
        final travels = travelPage.content;
        
        _allTravels = travels;
        _hasMoreData = !travelPage.last;
        return _allTravels;
      }).whenComplete(() {
        if (mounted) {
          setState(() {
            _isActionPending = false;
            _initialLoadComplete = true;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    taxi = Driver.fromJson(loggedInUser).taxi;

    // Initialize ghost container
    ghostContainer = Container(
      width: 24.0,
      color: Colors.transparent
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.addListener(() {
        setState(() {
          _currentSize = _sheetController.size;
        });
      });
    });
        _loadTravels();
  }

  Widget _buildTravelsList(ScrollController scrollController, ColorScheme colorScheme) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification && 
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            _hasMoreData && !_isLoadingMore) {
          _loadMoreTravels();
        }
        return false;
      },
      child: ListView.builder(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
          itemCount: _allTravels.length + (_hasMoreData ? 1 : 0),
          controller: scrollController,
          itemBuilder: (context, index) {
            if (index == _allTravels.length) {
              // Loading indicator at the end (only when loading)
              return _isLoadingMore ? Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: CircularProgressIndicator(color: colorScheme.primary),
              ) : const SizedBox.shrink();
            }
            return TripCard(
                travel: _allTravels[index],
                onTravelSelected: widget.onTravelSelected
            );
          }
      ),
    );
  }

  Future<void> _loadMoreTravels() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      _currentPage++;
      final travelPage = await travelService.fetchAvailableTravels(taxi.seats, taxi.type, page: _currentPage, size: 20);
      final newTravels = travelPage.content;
      
      setState(() {
        _allTravels.addAll(newTravels);
        _hasMoreData = !travelPage.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      // Revert page increment on error
      _currentPage--;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;

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
                                                padding: const EdgeInsets.only(top: 56.0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.cardBorderRadiusLarge)),
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
                                                                                          height: 48.0,
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
                                  child: !_initialLoadComplete 
                                    ? FutureBuilder(
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
                                          return _buildTravelsList(scrollController, colorScheme);
                                        }
                                      )
                                    : _allTravels.isEmpty
                                      ? Center(
                                          child: Text(
                                            localizations.noTravel,
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        )
                                      : _buildTravelsList(scrollController, colorScheme),
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