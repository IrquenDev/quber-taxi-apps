import 'package:flutter/material.dart';
import 'package:quber_taxi/common/pages/sos/emergency_dialog.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/enums/asset_dpi.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class DriverTripInfo extends StatefulWidget {

  final num? distance;
  final String originName;
  final String destinationName;
  final TaxiType taxiType;
  final double? travelPriceByTaxiType;
  final void Function(bool isEnabled) onGuidedRouteSwitched;
  final bool isFixedDestination;

  const DriverTripInfo({
    super.key,
    required this.originName,
    required this.destinationName,
    required this.distance,
    required this.taxiType,
    required this.travelPriceByTaxiType,
    required this.onGuidedRouteSwitched,
    required this.isFixedDestination,
  });

  @override
  State<DriverTripInfo> createState() => _DriverTripInfoState();
}

class _DriverTripInfoState extends State<DriverTripInfo> {

  bool _showGuidedRoute = false;
  final _tfController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<DimensionExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final mediaHeight = MediaQuery.of(context).size.height;
    final overlayHeight = _showGuidedRoute
        ? (widget.isFixedDestination ? mediaHeight * 0.30 : mediaHeight * 0.40)
        : mediaHeight * 0.30;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(dims.borderRadius)),
      child: SizedBox(
        height: overlayHeight,
        child: Stack(
          children: [
             // Background Layer
            Positioned.fill(
               child: Container(color: colorScheme.primaryContainer),
            ),
            // Distance & Price Info
            Positioned(
              top: 0.0,
              right: 0.0,
              left: 0.0,
              child: Padding(
                padding: EdgeInsets.only(top: 16.0, left: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16.0,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4.0,
                      children: [Text('DISTANCIA:'), Text('PRECIO:')],
                    ),
                    DefaultTextStyle(
                        style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.distance != null ? '${widget.distance!.toStringAsFixed(0)} Km' : '-'),
                              Text(widget.travelPriceByTaxiType != null && widget.distance != null
                                  ? '${(widget.distance! * widget.travelPriceByTaxiType!).toStringAsFixed(0)} CUP'
                                  : '-'
                              )
                            ]
                        )
                    )
                  ]
                )
              )
            ),
            // Top layer (Origin & Destination + Guided Route Section + SOS Button) 
            Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: ClipRRect(
                 borderRadius: BorderRadius.vertical(top: Radius.circular(dims.borderRadius)),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryFixed,
                      ),
                       padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Origin & Destination
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: const [
                                  Icon(Icons.my_location, size: 20, color: Colors.grey),
                                  Icon(Icons.more_vert, size: 14, color: Colors.grey),
                                  Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                                ],
                              ),
                              SizedBox(width: 12.0),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 12.0,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                           TextSpan(
                                             text: loc.from,
                                             style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
                                           ),
                                          TextSpan(text: widget.originName),
                                        ]
                                      )
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                           TextSpan(
                                             text: loc.until,
                                             style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
                                           ),
                                          TextSpan(
                                              text: widget.destinationName,
                                               style: textTheme.bodyMedium?.copyWith(
                                                  overflow: TextOverflow.ellipsis
                                              )
                                          )
                                        ]
                                      )
                                    )
                                  ]
                                ),
                              )
                            ]
                          ),
                          // Guided Route Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(loc.guidedRoute, style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                              Switch(
                                value: _showGuidedRoute,
                                 activeColor: colorScheme.primaryFixedDim,
                                onChanged: (value) {
                                  _tfController.clear();
                                  setState(() => _showGuidedRoute = value);
                                  widget.onGuidedRouteSwitched(value);
                                }
                              )
                            ]
                          ),
                          if (_showGuidedRoute && !widget.isFixedDestination)
                            Text("Mantén pulsado en el mapa para escoger un destino")
                        ]
                      )
                    ),
                    // SOS Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          padding: dims.contentPadding,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: colorScheme.errorContainer.withAlpha(200),
                          builder: (context) => EmergencyDialog()
                        ),
                        child: Text(
                          loc.emergencySOS,
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSecondary)
                        )
                      )
                    )
                  ]
                )
              )
            ),
            // Taxi Type Image
            Positioned(
              right: 16,
              top: _showGuidedRoute && !widget.isFixedDestination ? 20.0 : 10.0,
              child: SizedBox(
                height: 80,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0),
                  child: Image.asset(widget.taxiType.assetRef(AssetDpi.xhdpi))
                )
              )
            )
          ]
        )
      )
    );
  }
}