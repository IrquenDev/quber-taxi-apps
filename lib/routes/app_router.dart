import 'package:go_router/go_router.dart';
import 'package:quber_taxi/client-app/pages/home/home.dart';
import 'package:quber_taxi/client-app/pages/home/search_destination.dart';
import 'package:quber_taxi/client-app/pages/home/search_origin.dart';
import 'package:quber_taxi/client-app/pages/navigation/client_navigation.dart';
import 'package:quber_taxi/client-app/pages/navigation/quber_reviews.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/models/review.dart';
import 'package:quber_taxi/common/models/taxi.dart';
import 'package:quber_taxi/driver-app/pages/navigation/driver_navigation.dart';
import 'package:quber_taxi/client-app/pages/search_driver/search_driver.dart';
import 'package:quber_taxi/client-app/pages/track_driver/track_driver.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/widgets/location_picker.dart';
import 'package:quber_taxi/driver-app/pages/home/home.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/enums/travel_state.dart';
import 'package:quber_taxi/util/runtime.dart';
import '../client-app/pages/client_account/confirm_selfie.dart';
import '../client-app/pages/client_account/create_account.dart';
import '../client-app/pages/client_account/identity_verification.dart';
import '../driver-app/pages/admin_panel/admin_panel.dart';
import '../driver-app/pages/driver_account/driver_account.dart';
import '../driver-app/pages/info-driver/info_driver.dart';
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
        builder: (context, state) {
          // final travel = state.extra as Travel;
          // @Demo
          final travel = Travel(
              id: 1,
              originName: "Parque de la Fraternidad",
              destinationName: "Playa",
              originCoords: <num>[-82.3598, 23.1380],
              requiredSeats: 4,
              hasPets: true,
              taxiType: TaxiType.xhdpiComfort,
              minDistance: 5,
              maxDistance: 22,
              minPrice: 500,
              maxPrice: 3500,
              state: TravelState.inProgress,
              client: Client(id: 1, name: "Yosmel Pérez", phone: 56285623.toString()),
              driver: Driver(id: 1, name: "Juan", imageUrl: "", phone: "", email: "", credit: 0.0,
                  paymentDate: DateTime.now(), rating: 0.0,
                  taxi: Taxi(id: 1, plate: "", imageUrl: "", seats: 4, type: TaxiType.mdpiStandard)
              )
          );
          return ClientNavigation(travel: travel);
        }
    ),

    GoRoute(
        path: RoutePaths.quberReviews,
        builder: (context, state) {
          final reviews = state.extra as List<Review>;
          return QuberReviews(reviews: reviews);
        }
    ),

    GoRoute(
        path: RoutePaths.driverHome,
        builder: (context, state) => const DriverHome()
    ),

    GoRoute(
        path: RoutePaths.driverNavigation,
        builder: (context, state) {
          // final travel = state.extra as Travel;
          // @Demo
          final travel = Travel(
              id: 1,
              originName: "Parque de la Fraternidad",
              destinationName: "Playa",
              originCoords: <num>[-82.3598, 23.1380],
              requiredSeats: 4,
              hasPets: true,
              taxiType: TaxiType.xhdpiComfort,
              minDistance: 5,
              maxDistance: 22,
              minPrice: 500,
              maxPrice: 3500,
              state: TravelState.inProgress,
              client: Client(id: 1, name: "Yosmel Pérez", phone: 56285623.toString())
          );
          return DriverNavigation(travel: travel);
        }
    ),


    GoRoute(path: RoutePaths.identityVerification,
        builder: (context, state) => const IdentityVerificationPage()
    ),

    GoRoute(path: RoutePaths.confirmSelfie,
        builder: (context, state) => const ConfirmSelfiePage()
    ),

    GoRoute(path: RoutePaths.createAccount,
        builder: (context, state) => CreateClientAccountPage()),

    GoRoute(path: RoutePaths.infoDriver,
        builder: (context, state) => const DriverInfoPage()),

    GoRoute(path: RoutePaths.panelAdmin,
        builder: (context, state) => const AdminSettingsPage()),

    GoRoute(path: RoutePaths.driverAccount,
        builder: (context, state) => const DriverAccountSettingPage()),

  ]
);
