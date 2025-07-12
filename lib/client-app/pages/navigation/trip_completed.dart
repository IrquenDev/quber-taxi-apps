import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart' show CircleStack, showToast;
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/common/models/review.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/services/review_service.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/utils/runtime.dart';

class ClientTripCompleted extends StatefulWidget {

  final Travel travel;
  final int duration;
  final num distance;
  const ClientTripCompleted({super.key, required this.travel, required this.duration, required this.distance});

  @override
  State<ClientTripCompleted> createState() => _ClientTripCompletedState();
}

class _ClientTripCompletedState extends State<ClientTripCompleted> {

  final TextEditingController _commentController = TextEditingController();
  final _reviewService = ReviewService();
  final double _horizontalPadding = 20.0;
  final double _highHorizontalPadding = 40.0;
  int _rating = 0;
  bool get _canSubmitReview => _rating != 0 && _commentController.text.isNotEmpty;
  late Future<List<Review>> _futureReviews;

  Future<void> _refreshReviews() async {
    final newReviews = await _reviewService.findAll();
    setState(() {
      _futureReviews = Future.value(newReviews);
    });
  }

  void _loadTravels() {
    setState(() {
      _futureReviews = _reviewService.findAll();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTravels();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          spacing: 16.0,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
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
                          prototypeBuilder: (index) =>
                              Image.asset('assets/images/driver.png', fit: BoxFit.cover)
                      ),
                      // Title
                      Text(
                          loc.tripCompleted,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                      ),
                      // Timestamp
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: _highHorizontalPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 8.0,
                          children: [
                            Text(
                                'Fecha',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                            ),
                            Text('Martes, 20 de mayo de 2025'),
                          ]
                        )
                      )
                    ]
                  ),
                  const Divider(),
                  // Comment & Reviews Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.0,
                    children: [
                      Text(
                        loc.reviewSctHeader,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                      ),
                      Text(loc.reviewTooltip, style: Theme.of(context).textTheme.bodySmall),
                      // Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Theme.of(context).colorScheme.primaryContainer
                            ),
                            onPressed: () => setState(() => _rating = index + 1)
                          );
                        }),
                      ),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: loc.reviewTextHint,
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.send_outlined),
                              onPressed: _canSubmitReview && hasConnection(context) ? () async {
                                final response = await _reviewService.submitReview(
                                  comment: _commentController.text,
                                  rating: _rating,
                                  clientId: widget.travel.client.id,
                                  driverId: widget.travel.driver!.id,
                                );
                                if(!context.mounted) return;
                                if(response.statusCode != 200) {
                                  showToast(context: context, message: "No se pudo guardar tu valoración");
                                } else {
                                  showToast(context: context, message: "Gracias por tu tiempo");
                                  _commentController.clear();
                                  _refreshReviews(); // update comments count message
                                }
                              }  : null
                          )
                        )
                      ),
                      // Comment history
                      FutureBuilder(
                          future: _futureReviews,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            else if(snapshot.hasError) {
                              return Center(child: Text("No se pudieron cargar las reseñas"));
                            }
                            else if(!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text(loc.noReviews));
                            }
                            else {
                              final data = snapshot.data;
                              final commentsCount = data!.length;
                              return Padding(
                                  padding: EdgeInsets.only(left: _horizontalPadding),
                                  child: Row(
                                      spacing: 20.0,
                                      children: [
                                        // People who commented
                                        CircleStack(
                                            count: commentsCount <= 4 ? commentsCount : 4,
                                            radius: 16,
                                            offset: 8,
                                            // TODO("yapmDev": @Reminder)
                                            // - Display client images properly
                                            // - First, we need to do a little work on the REST API side to provide
                                            // images as static files. On the Flutter side, the relevant models and
                                            // services are ready.
                                            prototypeBuilder: (index) => Image.asset(
                                                'assets/images/vehicles/mdpi/standard.png', fit: BoxFit.cover
                                            )
                                        ),
                                        GestureDetector(
                                          onTap: commentsCount != 0 ? ()=> context.push(
                                              ClientRoutes.quberReviews,
                                              extra: data
                                          ) : null,
                                          child: Text(
                                            '$commentsCount comentarios',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.bold
                                            )
                                          ),
                                        )
                                      ]
                                  )
                              );
                            }
                          }
                      )
                    ]
                  ),
                  const Divider(),
                  Column(
                    spacing: 8.0,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TripDetailRow(label: 'Precio del Viaje', text: '${(widget.distance * 100).toStringAsFixed(0)} CUP'),
                      TripDetailRow(label: 'Tiempo Transcurrido', text: '${widget.duration.toStringAsFixed(0)} minutos'),
                      TripDetailRow(label: 'Distancia Recorrida', text: '${widget.distance.toStringAsFixed(0)} Km'),
                      TripDetailRow(label: 'Origen', text: widget.travel.originName),
                      TripDetailRow(label: 'Destino', text: widget.travel.destinationName),
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
                onPressed: () {},
                child:  Text(
                  'Aceptar',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16),
                )
              )
            )
          ]
        )
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