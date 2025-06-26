import 'package:go_router/go_router.dart';
import 'package:quber_taxi/client-app/pages/client_account/confirm_selfie.dart';
import 'package:quber_taxi/client-app/pages/client_account/create_account.dart';
import 'package:quber_taxi/client-app/pages/client_account/identity_verification.dart';
import 'package:quber_taxi/client-app/pages/home/home.dart';
import 'package:quber_taxi/client-app/pages/home/search_destination.dart';
import 'package:quber_taxi/client-app/pages/home/search_origin.dart';
import 'package:quber_taxi/client-app/pages/navigation/client_navigation.dart';
import 'package:quber_taxi/client-app/pages/navigation/quber_reviews.dart';
import 'package:quber_taxi/client-app/pages/search_driver/search_driver.dart';
import 'package:quber_taxi/client-app/pages/track_driver/track_driver.dart';
import 'package:quber_taxi/common/models/review.dart';
import 'package:quber_taxi/common/models/travel.dart';

import 'package:quber_taxi/common/pages/about_dev/about_dev.dart';
import 'package:quber_taxi/common/pages/about_us/about_us.dart';

import 'package:quber_taxi/common/pages/location_picker/location_picker.dart';
import 'package:quber_taxi/common/pages/login/login.dart';
import 'package:quber_taxi/common/pages/trip/trip_list.dart';
import 'package:quber_taxi/driver-app/pages/admin_panel/admin_panel.dart';
import 'package:quber_taxi/driver-app/pages/create_account/verification_page.dart';
import 'package:quber_taxi/driver-app/pages/driver_account/driver_account.dart';
import 'package:quber_taxi/driver-app/pages/home/home.dart';
import 'package:quber_taxi/driver-app/pages/info-driver/info_driver.dart';
import 'package:quber_taxi/driver-app/pages/navigation/driver_navigation.dart';
import 'package:quber_taxi/util/runtime.dart' as runtime;
import 'route_paths.dart';

final GoRouter appRouter = GoRouter(

  // App start up route. You can change it for developing or testing, just remember to take it back in place.
  initialLocation: runtime.isSessionOk ?? false
      ? runtime.isClientMode ? RoutePaths.clientHome : RoutePaths.driverHome : RoutePaths.login,
  
  routes: [
    GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage()
    ),

    GoRoute(
      path: RoutePaths.clientHome,
      builder: (context, state) => ClientHome()
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
          final travel = state.extra as Travel;
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
        builder: (context, state) => DriverHome()
    ),

    GoRoute(
        path: RoutePaths.driverNavigation,
        builder: (context, state) {
          final travel = state.extra as Travel;
          return DriverNavigation(travel: travel);
        }
    ),
    GoRoute(
        path: RoutePaths.driverCreateAccount,
        builder: (context, state) => const VerificationIdentityPage()
    ),

    GoRoute(path: RoutePaths.identityVerification,
        builder: (context, state) => const IdentityVerificationPage()
    ),

    GoRoute(path: RoutePaths.confirmSelfie,
        builder: (context, state) => const ConfirmSelfiePage()
    ),

    GoRoute(path: RoutePaths.createAccount,
        builder: (context, state) => CreateClientAccountPage()
    ),

    GoRoute(
        path: RoutePaths.infoDriver,
        builder: (context, state) {
          final driverId = state.extra as int;
          return DriverInfoPage(driverId: driverId);
        }
    ),

    GoRoute(path: RoutePaths.panelAdmin,
        builder: (context, state) => const AdminSettingsPage()
    ),

    GoRoute(path: RoutePaths.driverAccount,
        builder: (context, state) => const DriverAccountSettingPage()
    ),

    GoRoute(path: RoutePaths.aboutDev,
    builder: (context, state) => const AboutDevPage()),

    GoRoute(path: RoutePaths.aboutUs,
    builder: (context, state) => const AboutUsPage()),

    GoRoute(path: RoutePaths.tripList,
    builder: (context, state) => const TripsPage())
  ]
);
