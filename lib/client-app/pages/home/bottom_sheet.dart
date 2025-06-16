import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/mapbox_place.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/enums/municipalities.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/routes/route_paths.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/util/turf.dart';
import 'package:turf/turf.dart' as turf;

class RequestTravelSheet extends StatefulWidget {

  final String? originName;
  final List<double>? originCoords;
  final String? destinationName;

  const RequestTravelSheet({super.key, this.originName, this.destinationName, this.originCoords});

  @override
  State<RequestTravelSheet> createState() => _RequestTravelSheetState();
}

class _RequestTravelSheetState extends State<RequestTravelSheet> {

  final _travelService = TravelService();

  String? _originName;
  List<num>? _originCoords;
  String? _destinationName;
  int _passengerCount = 1;
  TaxiType _selectedVehicle = TaxiType.mdpiStandard;
  final List<TaxiType> _taxiTypeList = [TaxiType.mdpiStandard, TaxiType.mdpiFamiliar, TaxiType.mdpiComfort];
  bool _hasPets = false;
  num? _minDistance, _maxDistance;
  num? _minPrice, _maxPrice;

  bool get canEstimateDistance => _originName != null && _originCoords != null && _destinationName != null;

  Future<void> _estimateDistance() async {
    // Match .geojson
    final geoJsonPath = Municipalities.resolveGeoJsonRef(_destinationName!);
    if (geoJsonPath == null) {
      showToast(context: context, message: "${AppLocalizations.of(context)!.unknown} ${_destinationName!}");
      return;
    }
    // Load .geojson
    final polygon = await loadGeoJsonPolygon(geoJsonPath);
    // Calculate entrypoint
    final benchmark = turf.Position(_originCoords![0], _originCoords![1]);
    final entryPoint = findNearestPointInPolygon(benchmark: benchmark, polygon: polygon);
    // Calculate farthest point from entrypoint
    final farthestPoint = findFarthestPointInPolygon(benchmark: entryPoint.point, polygon: polygon);
    // Handling results
    setState(() {
      _minDistance = entryPoint.distance;
      _maxDistance = entryPoint.distance + farthestPoint.distance;
      ///TODO("yapmDev")
      /// - Check real price for distance.
      _minPrice = _minDistance! * 100;
      _maxPrice = _maxDistance! * 100;
    });
  }
  
