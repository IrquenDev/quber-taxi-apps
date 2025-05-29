import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:quber_taxi/client-app/pages/home/search_destination.dart';
import 'package:quber_taxi/client-app/pages/home/search_origin.dart';
import 'package:quber_taxi/client-app/pages/search_driver.dart';
import 'package:quber_taxi/common/models/mapbox_place.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:turf/turf.dart' as turf;
import 'package:quber_taxi/enums/municipalities.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/util/turf.dart';

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
  TaxiType _selectedVehicle = TaxiType.standard;
  bool _hasPets = false;
  num? _minDistance, _maxDistance;
  num? _minPrice, _maxPrice;

  bool get canEstimateDistance => _originName != null && _originCoords != null && _destinationName != null;

  Future<void> _estimateDistance() async {
    // Match .geojson
    final geoJsonPath = Municipalities.resolveGeoJsonRef(_destinationName!);
    if (geoJsonPath == null) {
      showToast(context: context, message: "Municipio no reconocido: ${_destinationName!}");
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
                                    final mapboxPlace = await Navigator.of(context).push<MapboxPlace>(
                                        MaterialPageRoute(builder: (context)=> SearchOriginPage())
                                    );
                                    setState(() {
                                      _originName = mapboxPlace?.placeName;
                                      _originCoords = mapboxPlace?.coordinates;
                                    });
                                    if(canEstimateDistance) _estimateDistance();
                                  },
                                  child: Text(
                                      _originName ?? "Seleccione el lugar de origen",
                                      style: Theme.of(context).textTheme.bodyLarge
                                  )
                              ),
                              Divider(height: 1),
                              GestureDetector(
                                  onTap: () async {
                                    _destinationName = await Navigator.of(context).push<String>(
                                        MaterialPageRoute(builder: (context)=> SearchDestinationPage())
                                    );
                                    if(canEstimateDistance) _estimateDistance();
                                  },
                                  child: Text(
                                      _destinationName ?? "Seleccione el municipio de destino",
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
                child: Text("¿Qué tipo de vehículo prefiere?", style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold
                ))
              ),
              // Available taxis list view
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(TaxiType.values.length, _vehicleItemBuilder),
              ),
              // Seats selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "¿Cuántas personas viajan?",
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
                  Text("¿Lleva mascota?", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                  Text("Distancia mínima:"), Text(_minDistance != null ? '${_minDistance!.toStringAsFixed(2)} km' : "-")
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Distancia máxima:"),
                  Text(_maxDistance != null ? '${_maxDistance!.toStringAsFixed(2)}'' km' : "-")
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Precio mínimo:"), Text(_minPrice != null ? '${_minPrice!.toStringAsFixed(0)} CUP' : "-")
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Precio máximo que puede costar:"),
                  Text(_maxPrice != null ? '${_maxPrice!.toStringAsFixed(0)} CUP' : "-")
                ]
              ),
              // Submit travel request
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canEstimateDistance ? () async {
                      final travel = await _travelService.requestNewTravel(
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
                      print('TRAVEL ID: ${travel.id}');
                      final wasAccepted = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (context) => SearchDriver(travelId: travel.id))
                      );
                      if(!context.mounted) return;
                      if(wasAccepted ?? false) {
                        showToast(context: context, message: "Su viaje fue aceptado", duration: Duration(seconds: 5));
                      }
                    } : null,
                    child: const Text("Pedir taxi"),
                  )
              )
            ]
        )
    );
  }

  Widget _vehicleItemBuilder(int index) {

    final vehicle = TaxiType.values[index];
    final isSelected = _selectedVehicle == vehicle;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
        onTap: () => setState(() => _selectedVehicle= vehicle),
        child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(dimensions.borderRadius),
              boxShadow: [
                BoxShadow(color: colorScheme.shadow.withAlpha(25), blurRadius: 6, offset: const Offset(0, 3))
              ],
              border: isSelected ?
              Border.all(color: colorScheme.primaryFixedDim, width: 2)
                  : Border.all(color: colorScheme.outline)
            ),
            width: 120,
            height: 120,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("vehículo", style: Theme.of(context).textTheme.bodySmall),
                              Text(vehicle.displayText, style: Theme.of(context).textTheme.labelLarge),
                            ],
                          ),
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle
                              ),
                              padding: const EdgeInsets.all(2),
                              child: Icon(Icons.check_outlined, size: Theme.of(context).iconTheme.size! / 1.5),
                            )
                        ]
                    ),
                  ),
                  Expanded(child: Image.asset(vehicle.assetRef))
                ]
            )
        )
    );
  }
}