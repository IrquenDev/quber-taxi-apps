// ignore: unused_import
import 'package:intl/intl.dart' as intl;
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
  String get destinationName => 'Select the destination location';

  @override
  String get carPrefer => 'What type of vehicle do you prefer?';

  @override
  String get howTravels => 'How many people are traveling?';

  @override
  String get pets => 'Are you bringing a pet?';

  @override
  String get distance => 'Distance:';

  @override
  String get minDistance => 'Minimum distance:';

  @override
  String get maxDistance => 'Maximum distance:';

  @override
  String get price => 'Price:';

  @override
  String get minPrice => 'Minimum price:';

  @override
  String get maxPrice => 'Maximum price you can pay:';

  @override
  String get askTaxi => 'Request a taxi';

  @override
  String get vehicle => 'vehicle';

  @override
  String get tooltipAboutEstimations =>
      'The estimates below, while very precise, are still approximate. Please refer to them as a guide. Actual distance and price will be calculated during the voyage.';

  @override
  String get settingsHome => 'Settings';

  @override
  String get map => 'Map';

  @override
  String get select => 'Select';

  @override
  String get origin => 'Origin';

  @override
  String get destination => 'Destination';

  @override
  String get marker => 'Marker';

  @override
  String get mapBottomItem => 'Map';

  @override
  String get requestTaxiBottomItem => 'Order Taxi';

  @override
  String get settingsBottomItem => 'Settings';

  @override
  String get quberPointsBottomItem => 'Quber Points';

  @override
  String get quberPoints => 'Quber Points';

  @override
  String get accumulatedPoints => 'Accumulated points';

  @override
  String get quberPointsEarned => 'Quber Points Earned';

  @override
  String get inviteFriendsDescription =>
      'Invite friends with your referral code to earn more points. Use them to buy discounts on your trips.';

  @override
  String get driverCredit => 'Driver Credit';

  @override
  String get driverCreditDescription =>
      'Available balance in your account. This credit is updated after each completed trip.';

  @override
  String get ubicationFailed =>
      'Your current location is outside the limits of Havana';

  @override
  String get permissionsDenied => 'Location permission denied';

  @override
  String get permissionDeniedPermanently =>
      'Location permission permanently denied';

  @override
  String get locationError => 'Error getting location';

  @override
  String get destinationsLimitedToHavana =>
      'Destinations are limited to Havana';

  @override
  String get selectLocation => 'Select location';

  @override
  String get tapMapToSelectLocation => 'Tap the map to select a location';

  @override
  String get writeUbication => 'Enter a location...';

  @override
  String get selectUbication => 'Select location from map';

  @override
  String get actualUbication => 'Use my current location';

  @override
  String get outLimits =>
      'Your current location is outside the limits of Havana';

  @override
  String get noResultsTitle => 'Oops!';

  @override
  String get noResultsMessage =>
      'Our provider wasn\'t able to find similar results.';

  @override
  String get noResultsHint =>
      'Try a more generic search, then refine it using the map.';

  @override
  String get searchDrivers => 'Searching for Drivers...';

  @override
  String get selectTravel => 'Select a trip';

  @override
  String get updateTravel => 'Update trips';

  @override
  String get noTravel => 'No trips available';

  @override
  String get noAssignedTrip =>
      'We\'re experiencing server issues. Please try again later.';

  @override
  String get countPeople => 'Number of people traveling:';

  @override
  String get pet => 'Pet:';

  @override
  String get typeVehicle => 'Type of vehicle:';

  @override
  String get startTrip => 'Start Trip (Client Picked Up)';

  @override
  String get people => 'people';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get from => 'From: ';

  @override
  String get until => 'To: ';

  @override
  String get welcomeTitle => 'Welcome\nto Quber';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

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
  String get recoverPasswordDescription =>
      'Please enter your phone number. We will send you a code to reset your password.';

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
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get newPasswordHint => 'New Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get resetButton => 'Reset';

  @override
  String get allFieldsRequiredMessage => 'Please fill out all fields';

  @override
  String get passwordsDoNotMatchMessage => 'Passwords do not match';

  @override
  String get resetSuccessMessage => 'Password reset successfully';

  @override
  String get invalidCodeMessage => 'Invalid or expired code';

  @override
  String get unexpectedErrorMessage =>
      'Unexpected error. Please try again later.';

  @override
  String get codeSendErrorMessage => 'Failed to send code. Please try again.';

  @override
  String get invalidPhoneMessage => 'Invalid phone number. Must be 8 digits.';

  @override
  String get incorrectPasswordMessage => 'The password is incorrect';

  @override
  String get phoneNotRegisteredMessage => 'The phone number is not registered';

  @override
  String get unexpectedErrorLoginMessage =>
      'Something went wrong, please try again later';

  @override
  String get locationNotFoundTitle => 'Location not found';

  @override
  String get locationNotFoundMessage => 'We haven\'t found your location yet.';

  @override
  String get locationNotFoundHint => 'Select this button to try again.';

  @override
  String get locationNotFoundButton => 'Got it';

  @override
  String get identityVerify => 'Identity Verification';

  @override
  String get confirmIdentity => 'We need to confirm your identity.';

  @override
  String get noBot => 'Please take a selfie to confirm you are not a bot.';

  @override
  String get noUsedImage =>
      'We will not use this image as a profile picture nor will it be displayed publicly.';

  @override
  String get verificationUser =>
      'This step is part of our verification system to ensure the safety of all users.';

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
  String get accountCreatedSuccess => 'Account successfully created';

  @override
  String get errorCreatingAccount =>
      'An error occurred while creating the account';

  @override
  String get checkYourInternetConnection =>
      'Check your Internet connection and try again';

  @override
  String get nowCanAskForTaxi => 'You can now go get your trip';

  @override
  String get thanks => 'Thank you for confirming your identity.';

  @override
  String get successConfirm => 'We have successfully confirmed your identity.';

  @override
  String get passSecurity =>
      'This step is part of our verification system to ensure the safety of all users.';

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
  String get cancelButton => 'Cancel';

  @override
  String get adminSettingsTitle => 'Admin Settings';

  @override
  String get pricesSectionTitle => 'Prices';

  @override
  String get driverCreditPercentage => 'Quber credit percentage:';

  @override
  String get tripPricePerKm => 'Trip price per KM and vehicle:';

  @override
  String get saveButtonPanel => 'Save';

  @override
  String get passwordsSectionTitle => 'Password';

  @override
  String get newPassword => 'New password:';

  @override
  String get confirmPassword => 'Confirm password:';

  @override
  String get otherActionsTitle => 'Other Actions';

  @override
  String get viewAllTrips => 'View all trips';

  @override
  String get viewAllDrivers => 'View all drivers';

  @override
  String get viewAllClients => 'View all clients';

  @override
  String get nameDriver => 'Name:';

  @override
  String get carRegistration => 'License Plate:';

  @override
  String get phoneNumberDriver => 'Phone Number:';

  @override
  String get email => 'irquensucursal1@gmail.com';

  @override
  String get numberOfSeats => 'Number of Seats:';

  @override
  String get saveInformation => 'Save';

  @override
  String get myAccount => 'Settings';

  @override
  String get balance => 'Balance:';

  @override
  String get valuation => 'Accumulated Rating:';

  @override
  String get quberCredits => 'Accumulated Quber Credits:';

  @override
  String get nextPay => 'Next Payment Date:';

  @override
  String get passwordConfirmDriver => 'Confirm Password:';

  @override
  String get passwordDriver => 'Password:';

  @override
  String get goBack => 'Go Back';

  @override
  String get aboutUsDriver => 'About Us';

  @override
  String get aboutDevDriver => 'About the developer';

  @override
  String get logout => 'Log out';

  @override
  String get requiredLabel => 'Please complete all required fields';

  @override
  String get aboutUsTitle => 'About Us';

  @override
  String get companyDescription => 'Microenterprise - Taxi Agency';

  @override
  String get companyAdress =>
      '4th Street / Central and Market, Martín Pérez Neighborhood, San Miguel del Padrón';

  @override
  String get companyAboutText =>
      'Quber is a microenterprise dedicated to providing transportation services through an organized taxi network, focused on offering safe, punctual and quality service. The company is committed to customer satisfaction and the well-being of its drivers, promoting a reliable, accessible mobility experience centered on respect, responsibility and efficiency.';

  @override
  String get contactAddress => '10th Street between Linea and 23rd';

  @override
  String get tripsPageTitle => 'Trips';

  @override
  String get tripPrice => 'Trip price: ';

  @override
  String get tripDuration => 'Trip duration: ';

  @override
  String get clientSectionTitle => 'Client:';

  @override
  String get clientName => 'Name: ';

  @override
  String get clientPhone => 'Phone: ';

  @override
  String get driverSectionTitle => 'Driver:';

  @override
  String get driverName => 'Name: ';

  @override
  String get driverPhone => 'Phone: ';

  @override
  String get driverPlate => 'License plate:';

  @override
  String get tripPriceLabel => 'Trip Price';

  @override
  String get tripDurationLabel => 'Time Elapsed';

  @override
  String get tripDistanceLabel => 'Distance Traveled';

  @override
  String get originLabel => 'Origin';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get dateLabel => 'Date';

  @override
  String get quberCreditLabel => 'Credit for Quber';

  @override
  String get commentsLabel => 'comments';

  @override
  String get minutesLabel => 'minutes';

  @override
  String get kilometersLabel => 'km';

  @override
  String get currencyLabel => 'CUP';

  @override
  String get aboutDeveloperTitle => 'About Developer';

  @override
  String get softwareCompany => 'Software company';

  @override
  String get aboutText =>
      'Irquen, founded by three students and built as a family of friends, is now a software company with strong foundations and future vision. Our purpose is to make digitalization fast and accessible for everyone. Our mission is to bring technology to every corner, grow, optimize and expand. Our vision is to push boundaries, find solutions and create what doesn\'t exist yet.';

  @override
  String get identityVerificationTitle => 'Identity Verification';

  @override
  String get confirmIdentityHeader => 'We need to confirm your identity';

  @override
  String get takeSelfieInstruction =>
      'Please take a selfie to confirm you\'re not a bot.';

  @override
  String get selfieUsageNote =>
      'We won\'t use this image as a profile picture or display it publicly.';

  @override
  String get verificationPurpose =>
      'This step is part of our verification process to ensure the safety of all users.';

  @override
  String get takeSelfieButton => 'Take Selfie';

  @override
  String get identityVerificationHeader => 'Identity Verification';

  @override
  String get thankYouForVerification =>
      'Thank you for confirming your identity';

  @override
  String get identityConfirmedSuccessfully =>
      'We have successfully confirmed your identity.';

  @override
  String get verificationBenefits =>
      'This process helps us protect your account and maintain a safe community for all users.';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get titlePlaceholder =>
      'A text should appear here, but it doesn\'t seem to have loaded.';

  @override
  String get descriptionPlaceholder =>
      'A description should appear here, but it doesn\'t seem to have loaded. Please wait a moment. If the issue persists, close the app and reopen it.';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get nameLabel => 'Name:';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get plateLabel => 'License Plate:';

  @override
  String get plateHint => 'Enter your vehicle license plate number';

  @override
  String get phoneLabel => 'Phone Number:';

  @override
  String get phoneHint => 'Example: 5566XXXX';

  @override
  String get seatsLabel => 'Number of Seats:';

  @override
  String get seatsHint => 'Example: 4';

  @override
  String get licenseLabel => 'Driver\'s License';

  @override
  String get attachButton => 'Attach';

  @override
  String get vehicleTypeLabel => 'Select your vehicle type:';

  @override
  String get standardVehicle => 'Standard';

  @override
  String get standardDescription =>
      'The most common choice for daily trips. Suitable for 3 or 4 passengers, offering acceptable comfort, good performance, and affordable rates.';

  @override
  String get familyVehicle => 'Family';

  @override
  String get familyDescription =>
      'Spacious and comfortable, ideal for groups of 6 or more people or trips with extra luggage. Perfect for group transfers or long journeys.';

  @override
  String get comfortVehicle => 'Comfort';

  @override
  String get comfortDescription =>
      'A superior comfort experience. Wider seats, smooth suspension, air conditioning, and greater attention to detail. Ideal for those seeking a more relaxed and pleasant ride.';

  @override
  String get passwordLabel => 'Password:';

  @override
  String get passwordHint => 'Enter your desired password';

  @override
  String get confirmPasswordLabel => 'Confirm password:';

  @override
  String get finishButton => 'Complete Registration';

  @override
  String get motoTaxiVehicle => 'Mototaxi';

  @override
  String get motoTaxiDescription =>
      'Two- or three-wheeled vehicle, ideal for short trips in heavy traffic areas. Economical, agile, and perfect for quick navigation through narrow streets.';

  @override
  String get updatePasswordSuccess => 'Password updated';

  @override
  String get somethingWentWrong =>
      'Something went wrong, please try again later';

  @override
  String get checkConnection => 'Please check your internet connection';

  @override
  String get save => 'Save';

  @override
  String get aboutUs => 'About Us';

  @override
  String get aboutDeveloper => 'About the Developer';

  @override
  String get hintPassword => 'Enter your desired password';

  @override
  String get labelNameDriver => 'Name:';

  @override
  String get labelCarRegistration => 'Plate:';

  @override
  String get labelPhoneNumberDriver => 'Phone number:';

  @override
  String get labelNumberOfSeats => 'Number of seats:';

  @override
  String get balanceLabel => 'Balance:';

  @override
  String get quberCreditsLabel => 'Accumulated Quber credits:';

  @override
  String get nextPayLabel => 'Next pay date:';

  @override
  String get valuationLabel => 'Accumulated rating:';

  @override
  String get androidOnlyText => '-';

  @override
  String get cameraPermissionDenied => 'Camera permission denied.';

  @override
  String get goBackButton => 'Go Back';

  @override
  String get faceDetectionStep => '1. Face detection';

  @override
  String get livenessDetectionStep => '2. Liveness detection';

  @override
  String get selfieCapturingStep => '3. Selfie capture';

  @override
  String get compatibilityErrorTitle => 'Compatibility error';

  @override
  String get faceDetectionInstruction =>
      'We recommend placing your face in the indicated area.';

  @override
  String get livenessDetectionInstruction =>
      'We recommend that you do not act rigidly, without blinking or breathing naturally, to ensure accurate face detection.';

  @override
  String get selfieProcessingInstruction =>
      'Our artificial intelligence is processing the selfie. Please stay connected to the internet and avoid closing the application.';

  @override
  String get deviceNotCompatibleMessage =>
      'Your device is not compatible with facial verification. Please contact technical support or try with another device.';

  @override
  String get imageProcessingErrorTitle => 'Image Processing Error';

  @override
  String get imageProcessingErrorMessage =>
      'An error occurred while processing your image. Please try again later.';

  @override
  String get cameraPermissionPermanentlyDeniedTitle =>
      'Camera Permission Required';

  @override
  String get cameraPermissionPermanentlyDeniedMessage =>
      'Camera access is permanently denied. To use identity verification, please enable camera permission in your device settings.';

  @override
  String get goToSettingsButton => 'Go to Settings';

  @override
  String get confirmExitTitle => 'Confirm Exit';

  @override
  String get confirmExitMessage =>
      'Are you sure you want to exit? You will lose all progress made so far.';

  @override
  String get passwordMinLengthError => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get phoneAlreadyRegistered => 'Phone number is already registered';

  @override
  String get registrationError =>
      'We could not complete your registration. Please try again later';

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get newTrip => 'New Trip';

  @override
  String get noConnection => 'No Connection';

  @override
  String get noConnectionMessage =>
      'The app cannot continue without internet connection';

  @override
  String get needsApproval => 'Needs Approval';

  @override
  String get needsApprovalMessage =>
      'Your account is in the process of activation. To continue, please visit our offices for the technical review of your vehicle and contract signing. We are located at 4th Street / Central and Market, Martín Pérez neighborhood, San Miguel del Padrón. Once you complete this step, you will be able to use the app normally and available trip requests will be displayed.';

  @override
  String get weWaitForYou => 'We are waiting for you!';

  @override
  String get paymentSoon => 'Payment Soon';

  @override
  String get paymentPending => 'Payment Pending';

  @override
  String get inThreeDays => 'in 3 days';

  @override
  String get dayAfterTomorrow => 'day after tomorrow';

  @override
  String get tomorrow => 'tomorrow';

  @override
  String paymentReminderSoon(Object timeText) {
    return 'We remind you that your next payment date is $timeText.';
  }

  @override
  String get paymentReminderToday =>
      'Today\'s scheduled payment date has arrived. You have up to 4 days to make the payment.';

  @override
  String paymentExpired(Object date) {
    return 'The deadline for the payment previously set for $date has expired.';
  }

  @override
  String paymentOverdue(Object date, Object days, Object daysText) {
    return 'The scheduled payment date was $date. You have $days $daysText to make the payment.';
  }

  @override
  String paymentLastDay(Object date) {
    return 'The scheduled payment date was $date. Today is your last day to make the payment.';
  }

  @override
  String get day => 'day';

  @override
  String get days => 'days';

  @override
  String get paymentOfficeInfo =>
      ' Please go to our office at 4th Street / Central and Market, Martín Pérez neighborhood, San Miguel del Padrón to make it. You can check the amount by accessing your profile in the app.';

  @override
  String get thanksForAttention => 'Thank you for your attention.';

  @override
  String distanceFixed(Object distance) {
    return 'Distance: ${distance}km';
  }

  @override
  String distanceMinimum(Object distance) {
    return 'Minimum Distance: ${distance}km';
  }

  @override
  String distanceMaximum(Object distance) {
    return 'Maximum Distance: ${distance}km';
  }

  @override
  String priceFixedCost(Object price) {
    return 'Price: $price CUP';
  }

  @override
  String priceMinimumCost(Object price) {
    return 'Minimum price: $price CUP';
  }

  @override
  String priceMaximumCost(Object price) {
    return 'Maximum price: $price CUP';
  }

  @override
  String get driverStateNotConfirmed => 'Not confirmed';

  @override
  String get driverStateCanPay => 'Can pay';

  @override
  String get driverStatePaymentRequired => 'Payment required';

  @override
  String get driverStateEnabled => 'Enabled';

  @override
  String get driverStateDisabled => 'Disabled';

  @override
  String get driverStateSuspended => 'Suspended';

  @override
  String get clientStateBlocked => 'Blocked';

  @override
  String get clientStateActive => 'Active';

  @override
  String get driverBlocked => 'Account Blocked';

  @override
  String get driverBlockedMessage =>
      'Your driver account has been blocked. Please visit our office at Calle 4ta / Central y mercado, reparto Martín Pérez, San Miguel del Padrón';

  @override
  String get filterByName => 'Filter by name';

  @override
  String get filterByPhone => 'Filter by phone';

  @override
  String get filterByState => 'Filter by state';

  @override
  String get allStates => 'All states';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get drivers => 'Drivers';

  @override
  String get noDriversYet => 'No drivers yet';

  @override
  String get noDriversFound => 'No drivers found with the applied filters';

  @override
  String get clients => 'Clients';

  @override
  String get noClientsYet => 'No clients yet';

  @override
  String get noClientsFound => 'No clients found with the applied filters';

  @override
  String get confirmAccount => 'Confirm Account';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get actions => 'Actions';

  @override
  String get recharge => 'Recharge';

  @override
  String get rechargeAmount => 'Amount to recharge';

  @override
  String get credit => 'Credit';

  @override
  String creditAmount(Object amount) {
    return 'Credit: $amount CUP';
  }

  @override
  String get rechargeSuccess => 'Credit recharged successfully';

  @override
  String get rechargeError => 'Error recharging credit';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get blockAccount => 'Block account';

  @override
  String get enableAccount => 'Enable account';

  @override
  String get errorTryLater => 'Something went wrong, please try again later';

  @override
  String peopleCount(Object count) {
    return '$count people';
  }

  @override
  String get withPet => 'With pet';

  @override
  String get withoutPet => 'Without pet';

  @override
  String fromLocation(Object location) {
    return 'From: $location';
  }

  @override
  String toLocation(Object location) {
    return 'To: $location';
  }

  @override
  String get acceptTrip => 'Accept Trip';

  @override
  String get acceptTripConfirmMessage =>
      'The client will be notified that their trip request has been accepted. Your location will start being shared only with them.';

  @override
  String get accept => 'Accept';

  @override
  String get locationPermissionRequired =>
      'Location permission is required to start sharing your location with the client';

  @override
  String get locationPermissionBlocked =>
      'Location permission blocked. Please enable again in settings';

  @override
  String get invalidCreditPercentage => 'Percentage must be between 0 and 100';

  @override
  String get invalidPrice => 'Price must be greater than 0';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get tripDescription => 'Trip Description';

  @override
  String get myDiscountCode => 'My discount code:';

  @override
  String get inviteFriendDiscount =>
      'Invite a friend to use the app and ask them to enter your code when registering or from Settings. They will receive a 10% discount on their next trip.';

  @override
  String get copied => 'Copied';

  @override
  String get accountVerification => 'Account Verification';

  @override
  String get verificationCodeMessage =>
      'We have sent a verification code to your phone number via WhatsApp, please enter the code below.';

  @override
  String get verificationCodeLabel => 'Verification code';

  @override
  String get verificationCodeHint => 'Enter the code';

  @override
  String get sendCode => 'Send';

  @override
  String get resendCode => 'Resend code';

  @override
  String get sendingCode => 'Sending code...';

  @override
  String get verifying => 'Verifying...';

  @override
  String get sendCodeError => 'Error sending code. Please try again.';

  @override
  String get verifyCodeError => 'Error verifying code. Please try again.';

  @override
  String get invalidVerificationCode => 'Invalid verification code';

  @override
  String get verificationCodeExpired => 'Verification code expired';

  @override
  String get tripRequestCancelled =>
      'The request for this trip has been cancelled';

  @override
  String get operationSuccessful => 'Operation completed successfully';

  @override
  String get errorChangingConfiguration =>
      'Error. Could not change the configuration';

  @override
  String get errorChangingPassword => 'Error. Could not change the password';

  @override
  String get couldNotOpenPhoneDialer => 'Could not open phone dialer';

  @override
  String get favoritesBottomItem => 'Favorites';

  @override
  String get myMarkers => 'My Markers';

  @override
  String get notAvailable => 'N/A';

  @override
  String get currency => 'CUP';

  @override
  String get kilometers => 'km';

  @override
  String get minutes => 'min';

  @override
  String get onboardingPage1Title => 'Ready to Travel?';

  @override
  String get onboardingPage1Subtitle =>
      'Just by selecting the destination municipality';

  @override
  String get onboardingPage1Description =>
      'you will be able to travel quickly and safely';

  @override
  String get onboardingPage2Title => 'But first';

  @override
  String get onboardingPage2Subtitle => 'How did you hear about us?';

  @override
  String get referralSourceFriend => 'From a friend';

  @override
  String get referralSourcePoster => 'From a poster';

  @override
  String get referralSourcePlayStore => 'From PlayStore';

  @override
  String get onboardingPage3Title => 'Do you have a referral code?';

  @override
  String get onboardingPage3Subtitle => 'Help your friend and earn benefits';

  @override
  String get onboardingPage3Description =>
      'Enter a referral code so your friend gets a discount on their next trip. If you don\'t have one, you can continue.';

  @override
  String get onboardingPage3InputHint => 'Enter your referral code';

  @override
  String get onboardingPage4Title => 'How is the trip price calculated?';

  @override
  String get onboardingPage4Subtitle => 'Based on distance and destination';

  @override
  String get onboardingPage4Description =>
      'The app will calculate and show the price in real time according to the distance traveled. So depending on the municipality you\'re going to, you\'ll be shown an estimated price range at the beginning. This allows you to make stops and visit multiple destinations with greater freedom.';

  @override
  String get onboardingPage5Title => 'Quber Points';

  @override
  String get onboardingPage5Subtitle => 'Travel and earn discounts';

  @override
  String get onboardingPage5Description =>
      'Every time you take a trip or someone enters your referral code, you accumulate Quber Points. These points allow you to get discounts on future trips. Travel more and save more!';

  @override
  String get tripAccepted => 'Trip Accepted';

  @override
  String get tripAcceptedDescription =>
      'A driver has accepted your request. You are now waiting for their arrival. You will be able to see their location in real time on the map. We will ask for your confirmation when they are ready to pick you up.';

  @override
  String get seeDriverLocation => 'See driver\'s location';

  @override
  String get noDriverLocation => 'Driver location not available yet';

  @override
  String get pickupConfirmationInfo =>
      'We\' ll send a notification to the client. Once they accept, the trip will begin.';

  @override
  String get pickupConfirmationTitle => 'Pickup confirmation';

  @override
  String get pickupConfirmationMessage =>
      'The driver has indicated that your pickup has been completed. Please confirm only if you are already with the driver; once confirmed, the trip will begin.';

  @override
  String get pickupConfirmationSentTitle => 'Confirmation sent';

  @override
  String get nameAboutDev => 'Irquen';

  @override
  String get emailAboutDev => 'qnecesitas.desarrollo@gmail.com';

  @override
  String get phoneAboutDev => '+5355759386';

  @override
  String get websiteAboutDev => 'https://qnecesitas.nat.cu';

  @override
  String get nameAboutUs => 'Quber';

  @override
  String get phoneAboutUs => '+53 52417814';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get reviewSaveError => 'Could not save your review';

  @override
  String get reviewThankYou => 'Thank you for your time';

  @override
  String get reviewsLoadError => 'Could not load reviews';

  @override
  String get dateFormat => 'd \'of\' MMMM \'of\' y';

  @override
  String get finalizarViaje => 'Finish Trip';

  @override
  String get verMiUbicacion => 'See My Location';

  @override
  String get confirmacionFinalizacion => 'Finish Confirmation';

  @override
  String get confirmacionFinalizacionMensaje =>
      'The driver will be notified immediately that you want to end the trip. Please accept only if this is correct.';

  @override
  String destinationsLimited(Object destinationName) {
    return 'Destinations are limited to $destinationName';
  }

  @override
  String get placeNotFound => 'Place not found';

  @override
  String get showMyLocation => 'Show My Location';

  @override
  String get finishTrip => 'Finish Trip';

  @override
  String get confirmacionLlegadaDestino => 'Destination Arrival Confirmation';

  @override
  String get confirmacionLlegadaDestinoMensaje =>
      'The driver has notified that the destination has been reached. Please accept only if this is correct.';

  @override
  String get guidedRoute => 'Guided route';

  @override
  String get exactRoute => 'Exact route';

  @override
  String get emergencySOS => 'Emergency (SOS)';

  @override
  String get fixedDestinationTrip => 'This trip has a fixed destination';

  @override
  String get defaultName => 'Unnamed location';

  @override
  String get saveFavoritesTitle => 'Save to favorites';

  @override
  String get markerNameHint => 'Marker name';

  @override
  String get cancel => 'Cancel';

  @override
  String get addedToFavorites => 'Added to Favorites';

  @override
  String get originSelected => 'Origin selected successfully';

  @override
  String get destinationSelected => 'Destination selected successfully';

  @override
  String get noFavorites => 'No favorites saved';
}
