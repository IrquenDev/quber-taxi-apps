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

  @override
  String get welcomeTitle => 'Welcome\nto Quber';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get requiredField => 'Required field';

  @override
  String get requiredEmail => 'Please enter your email';

  @override
  String get loginButton => 'Log in';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get createAccountLogin => 'Create account';

  @override
  String get recoverPassword => 'Recover Password';

  @override
  String get recoverPasswordDescription => 'Please enter your email address. We’ll send you a link to reset your password.';

  @override
  String get sendButton => 'Send';

  @override
  String get noReviews => 'No driver reviews yet';

  @override
  String get reviewSctHeader => 'Your opinion helps us improve';

  @override
  String get reviewTooltip => '(Rate the trip from 1 to 5 stars)';

  @override
  String get reviewTextHint => 'Help us improve by leaving your opinion';

  @override
  String get tripCompleted => 'Trip completed';

  @override
  String get identityVerify => 'Identity Verification';

  @override
  String get confirmIdentity => 'We need to confirm your identity.';

  @override
  String get noBot => 'Please take a selfie to confirm you are not a bot.';

  @override
  String get noUsedImage => 'We will not use this image as a profile picture nor will it be displayed publicly.';

  @override
  String get verificationUser => 'This step is part of our verification system to ensure the safety of all users.';

  @override
  String get takeSelfie => 'Take Selfie';

  @override
  String get createAccount => 'Create Account';

  @override
  String get name => 'Name:';

  @override
  String get nameAndLastName => 'Enter your first and last name';

  @override
  String get phoneNumber => 'Phone Number:';

  @override
  String get password => 'Password:';

  @override
  String get passwordConfirm => 'Confirm Password:';

  @override
  String get endRegistration => 'Complete Registration';

  @override
  String get thanks => 'Thank you for confirming your identity.';

  @override
  String get successConfirm => 'We have successfully confirmed your identity.';

  @override
  String get passSecurity => 'This step is part of our verification system to ensure the safety of all users.';

  @override
  String get driverInfoTitle => 'Driver Information';

  @override
  String get averageRating => 'Average Rating';

  @override
  String get vehiclePlate => 'Vehicle Plate';

  @override
  String get seatNumber => 'Number of Seats';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get acceptButton => 'Accept';

  @override
  String get familyVehicle => 'Family';
}
