import 'package:go_router/go_router.dart';
import 'package:quber_taxi/client-app/pages/home/home.dart';
import 'package:quber_taxi/client-app/pages/home/search_destination.dart';
import 'package:quber_taxi/client-app/pages/home/search_origin.dart';
import 'package:quber_taxi/client-app/pages/navigation/client_navigation.dart';
import 'package:quber_taxi/driver-app/pages/navigation/driver_navigation.dart';
import 'package:quber_taxi/client-app/pages/search_driver.dart';
import 'package:quber_taxi/client-app/pages/track_driver.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/widgets/location_picker.dart';
import 'package:quber_taxi/driver-app/pages/home/home.dart';
import 'package:quber_taxi/util/runtime.dart';
import 'route_paths.dart';

final GoRouter appRouter = GoRouter(
  // App start up route. You can change it for developing or testing, just remember to take it back in place.
  initialLocation: isClientMode ? RoutePaths.clientHome : RoutePaths.driverHome,
  routes: [
    GoRoute(
      path: RoutePaths.clientHome,
      builder: (context, state) => const ClientHome()
    ),

    GoRoute(
        path: RoutePaths.searchOrigin,
        builder: (context, state) => const SearchOrigin()
    ),

    GoRoute(
        path: RoutePaths.searchDestination,
        builder: (context, state) => const SearchDestination()
    ),

    GoRoute(
        path: RoutePaths.locationPicker,
        builder: (context, state) => const LocationPicker()
    ),

    GoRoute(
        path: RoutePaths.searchDriver,
        builder: (context, state) {
            final travelId = state.extra as int;
            return SearchDriver(travelId: travelId);
        }
    ),

    GoRoute(
        path: RoutePaths.trackDriver,
        builder: (context, state) {
          final travel = state.extra as Travel;
          return TrackDriver(travel: travel);
        }
    ),

    GoRoute(
        path: RoutePaths.clientNavigation,
        builder: (context, state) => const ClientNavigation()
    ),

    GoRoute(
        path: RoutePaths.driverHome,
        builder: (context, state) => const DriverHome()
    ),
    GoRoute(
        path: RoutePaths.driverNavigation,
        builder: (context, state) => const DriverNavigation()
    )
  ]
);