  @override
  void initState() {
    super.initState();
    _originName = widget.originName;
    _originCoords = widget.originCoords;
    _destinationName = widget.destinationName;
    if(canEstimateDistance) _estimateDistance();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = NetworkScope.of(context).value == ConnectionStatus.online;
    return Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12.0,
            children: [
              // Origin / Destination inputs.
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16.0,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.my_location),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                            child: Container(width: 1.5, height: 32.0, color: Theme.of(context).dividerColor)
                        ),
                        const Icon(Icons.location_on_outlined),
                      ],
                    ),
                    Expanded(
                        child: Column(
                            spacing: 8.0,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                  onTap: () async {
                                    final mapboxPlace = await context.push<MapboxPlace>(RoutePaths.searchOrigin);
                                    setState(() {
                                      _originName = mapboxPlace?.placeName;
                                      _originCoords = mapboxPlace?.coordinates;
                                    });
                                    if(canEstimateDistance) _estimateDistance();
                                  },
                                  child: Text(
                                      _originName ?? AppLocalizations.of(context)!.originName,
                                      style: Theme.of(context).textTheme.bodyLarge
                                  )
                              ),
                              Divider(height: 1),
                              GestureDetector(
                                  onTap: () async {
                                    _destinationName = await context.push<String>(RoutePaths.searchDestination);
                                    if(canEstimateDistance) _estimateDistance();
                                  },
                                  child: Text(
                                      _destinationName ?? AppLocalizations.of(context)!.destinationName,
                                      style: Theme.of(context).textTheme.bodyLarge
                                  )
                              )
                            ]
                        )
                    )
                  ]
              ),
              // Taxi preference header
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.askTaxi, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold
                ))
              ),
              // Available taxis list view
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_taxiTypeList.length, (index) => Flexible(child: _vehicleItemBuilder(index))),
              ),
              // Seats selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      AppLocalizations.of(context)!.howTravels,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {if (_passengerCount > 1) {setState(() => _passengerCount--);}},
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        "$_passengerCount",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => setState(() => _passengerCount++),
                        icon: const Icon(Icons.add_circle_outline),
                      )
                    ]
                  )
                ]
              ),
              // Has pets ?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.pets, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Switch(
                    value: _hasPets,
                    activeColor: Theme.of(context).colorScheme.primaryFixedDim,
                    onChanged: (value) => setState(() => _hasPets = value)
                  )
                ],
              ),
              // Estimations for distance and price
              Divider(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.minDistance), Text(_minDistance != null ? '${_minDistance!.toStringAsFixed(2)} km' : "-")
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.maxDistance),
                  Text(_maxDistance != null ? '${_maxDistance!.toStringAsFixed(2)}'' km' : "-")
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.minPrice), Text(_minPrice != null ? '${_minPrice!.toStringAsFixed(0)} CUP' : "-")
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.maxPrice),
                  Text(_maxPrice != null ? '${_maxPrice!.toStringAsFixed(0)} CUP' : "-")
                ]
              ),
              // Submit travel request
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canEstimateDistance && isConnected ? () async {
                      Travel travel = await _travelService.requestNewTravel(
                          /// TODO("yapmDev": static client id)
                          clientId: 1,
                          originName: _originName!,
                          destinationName: _destinationName!,
                          originCoords: _originCoords!,
                          requiredSeats: _passengerCount,
                          hasPets: _hasPets,
                          taxiType: _selectedVehicle,
                          minDistance: _minDistance!,
                          maxDistance: _maxDistance!,
                          minPrice: _minPrice!,
                          maxPrice: _maxPrice!
                      );
                      if(!context.mounted) return;
                      // Radar animation while waiting for acceptation.
                      final updatedTravel = await context.push<Travel?>(RoutePaths.searchDriver, extra: travel.id);
                      if(!context.mounted) return;
                      if(updatedTravel != null) {
                        // Navigate to TrackDriver Screen.
                        context.go(RoutePaths.trackDriver, extra: updatedTravel);
                      } else {
                        /// TODO ("yapmDev")
                        /// - This travel request should be delete or marked as CANCELED.
                      }
                    } : null,
                    child: Text(AppLocalizations.of(context)!.askTaxi),
                  )
              )
            ]
        )
    );
  }

  Widget _vehicleItemBuilder(int index) {

    final vehicle = _taxiTypeList[index];
    final isSelected = _selectedVehicle == vehicle;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;

    return GestureDetector(
        onTap: () => setState(() => _selectedVehicle= vehicle),
        child: SizedBox(
          height: 120,
          child: Stack(
              children: [
                // Background Card
                Align(
                  alignment: Alignment.centerRight,
                  child: LayoutBuilder(
                    builder: (context, constraints) => SizedBox(
                      // Using a responsive 80% width from parent, also resolved
                      // dynamically by Flexible widget, who's wrapping this items.
                      width: constraints.maxWidth * 0.8,
                      child: Card(
                        elevation: dimensions.elevation,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(AppLocalizations.of(context)!.vehicle, style: Theme.of(context).textTheme.bodySmall),
                                        if (isSelected)
                                          SizedBox(width: 8.0),
                                        if (isSelected)
                                          SizedBox(
                                            width: Theme.of(context).iconTheme.size! * 0.75,
                                            height: Theme.of(context).iconTheme.size! * 0.75,
                                            child: SvgPicture.asset("assets/icons/yellow_check.svg"),
                                          )
                                      ]
                                    ),
                                    Text(vehicle.displayText, style: Theme.of(context).textTheme.labelLarge),
                                  ]
                                )
                              ]
                          )
                        )
                      )
                    )
                  )
                ),
                // Vehicle Image
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 8.0, right: 8.0),
                        child: Image.asset(vehicle.assetRef)
                    )
                )
              ]
          )
        )
    );
  }
}