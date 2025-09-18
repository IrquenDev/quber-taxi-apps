import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart' show CircleStack;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/widgets/dialogs/circular_info_dialog.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class DriverTripCompleted extends StatefulWidget {

  final Travel travel;
  final Driver driver;
  final int? duration;
  final num? distance;
  final double finalPrice;

  const DriverTripCompleted({
    super.key,
    required this.travel,
    required this.driver,
    required this.duration,
    required this.distance,
    required this.finalPrice
  });

  @override
  State<DriverTripCompleted> createState() => _DriverTripCompletedState();
}

class _DriverTripCompletedState extends State<DriverTripCompleted> {

  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dims = Theme.of(context).extension<DimensionExtension>()!;
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(dims.borderRadius)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.0,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Section
                      Column(
                          spacing: 8.0,
                          children: [
                            // Client & Driver Profile Images
                            CircleStack(
                                count: 2, radius: 40.0, offset: 20.0,
                                prototypeBuilder: (index) {
                                  final imageUrl = index == 0
                                      ? widget.travel.client.profileImageUrl
                                      : widget.driver.taxi.imageUrl;
                                  if(imageUrl != null) {
                                    return Image.network("${ApiConfig().baseUrl}/$imageUrl", fit: BoxFit.fill);
                                  } else {
                                    return Image.asset(
                                      index == 0
                                          ? "assets/images/default_profile_picture"
                                          : "assets/images/default_profile_driver",
                                      fit: BoxFit.fill,
                                    );
                                  }
                                }
                            ),
                            // Title
                            Text(
                                loc.tripCompleted,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                            ),
                            // Timestamp
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    spacing: 8.0,
                                    children: [
                                      Text(
                                          loc.dateLabel,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(DateTime.now())),
                                    ]
                                )
                            )
                          ]
                      ),
                      const Divider(),
                      // Comment & Reviews Section
                      Column(
                          spacing: 8.0,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TripDetailRow(
                                label: loc.tripPriceLabel,
                                text: '${widget.finalPrice.toStringAsFixed(0)} ${loc.currencyLabel}'
                            ),
                            TripDetailRow(
                                label: loc.tripDurationLabel,
                                text: widget.duration != null
                                    ? '${widget.duration!.toStringAsFixed(0)} ${loc.minutesLabel}'
                                    : '-'
                            ),
                            TripDetailRow(
                                label: loc.tripDistanceLabel,
                                text: widget.distance != null
                                    ? '${widget.distance!.toStringAsFixed(0)} ${loc.kilometersLabel}'
                                    : '-'
                            ),
                            TripDetailRow(label: loc.originLabel, text: widget.travel.originName),
                            TripDetailRow(label: loc.destinationLabel, text: widget.travel.destinationName),
                            TripDetailRow(
                                label: loc.quberCreditLabel,
                                text: '${(widget.travel.driver!.credit - widget.driver.credit).toStringAsFixed(2)} ${loc.currencyLabel}'
                            ),
                          ]
                      )
                    ]
                ),
              ),
              // Accept Button
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder())
                      ),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CircularInfoDialog(
                              largeNumber: widget.travel.driver!.credit.toInt().toString(),
                              mediumText: AppLocalizations.of(context)!.driverCredit,
                              smallText: AppLocalizations.of(context)!.driverCreditDescription,
                              animateFrom: widget.travel.driver!.credit.toInt(),
                              animateTo: widget.driver.credit.toInt(),
                              onTapToDismiss: () => context.pop(),
                            );
                          },
                        );
                        if(!context.mounted) return;
                        context.go(DriverRoutes.home);
                      },
                      child:  Text(
                        loc.acceptButton,
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16),
                      )
                  )
              )
            ]
        )
    );
  }
}

class TripDetailRow extends StatelessWidget {

  final String label;
  final String text;

  const TripDetailRow({super.key, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
        spacing: 8.0,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(text)
        ]
    );
  }
}
