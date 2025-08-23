import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/admin-app/pages/driver_info/driver_info.dart';
import 'package:quber_taxi/admin-app/pages/settings/admin_settings.dart';
import 'package:quber_taxi/admin-app/pages/trips_list/trip_list.dart';
import 'package:quber_taxi/admin-app/pages/request_taxi/request_taxi_screen.dart';
import 'package:quber_taxi/client-app/pages/create_account/create_account.dart';
import 'package:quber_taxi/client-app/pages/home/home.dart';
import 'package:quber_taxi/client-app/pages/home/search_destination.dart';
import 'package:quber_taxi/client-app/pages/home/search_origin.dart';
import 'package:quber_taxi/client-app/pages/navigation/client_navigation.dart';
import 'package:quber_taxi/client-app/pages/navigation/quber_reviews.dart';
import 'package:quber_taxi/client-app/pages/search_driver/search_driver.dart';
import 'package:quber_taxi/client-app/pages/settings/account_setting.dart';
import 'package:quber_taxi/client-app/pages/track_driver/track_driver.dart';
import 'package:quber_taxi/common/models/app_announcement.dart';
import 'package:quber_taxi/common/models/review.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/common/pages/about_dev/about_dev.dart';
import 'package:quber_taxi/common/pages/about_us/about_us.dart';
import 'package:quber_taxi/common/pages/app_announcement/announcement.dart';
import 'package:quber_taxi/common/pages/identity_verification/confirmed_selfie.dart';
import 'package:quber_taxi/common/pages/identity_verification/face_detection.dart';
import 'package:quber_taxi/common/pages/identity_verification/identity_verification.dart';
import 'package:quber_taxi/common/pages/location_picker/location_picker.dart';
import 'package:quber_taxi/common/pages/login/login.dart';
import 'package:quber_taxi/common/pages/onboarding/onboarding.dart';
import 'package:quber_taxi/config/app_profile.dart';
import 'package:quber_taxi/config/build_config.dart';
import 'package:quber_taxi/admin-app/pages/drivers_list/driver_list_page.dart';
import 'package:quber_taxi/driver-app/pages/create_account/create_account.dart';
import 'package:quber_taxi/driver-app/pages/home/home.dart';
import 'package:quber_taxi/driver-app/pages/navigation/driver_navigation.dart';
import 'package:quber_taxi/driver-app/pages/settings/settings.dart';
import 'package:quber_taxi/navigation/routes/admin_routes.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/utils/runtime.dart' as runtime;
import 'routes/common_routes.dart';
import 'package:quber_taxi/navigation/backup_navigation_manager.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: _resolveInitialLocation(BuildConfig.appProfile),
  // Resolve any redirection needed. If any applies (return null) then use initialLocation.
  redirect: (context, state) {
    // 1) Onboarding (client only)
    if (runtime.isClientMode && !runtime.isOnboardingDone) {
      return CommonRoutes.onboarding;
    }
    // 2) Session
    if (!runtime.isSessionOk) {
      return CommonRoutes.login;
    }
    // 3) Backup restore (client only)
    if (runtime.shouldRestorePage) {
      final route = BackupNavigationManager.instance.getSavedRoute();
      if (route != null && state.matchedLocation != route) {
        return route;
      }
    }
    return null;
  },
  routes: [
    // COMMONS
    GoRoute(path: CommonRoutes.onboarding,
        builder: (context, state) => const OnboardingPage()
    ),
    GoRoute(
        path: CommonRoutes.login,
        builder: (context, state) => const LoginPage()
    ),
    GoRoute(
        path: CommonRoutes.aboutDev,
        builder: (context, state) => const AboutDevPage()
    ),
    GoRoute(
        path: CommonRoutes.aboutUs,
        builder: (context, state) => const AboutUsPage()
    ),
    GoRoute(
        path: CommonRoutes.locationPicker,
        builder: (context, state) {
          final isOrigin = state.extra as bool? ?? true;
          return LocationPicker(isOrigin: isOrigin);
        }
    ),
    GoRoute(path: CommonRoutes.requestFaceId,
        builder: (context, state) => const VerificationIdentityPage()
    ),
    GoRoute(
        path: CommonRoutes.faceIdConfirmed,
        builder: (context, state) {
          final imageBytes = state.extra as Uint8List;
          return FaceIdConfirmed(imageBytes: imageBytes);
        }
    ),
    GoRoute(path: CommonRoutes.faceDetection,
        builder: (context, state) => const FaceDetectionPage()
    ),
    // CLIENT
    GoRoute(
        path: ClientRoutes.createAccount,
        builder: (context, state) {
          final faceIdImage = state.extra as Uint8List;
          return CreateClientAccountPage(faceIdImage: faceIdImage);
        }
    ),
    GoRoute(path: ClientRoutes.settings,
        builder: (context, state) => const ClientSettingsPage()
    ),
    GoRoute(
      path: ClientRoutes.home,
      builder: (context, state) => ClientHomePage()
    ),
    GoRoute(
        path: ClientRoutes.searchOrigin,
        builder: (context, state) => const SearchOriginPage()
    ),
    GoRoute(
        path: ClientRoutes.searchDestination,
        builder: (context, state) => const SearchDestinationPage()
    ),
    GoRoute(
        path: ClientRoutes.searchDriver,
        builder: (context, state) {
          if (runtime.shouldRestorePage) {
            final travel = BackupNavigationManager.instance.getSavedTravel();
            return SearchDriverPage(travelId: travel.id, wasRestored: true, restoredTravel: travel);
          }
          return SearchDriverPage(travelId: state.extra as int);
        }
    ),
    GoRoute(
        path: ClientRoutes.trackDriver,
        builder: (context, state) {
          if (runtime.shouldRestorePage) {
            final travel = BackupNavigationManager.instance.getSavedTravel();
            return TrackDriverPage(travel: travel, wasRestored: true);
          }
          return TrackDriverPage(travel: state.extra as Travel);
        }
    ),
    GoRoute(
        path: ClientRoutes.navigation,
        builder: (context, state) {
          if (runtime.shouldRestorePage) {
            final travel = BackupNavigationManager.instance.getSavedTravel();
            return ClientNavigation(travel: travel, wasRestored: true);
          }
          return ClientNavigation(travel: state.extra as Travel);
        }
    ),
    GoRoute(
        path: ClientRoutes.quberReviews,
        builder: (context, state) {
          final reviews = state.extra as List<Review>;
          return QuberReviewsPage(reviews: reviews);
        }
    ),
    // DRIVER
    GoRoute(
        path: DriverRoutes.createAccount,
        builder: (context, state) {
          final faceIdImage = state.extra as Uint8List;
          return CreateDriverAccountPage(faceIdImage: faceIdImage);
        }
    ),
    GoRoute(
        path: DriverRoutes.settings,
        builder: (context, state) => const DriverSettingsPage()
    ),
    GoRoute(
        path: DriverRoutes.home,
        builder: (context, state) {
          if(runtime.shouldRestorePage) {
            final travel = BackupNavigationManager.instance.getSavedTravel();
            return DriverHomePage(selectedTravel: travel, wasRestored: true);
          }
          return DriverHomePage();
        }
    ),
    GoRoute(
        path: DriverRoutes.navigation,
        builder: (context, state) {
          if (runtime.shouldRestorePage) {
            final travel = BackupNavigationManager.instance.getSavedTravel();
            return DriverNavigationPage(travel: travel, wasRestored: true);
          }
          return DriverNavigationPage(travel: state.extra as Travel);
        }
    ),
    // ADMIN
    GoRoute(
        path: AdminRoutes.settings,
        builder: (context, state) => const AdminSettingsPage()
    ),
    GoRoute(path: AdminRoutes.tripsList,
        builder: (context, state) => const CompletedTripsPage()
    ),
    GoRoute(path: AdminRoutes.driversList,
        builder: (context, state) => const DriversListPage()
    ),
    GoRoute(path: AdminRoutes.requestTaxi,
        builder: (context, state) => const RequestTaxiScreenAdmin()
    ),
    GoRoute(
        path: AdminRoutes.driverInfo,
        builder: (context, state) {
          final driverId = state.extra as int;
          return DriverInfoPage(driverId: driverId);
        }
    ),
    GoRoute(
        path: CommonRoutes.announcement,
        builder: (context, state) {
          final announcement = state.extra as AppAnnouncement?;
          return AppAnnouncementPage(announcement: announcement);
        }
    )
  ]
);

String _resolveInitialLocation(AppProfile profile) {
  return switch (profile) {
    AppProfile.client => ClientRoutes.home,
    AppProfile.driver => DriverRoutes.home,
    AppProfile.admin => AdminRoutes.settings
  };
}