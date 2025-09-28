import 'package:flutter/material.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/config/app_profile.dart';
import 'package:quber_taxi/config/build_config.dart';
import 'package:quber_taxi/navigation/backup_navigation_manager.dart';
import 'package:quber_taxi/storage/onboarding_prefs_manager.dart';
import 'package:quber_taxi/storage/session_prefs_manger.dart';

/// Check if the app is running as client profile.
bool get isClientMode => BuildConfig.appProfile == AppProfile.client;

/// Check if the app is running as driver profile.
bool get isDriverMode => BuildConfig.appProfile == AppProfile.driver;

/// Check if the app is running as driver profile.
bool get isAdminMode => BuildConfig.appProfile == AppProfile.admin;

/// Indicates whether there is an active session. If `false`, the user should be automatically redirected to login.
bool get isSessionOk => SessionPrefsManager.instance.isSessionOk();

/// Represents the logged-in user in a json row type. Consider the following example to work with the exact type:
/// ```dart
/// final client = Client.fromJson(loggedInUser);
/// ```
dynamic get loggedInUser => SessionPrefsManager.instance.getLoggedInUserAsRawType();

bool hasConnection(BuildContext context) {
  final status = NetworkScope.statusOf(context);
  return status == ConnectionStatus.online;
}

bool get isOnboardingDone => OnboardingPrefsManager.instance.isOnboardingDone();

bool get shouldRestorePage => BackupNavigationManager.instance.shouldRestorePage();

String? get savedRoute => BackupNavigationManager.instance.getSavedRoute();