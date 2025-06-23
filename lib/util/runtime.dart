import 'package:quber_taxi/config/app_profile.dart';
import 'package:quber_taxi/config/build_config.dart';

/// Check if the app is running as client profile.
final bool isClientMode = BuildConfig.appProfile == AppProfile.client;

/// Check if the app is running as driver profile.
final bool isDriverMode = BuildConfig.appProfile == AppProfile.driver;

/// Indicates whether there is an active session. If `false`, the user will be automatically redirected to login.
bool? isSessionOk;

/// Represents the logged-in user. Client/Driver or soon Admin.
dynamic userInLogged;