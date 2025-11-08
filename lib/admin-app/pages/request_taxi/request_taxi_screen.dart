import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/admin-app/pages/request_taxi/request_taxi.dart';
import 'package:quber_taxi/client-app/pages/home/map.dart';
import 'package:quber_taxi/navigation/routes/admin_routes.dart';

class RequestTaxiScreenAdmin extends StatelessWidget {
  final String? originName;
  final List<double>? originCoords;
  final String? destinationName;

  const RequestTaxiScreenAdmin({
    super.key,
    this.originName,
    this.originCoords,
    this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MapView(),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const RequestTravelAdminSheet(),
                    ],
                  ),
                ),
              );
            },
          ),
          // Header AppBar
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(AdminRoutes.settings),
                    icon: const Icon(Icons.arrow_back),
                    color: Theme.of(context).colorScheme.shadow,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
