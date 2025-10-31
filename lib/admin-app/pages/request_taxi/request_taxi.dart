import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/common/models/mapbox_place.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/admin_service.dart';
import 'package:quber_taxi/common/services/mapbox_service.dart';
import 'package:quber_taxi/common/services/travel_service.dart';
import 'package:quber_taxi/common/widgets/dialogs/info_dialog.dart';
import 'package:quber_taxi/enums/asset_dpi.dart';
import 'package:quber_taxi/enums/municipalities.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/utils/map/turf.dart';
import 'package:turf/turf.dart' as turf;

class RequestTravelAdminSheet extends StatefulWidget {
  const RequestTravelAdminSheet({super.key});

  @override
  State<RequestTravelAdminSheet> createState() => _RequestTravelAdminSheetState();
}

class _RequestTravelAdminSheetState extends State<RequestTravelAdminSheet> {
  // The service in charge of travel-related operations
  final _travelService = TravelService();
  final _adminService = AdminService();

  // Admin UI: no client object needed
  // Travel's origin
  String? _originName;
  List<num>? _originCoords;

  // Travel's destination
  String? _destinationName;
  List<num>? _destinationCoords;

  // Other aspects of the trip
  int _passengerCount = 1;
  TaxiType _selectedTaxi = TaxiType.standard;
  bool _hasPets = false;

  // It reflects whether the user has chosen a specific destination or municipality. The distance and price of the
  // trip will be calculated accordingly.
  bool _usingFixedDestination = false;

  // Specific destination case
  double? _fixedDistance, _fixedPrice;

  // Case of municipality as a destination
  double? _minDistance, _maxDistance;
  double? _minPrice, _maxPrice;

  // Price by type of taxi
  late final Map<TaxiType, double> _taxiPrices;

  // Calculate the price according to the given distance and the type of taxi already selected
  double _getPriceByDistance(double distance) => _taxiPrices[_selectedTaxi]! * distance;

  // It reflects when it is already possible to estimate a distance for when a specific destination has been set.
  bool get _canEstimateWithFixedDestination =>
      _usingFixedDestination == true &&
      (_originName != null && _originCoords != null) &&
      (_destinationName != null && _destinationCoords != null);

  // It reflects when it is already possible to estimate a distance for when a municipality has been set as a
  // destination
  bool get _canEstimateWithUnfixedDestination =>
      _usingFixedDestination == false && (_originName != null && _originCoords != null) && (_destinationName != null);

  // It is possible to estimate a distance when any of the above conditions are met
  bool get _canEstimateDistance => _canEstimateWithFixedDestination || _canEstimateWithUnfixedDestination;

  // Allows to know whether travel price should be updated when changing the preferred taxi type for the trip.
  bool get _shouldUpdatePriceOnSelectedTaxiChanged => (_minPrice != null && _maxPrice != null) || (_fixedPrice != null);

  final _formKey = GlobalKey<FormState>();
  late String _normalizedPhone;

  String _normalizePhoneNumber(String phone) {
    // Remove all spaces and trim
    String cleanPhone = phone.trim().replaceAll(' ', '');
    // Remove + if present
    if (cleanPhone.startsWith('+')) {
      cleanPhone = cleanPhone.substring(1);
    }
    // Remove country code (53) if present
    if (cleanPhone.startsWith('53') && cleanPhone.length > 8) {
      cleanPhone = cleanPhone.substring(2);
    }
    return cleanPhone;
  }

