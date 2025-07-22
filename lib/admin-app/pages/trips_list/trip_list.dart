import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/models/page.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/common/widgets/dashed_line.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

class CompletedTripsPage extends StatefulWidget {

  const CompletedTripsPage({super.key});

  @override
  State<CompletedTripsPage> createState() => _CompletedTripsPageState();
}

class _CompletedTripsPageState extends State<CompletedTripsPage> {

  final _travelService = TravelService();
  late Future<List<Travel>> _futureTravels;
  
  // Minimal pagination state - ONLY what's needed for pagination
  List<Travel> _allTravels = [];
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTravels();
  }

  Future<void> _refreshTravels() async {
    _currentPage = 0;
    _hasMoreData = true;
    final travelPage = await _travelService.fetchAllCompletedTravels(page: 0, size: 20);
    final newTravels = travelPage.content;
    
    setState(() {
      _allTravels = newTravels;
      _hasMoreData = !travelPage.last;
      _isInitialLoading = false;
    });
  }

  void _loadTravels() {
    _currentPage = 0;
    _futureTravels = _travelService.fetchAllCompletedTravels(page: 0, size: 20).then((travelPage) {
      final travels = travelPage.content;
      
      _allTravels = travels;
      _hasMoreData = !travelPage.last;
      _isInitialLoading = false;
      return _allTravels;
    });
  }

  // ONLY method needed for pagination
  Future<void> _loadMoreTravels() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      _currentPage++;
      final travelPage = await _travelService.fetchAllCompletedTravels(page: _currentPage, size: 20);
      final newTravels = travelPage.content;
      
      setState(() {
        _allTravels.addAll(newTravels);
        _hasMoreData = !travelPage.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header container - UNCHANGED from original
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0, bottom: 90),
                  child: Row(
                    spacing: 16.0,
                    children: [
                      IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back), color: Theme.of(context).colorScheme.shadow),
                      Text(
                        AppLocalizations.of(context)!.tripsPageTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.shadow
                        )
                      )
                    ]
                  )
                )
              )
            )
          ),
          // Trip cards
          Positioned(
            top: 120,
            left: 16,
            right: 16,
            bottom: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(20.0),
                child: _isInitialLoading 
                  ? FutureBuilder(
                      future: _futureTravels,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        else if(snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text(AppLocalizations.of(context)!.noTravel));
                        }
                        else {
                          return _buildTravelsList();
                        }
                      }
                    )
                  : _buildTravelsList(),
              ),
            )
          )
        ]
      )
    );
  }

  // ONLY method needed for pagination
  Widget _buildTravelsList() {
    final mockedTravels = List.generate(8, (_) => _allTravels.isNotEmpty ? _allTravels[0] : null).where((t) => t != null).cast<Travel>().toList();
    
    return RefreshIndicator(
      onRefresh: _refreshTravels,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreTravels();
          }
          return false;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ExpansionPanelList.radio(
                elevation: 0,
                expandedHeaderPadding: EdgeInsets.zero,
                children: List.generate(mockedTravels.length + (_isLoadingMore ? 1 : 0), (index) {
                  if (index >= mockedTravels.length) {
                    return ExpansionPanelRadio(
                      value: -1,
                      canTapOnHeader: false,
                      headerBuilder: (context, isExpanded) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      body: const SizedBox.shrink(),
                    );
                  }
                  final travel = mockedTravels[index];
                  return _buildTripCardItem(index, travel);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ExpansionPanelRadio _buildTripCardItem(int index, Travel travel) {
    final client = travel.client;
    final driver = travel.driver!;
    return ExpansionPanelRadio(
      value: index,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.0,
            children: [
              Row(
                spacing: 4.0,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16),
                  Text(DateFormat("yyyy-MM-dd hh:mm").format(travel.endDate!)),
                  const Spacer(),
                  Icon(Icons.route_sharp, size: 16),
                  Text('${travel.finalDistance!} km'),
                ],
              ),
              Row(
                spacing: 8.0,
                children: [
                  Icon(Icons.monetization_on_outlined, size: 16),
                  Text('${AppLocalizations.of(context)!.tripPrice} ${travel.finalPrice} CUP'),
                ],
              ),
              Row(
                spacing: 8.0,
                children: [
                  Icon(Icons.access_time, size: 16),
                  Text('${AppLocalizations.of(context)!.tripDuration} ${travel.finalDuration} min'),
                ]
              )
            ]
          )
        );
      },
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            DashedLine(height: 1, color: Theme.of(context).colorScheme.surfaceDim),
            Text(
              AppLocalizations.of(context)!.clientSectionTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            _infoRow(AppLocalizations.of(context)!.clientName, client.name),
            _infoRow(AppLocalizations.of(context)!.clientPhone, client.phone),
            DashedLine(height: 1, color: Theme.of(context).colorScheme.surfaceDim),
            Text(
              AppLocalizations.of(context)!.driverSectionTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            _infoRow(AppLocalizations.of(context)!.driverName, driver.name),
            _infoRow(AppLocalizations.of(context)!.driverPhone, driver.phone),
            _infoRow(AppLocalizations.of(context)!.driverPlate, driver.taxi.plate),
          ]
        )
      )
    );
  }

  // REVERTED to original method - NO unnecessary changes  
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 16),
          SvgPicture.asset(
            "assets/icons/list_icon.svg",
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSecondaryContainer,
              BlendMode.srcIn,
            ),
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          Text('$label: ', style: Theme.of(context).textTheme.bodyLarge,),
          Expanded(
            child: Text(value ?? '', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyLarge)
          )
        ]
      )
    );
  }
}