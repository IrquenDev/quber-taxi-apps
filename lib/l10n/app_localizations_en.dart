import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get unknown => 'Unrecognized municipality:';

  @override
  String get originName => 'Select the origin location';

  @override
  String get destinationName => 'Select the destination municipality';

  @override
  String get carPrefer => 'What type of vehicle do you prefer?';

  @override
  String get howTravels => 'How many people are traveling?';

  @override
  String get pets => 'Are you bringing a pet?';

  @override
  String get minDistance => 'Minimum distance:';

  @override
  String get maxDistance => 'Maximum distance:';

  @override
  String get minPrice => 'Minimum price:';

  @override
  String get maxPrice => 'Maximum price you can pay:';

  @override
  String get askTaxi => 'Request a taxi';

  @override
  String get vehicle => 'vehicle';

  @override
  String get map => 'Map';

  @override
  String get quberPoints => 'Quber Points';

  @override
  String get ubicationFailed => 'Your current location is outside the limits of Havana';

  @override
  String get permissionsDenied => 'Location permission denied';

  @override
  String get permissionDeniedPermanently => 'Location permission permanently denied';

  @override
  String get writeUbication => 'Enter a location...';

  @override
  String get selectUbication => 'Select location from map';

  @override
  String get actualUbication => 'Use my current location';

  @override
  String get outLimits => 'Your current location is outside the limits of Havana';

  @override
  String get noResults => 'No results found';

  @override
  String get searchDrivers => 'Searching for Drivers...';

  @override
  String get selectTravel => 'Select a trip';

  @override
  String get updateTravel => 'Update trips';

  @override
  String get noTravel => 'No trips available';

  @override
  String get noAssignedTrip => 'The trip could not be assigned';

  @override
  String get countPeople => 'Number of people traveling:';

  @override
  String get pet => 'Pet:';

  @override
  String get typeVehicle => 'Type of vehicle:';

  @override
  String get startTrip => 'Start Trip';

  @override
  String get people => 'people';

  @override
  String get from => 'From: ';

  @override
  String get until => 'To: ';
}