  // It is responsible for calculating the distance and, consequently, the price of the trip. It should only be
  // called when _canEstimateDistance is true.
  Future<void> _estimateDistance() async {
    if (_usingFixedDestination) {
      // Check connection first
      if (hasConnection(context)) {
        // Get the Mapbox suggested route. Even if we only care about the distance from here, the estimate between
        // two points is very precise.
        final route = await MapboxService().getRoute(
            originLng: _originCoords![0],
            originLat: _originCoords![1],
            destinationLng: _destinationCoords![0],
            destinationLat: _destinationCoords![1]);
        // Mapbox.distance is given in meters, we need to convert to km here
        final distance = route.distance / 1000;
        // Update UI with results
        setState(() {
          _fixedDistance = distance;
          _fixedPrice = _getPriceByDistance(_fixedDistance!);
        });
      } else {
        return;
      }
    } else {
      // Match .geojson
      final geoJsonPath = Municipalities.resolveGeoJsonRef(_destinationName!);
      if (geoJsonPath == null) {
        showToast(context: context, message: "${AppLocalizations.of(context)!.unknown} ${_destinationName!}");
        return;
      }
      // Load .geojson
      final polygon = await GeoUtils.loadGeoJsonPolygon(geoJsonPath);
      // Calculate entrypoint
      final benchmark = turf.Position(_originCoords![0], _originCoords![1]);
      final entryPoint = GeoUtils.findNearestPointInPolygon(benchmark: benchmark, polygon: polygon);
      // Calculate farthest point from entrypoint
      final farthestPoint = GeoUtils.findFarthestPointInPolygon(benchmark: entryPoint.point, polygon: polygon);
      // Update UI with results
      setState(() {
        _minDistance = entryPoint.distance.toDouble();
        _maxDistance = _minDistance! + farthestPoint.distance;
        _minPrice = _getPriceByDistance(_minDistance!);
        _maxPrice = _getPriceByDistance(_maxDistance!);
      });
    }
  }

  // It is responsible for canceling the previous trip request, either because the driver search was canceled by
  // manual action of the user or because the time limit has passed.
  Future<void> _cancelTravelRequest(int travelId) async {
    final response = await _travelService.changeState(travelId: travelId, state: TravelState.canceled);
    if (!mounted) return;
    if (response.statusCode == 200) {
      showToast(context: context, message: AppLocalizations.of(context)!.tripRequestCancelled);
    }
  }

