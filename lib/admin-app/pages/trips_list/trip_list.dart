import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/common/widgets/dashed_line.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class CompletedTripsPage extends StatefulWidget {
  const CompletedTripsPage({super.key});

  @override
  State<CompletedTripsPage> createState() => _CompletedTripsPageState();
}

class _CompletedTripsPageState extends State<CompletedTripsPage> {
  final _travelService = TravelService();
  late Future<List<Travel>> _futureTravels;

  int? _expandedTileIndex;

  List<Travel> _allTravels = [];
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadTravels();
  }

  Future<void> _refreshTravels() async {
    _currentPage = 0;
    _hasMoreData = true;
    final travelPage = await _travelService.fetchAllCompletedTravels();
    final newTravels = travelPage.content;

    setState(() {
      _allTravels = newTravels;
      _hasMoreData = !travelPage.last;
    });
  }

  void _loadTravels() {
    _currentPage = 0;
    _futureTravels = _travelService.fetchAllCompletedTravels().then((travelPage) {
      final travels = travelPage.content;

      _allTravels = travels;
      _hasMoreData = !travelPage.last;
      return _allTravels;
    });
  }

  Future<void> _loadMoreTravels() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final travelPage = await _travelService.fetchAllCompletedTravels(page: _currentPage);
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
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Stack(
        children: [
          // Header container
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(dimensions.borderRadius),
                  bottomRight: Radius.circular(dimensions.borderRadius),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0, bottom: 90),
                  child: Row(
                    spacing: 16.0,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        color: Theme.of(context).colorScheme.shadow,
                      ),
                      Text(
                        AppLocalizations.of(context)!.tripsPageTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.shadow),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Trip cards
          Positioned(
            top: 140,
            left: 20.0,
            right: 20.0,
            bottom: 0.0,
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(dimensions.borderRadius),
              child: FutureBuilder(
                future: _futureTravels,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(AppLocalizations.of(context)!.noTravel));
                  } else {
                    return _buildTravelsList();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelsList() {
    return RefreshIndicator(
      onRefresh: _refreshTravels,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreTravels();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _allTravels.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _allTravels.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final travel = _allTravels[index];
            return _buildTripCard(index, travel);
          },
        ),
      ),
    );
  }

  Widget _buildTripCard(int index, Travel travel) {
    final colorScheme = Theme.of(context).colorScheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;
    final client = travel.client;
    final driver = travel.driver;
    final isExpanded = _expandedTileIndex == index;

    // Item Container
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      // Adjust ExpansionTile Theme
      child: Theme(
        data: Theme.of(context).copyWith(
          expansionTileTheme: ExpansionTileThemeData(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            iconColor: Theme.of(context).iconTheme.color,
            collapsedIconColor: Theme.of(context).iconTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.borderRadius)),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
          ),
        ),
        child: ExpansionTile(
          key: ValueKey<bool>(_expandedTileIndex == index),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (bool expanded) => setState(() => _expandedTileIndex = expanded ? index : null),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.0,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 20, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                      travel.endDate != null
                          ? DateFormat("yyyy-MM-dd hh:mm").format(travel.endDate!)
                          : localizations.notAvailable,
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(Icons.route_sharp, size: 20, color: colorScheme.outline),
                  Text(
                    travel.finalDistance != null
                        ? '${travel.finalDistance} ${localizations.kilometers}'
                        : localizations.notAvailable,
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
                  )
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.monetization_on_outlined, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    localizations.tripPrice,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    travel.finalPrice != null
                        ? '${travel.finalPrice} ${localizations.currency}'
                        : localizations.notAvailable,
                    style: textTheme.bodyLarge,
                  )
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 4),
                  Text(localizations.tripDuration, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    travel.finalDuration != null
                        ? '${travel.finalDuration} ${localizations.minutes}'
                        : localizations.notAvailable,
                    style: textTheme.bodyLarge,
                  )
                ],
              )
            ],
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.0,
              children: [
                // Dashed Divider
                DashedLine(color: colorScheme.surfaceDim),
                // Client Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(localizations.clientSectionTitle,
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    _infoRow(localizations.clientName, client.name),
                    _infoRow(localizations.clientPhone, client.phone),
                  ],
                ),
                // Dashed Divider
                DashedLine(color: colorScheme.surfaceDim),
                // Driver Info
                if (driver != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(localizations.driverSectionTitle,
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      _infoRow(localizations.driverName, driver.name),
                      _infoRow(localizations.driverPhone, driver.phone),
                      _infoRow(localizations.driverPlate, driver.taxi.plate),
                    ],
                  )
                ] else ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localizations.driverSectionTitle,
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      _infoRow(localizations.driverName, localizations.notAvailable),
                      _infoRow(localizations.driverPhone, localizations.notAvailable),
                      _infoRow(localizations.driverPlate, localizations.notAvailable),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        spacing: 4.0,
        children: [
          SvgPicture.asset(
            "assets/icons/list_icon.svg",
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSecondaryContainer,
              BlendMode.srcIn,
            ),
          ),
          Text('$label ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value ?? '', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyLarge),
          )
        ],
      ),
    );
  }
}
