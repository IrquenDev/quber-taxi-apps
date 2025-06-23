import 'package:flutter/material.dart';
import 'package:quber_taxi/common/pages/sos/emergency_dialog.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class DriverTripInfo extends StatefulWidget {

  final num distance;
  final String originName;
  final String destinationName;
  final TaxiType taxiType;
  final Future<bool> Function(String query) onSearch;
  final void Function(bool isEnabled) onGuidedRouteSwitched;

  const DriverTripInfo({
    super.key,
    required this.originName,
    required this.destinationName,
    required this.distance,
    required this.taxiType,
    required this.onSearch,
    required this.onGuidedRouteSwitched
  });

  @override
  State<DriverTripInfo> createState() => _DriverTripInfoState();
}

class _DriverTripInfoState extends State<DriverTripInfo> {

  bool _showGuidedRoute = false;
  final _tfController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final mediaHeight = MediaQuery.of(context).size.height;
    final overlayHeight = _showGuidedRoute
        ? mediaHeight * 0.40
        : mediaHeight * 0.30;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.borderRadius)),
      child: SizedBox(
        height: overlayHeight,
        child: Stack(
          children: [

            // Background Layer
            Positioned.fill(
              child: Container(color: Theme.of(context).colorScheme.primaryContainer),
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
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${(widget.distance.toStringAsFixed(0))} Km'),
                            Text('${(widget.distance * 100).toStringAsFixed(0)} CUP')
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(dimensions.borderRadius)),
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
                                            text: 'Desde: ',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                fontWeight: FontWeight.bold
                                            )
                                          ),
                                          TextSpan(text: widget.originName),
                                        ]
                                      )
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Hasta: ',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                fontWeight: FontWeight.bold
                                            )
                                          ),
                                          TextSpan(
                                              text: widget.destinationName,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                              Text(
                                'Ruta guiada',
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: _showGuidedRoute,
                                activeColor: Theme.of(context).colorScheme.primaryFixedDim,
                                onChanged: (value) {
                                  _tfController.clear();
                                  setState(() => _showGuidedRoute = value);
                                  widget.onGuidedRouteSwitched(value);
                                }
                              )
                            ]
                          ),
                          if (_showGuidedRoute) ... [
                            Text('Ruta exacta', style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 8.0),
                            TextField(
                              controller: _tfController,
                              onChanged: (_) {setState(() {});},
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.location_on_outlined),
                                hintText: 'Seleccione la ubicación de destino',
                                suffixIcon: !_isLoading ? IconButton(
                                    onPressed: _tfController.text.isNotEmpty ? () async {
                                      setState(() => _isLoading = true);
                                      final query = _tfController.text;
                                      final wasSearchSuccess = await widget.onSearch(query);
                                      if(wasSearchSuccess) {
                                        // you can do something here about it
                                      }
                                      setState(() => _isLoading = false);
                                    } : null,
                                    icon: Icon(Icons.search_outlined)
                                ) : CircularProgressIndicator()
                              )
                            )
                          ]
                        ]
                      )
                    ),
                    // SOS Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          padding: dimensions.contentPadding,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Theme.of(context).colorScheme.errorContainer.withAlpha(200),
                          builder: (context) => EmergencyDialog()
                        ),
                        child: Text(
                          'Emergencia (SOS)',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary
                          )
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
              top: _showGuidedRoute ? 20.0 : 10.0,
              child: SizedBox(
                height: 80,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0),
                  child: Image.asset(widget.taxiType.assetRef)
                )
              )
            )
          ]
        )
      )
    );
  }
}