  double _roundTo2Dec(double val) => double.parse(val.toStringAsFixed(2));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (hasConnection(context)) {
        final quberConfig = await AdminService().getQuberConfig();
        if (quberConfig != null) {
          _taxiPrices = quberConfig.travelPrice;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 12.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Origin / Destination inputs.
            Row(
              spacing: 16.0,
              children: [
                Column(
                  children: [
                    const Icon(Icons.my_location),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Container(width: 1.5, height: 20.0, color: Theme.of(context).dividerColor)),
                    const Icon(Icons.location_on_outlined)
                  ],
                ),
                Expanded(
                  child: Column(
                    spacing: 12.0,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            final mapboxPlace = await context.push<MapboxPlace>(ClientRoutes.searchOrigin);
                            if (mapboxPlace != null) {
                              setState(() {
                                _originName = mapboxPlace.text;
                                _originCoords = mapboxPlace.coordinates;
                              });
                              if (_canEstimateDistance) _estimateDistance();
                            }
                          },
                          child: Text(_originName ?? AppLocalizations.of(context)!.originName,
                              style: textTheme.bodyLarge)),
                      const Divider(height: 1, thickness: 1),
                      GestureDetector(
                        onTap: () async {
                          final resultData = await context.push<Map<String, dynamic>?>(ClientRoutes.searchDestination);
                          if (resultData != null) {
                            _usingFixedDestination = resultData["usingFixedDestination"];
                            // The user has chosen a specific destination
                            if (_usingFixedDestination) {
                              final place = resultData["destination"] as MapboxPlace;
                              setState(() {
                                _destinationName = place.text;
                                _destinationCoords = place.coordinates;
                                _minDistance = null;
                                _maxDistance = null;
                                _minPrice = null;
                                _maxPrice = null;
                              });
                            }
                            // The user has chosen a municipality as a destination
                            else {
                              final municipality = resultData["destination"] as String;
                              setState(() {
                                _destinationName = municipality;
                                _fixedDistance = null;
                                _fixedPrice = null;
                              });
                            }
                            // Estimate distance regardless of the type of destination chosen
                            if (_canEstimateDistance) _estimateDistance();
                          }
                        },
                        child: Text(
                          _destinationName ?? AppLocalizations.of(context)!.destinationName,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            // Taxi preference header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                localizations.askTaxi,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            // Available taxis list view
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: TaxiType.values.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _taxiItemBuilderAdmin(index, textTheme),
                ),
              ),
            ),
            // Seats selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.howTravels,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (_passengerCount > 1) {
                            setState(() => _passengerCount--);
                          }
                        },
                        icon: const Icon(Icons.remove)),
                    Text("$_passengerCount", style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (_passengerCount < 20) {
                            setState(() => _passengerCount++);
                          }
                        },
                        icon: const Icon(Icons.add))
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.pets,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _hasPets,
                  activeColor: colorScheme.primaryFixedDim,
                  onChanged: (value) => setState(() => _hasPets = value),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.phoneNumber,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    maxLength: 12,
                    decoration: InputDecoration(
                      errorMaxLines: 2,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      hintText: AppLocalizations.of(context)!.phoneHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.requiredField;
                      }
                      final normalizedPhone = _normalizePhoneNumber(value);
                      if (normalizedPhone.length != 8 || !RegExp(r'^\d{8}$').hasMatch(normalizedPhone)) {
                        return AppLocalizations.of(context)!.invalidPhoneMessage;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _normalizedPhone = _normalizePhoneNumber(value);
                      }
                    },
                  ),
                )
              ],
            ),
            // Divider
            const Divider(height: 24, thickness: 1),
            // Estimations for distance and price
            if (_canEstimateDistance)
              Column(
                spacing: 12.0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizations.tooltipAboutEstimations, style: textTheme.bodySmall),
                  if (_canEstimateWithFixedDestination)
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      // Fixed Distance
                      _buildEstimationInfoRowAdmin(textTheme, localizations.distance,
                          _fixedDistance != null ? '${_roundTo2Dec(_fixedDistance!)} km' : "-"),
                      // Fixed Price
                      _buildEstimationInfoRowAdmin(textTheme, localizations.price,
                          _fixedPrice != null ? '${_roundTo2Dec(_fixedPrice!)} CUP' : "-")
                    ]),
                  if (_canEstimateWithUnfixedDestination)
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      // Minimum Distance
                      _buildEstimationInfoRowAdmin(textTheme, localizations.minDistance,
                          _minDistance != null ? '${_roundTo2Dec(_minDistance!)} km' : "-"),
                      // Minimum Price
                      _buildEstimationInfoRowAdmin(textTheme, localizations.minPrice,
                          _minPrice != null ? '${_roundTo2Dec(_minPrice!)} CUP' : "-"),
                      // Maximum Distance
                      _buildEstimationInfoRowAdmin(textTheme, localizations.maxDistance,
                          _maxDistance != null ? '${_roundTo2Dec(_maxDistance!)} km' : "-"),
                      // Maximum Price
                      _buildEstimationInfoRowAdmin(textTheme, localizations.maxPrice,
                          _maxPrice != null ? '${_roundTo2Dec(_maxPrice!)} CUP' : "-")
                    ]),
                  Row(
                    spacing: 16.0,
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: colorScheme.primary,
                      ),
                      Expanded(
                        child: Text(
                          "Se recomienda informar primero al cliente de estos valores guía antes de solicitar el "
                          "viaje.",
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            // Submit travel request
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  foregroundColor: colorScheme.secondary,
                  backgroundColor: colorScheme.primaryContainer,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 100),
                ),
                onPressed: _canEstimateDistance && hasConnection(context)
                    ? () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();
                        final response = await _adminService.requestNewTravel(
                          clientPhone: _normalizedPhone,
                          originName: _originName!,
                          destinationName: _destinationName!,
                          originCoords: _originCoords!,
                          destinationCoords: _destinationCoords,
                          requiredSeats: _passengerCount,
                          hasPets: _hasPets,
                          taxiType: _selectedTaxi,
                          fixedDistance: _fixedDistance,
                          minDistance: _minDistance,
                          maxDistance: _maxDistance,
                          fixedPrice: _fixedPrice,
                          minPrice: _minPrice,
                          maxPrice: _maxPrice,
                        );
                        if (!context.mounted) return;
                        if (response.statusCode == 200) {
                          final travel = Travel.fromJson(jsonDecode(response.body));
                          // Radar animation while waiting for acceptation.
                          final updatedTravel = await context.push<Travel?>(
                            ClientRoutes.searchDriver,
                            extra: {
                              'travelId': travel.id,
                              'travelRequestedDate': travel.requestedDate,
                              'wasPageRestored': false,
                            },
                          );
                          if (!context.mounted) return;
                          if (updatedTravel != null) {
                            // Navigate to TrackDriver Screen.
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => InfoDialog(
                                      title: "Viaje Aceptado",
                                      bodyMessage: "Teléfono de contacto de conductor: ${updatedTravel.driver!.phone}",
                                      onAccept: () => context.pop(),
                                    ));
                          } else {
                            // Cancel this travel request
                            if (hasConnection(context)) {
                              await _cancelTravelRequest(travel.id);
                            }
                          }
                        } else if (response.statusCode == 403) {
                          showToast(
                            context: context,
                            message: "El estado actual de la cuenta del cliente es BLOQUEADO. Puesto que ha sido "
                                "reportado por mal comportamiento ya no se le permite solicitar nuevos viajes.",
                            durationInSeconds: 4,
                          );
                        } else if (response.statusCode == 404) {
                          showToast(
                            context: context,
                            message: "No hay ningún cliente registrado con el teléfono proporcionado.",
                            durationInSeconds: 4,
                          );
                        } else if (response.statusCode == 409) {
                          showToast(
                            context: context,
                            message: "Este cliente ya se encuentra en un viaje activo",
                            durationInSeconds: 4,
                          );
                        } else {
                          showToast(
                            context: context,
                            message: "Ocurrió algo mal, por favor inténtelo más tarde",
                            durationInSeconds: 4,
                          );
                        }
                      }
                    : null,
                child: Text(AppLocalizations.of(context)!.askTaxi),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taxiItemBuilderAdmin(int index, TextTheme textTheme) {
    final taxi = TaxiType.values[index];
    final isSelected = _selectedTaxi == taxi;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        if (_shouldUpdatePriceOnSelectedTaxiChanged) {
          if (_usingFixedDestination) {
            setState(() {
              _selectedTaxi = taxi;
              _fixedPrice = _getPriceByDistance(_fixedDistance!);
            });
          } else {
            setState(() {
              _selectedTaxi = taxi;
              _minPrice = _getPriceByDistance(_minDistance!);
              _maxPrice = _getPriceByDistance(_maxDistance!);
            });
          }
        } else {
          setState(() {
            _selectedTaxi = taxi;
          });
        }
      },
      child: SizedBox(
        height: 120,
        width: 130,
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
                                  Text(localizations.vehicle, style: textTheme.bodySmall),
                                  if (isSelected) const SizedBox(width: 8.0),
                                  if (isSelected)
                                    SizedBox(
                                      width: Theme.of(context).iconTheme.size! * 0.75,
                                      height: Theme.of(context).iconTheme.size! * 0.75,
                                      child: SvgPicture.asset("assets/icons/yellow_check.svg"),
                                    )
                                ],
                              ),
                              Text(TaxiType.nameOf(taxi, localizations), style: textTheme.labelLarge)
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Vehicle Image
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                child: Image.asset(
                  taxi.assetRef(AssetDpi.xhdpi),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEstimationInfoRowAdmin(TextTheme textTheme, String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: textTheme.bodyLarge),
      Text(value, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))
    ]);
  }
}
