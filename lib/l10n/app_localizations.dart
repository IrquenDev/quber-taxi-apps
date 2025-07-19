import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @unknown.
  ///
  /// In es, this message translates to:
  /// **'Municipio no reconocido:'**
  String get unknown;

  /// No description provided for @originName.
  ///
  /// In es, this message translates to:
  /// **'Seleccione la ubicación de origen'**
  String get originName;

  /// No description provided for @destinationName.
  ///
  /// In es, this message translates to:
  /// **'Seleccione el municipio de destino'**
  String get destinationName;

  /// No description provided for @carPrefer.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tipo de vehículo prefiere?'**
  String get carPrefer;

  /// No description provided for @howTravels.
  ///
  /// In es, this message translates to:
  /// **'¿Cuántas personas viajan?'**
  String get howTravels;

  /// No description provided for @pets.
  ///
  /// In es, this message translates to:
  /// **'¿Lleva mascota?'**
  String get pets;

  /// No description provided for @minDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia mínima:'**
  String get minDistance;

  /// No description provided for @maxDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia máxima:'**
  String get maxDistance;

  /// No description provided for @minPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio mínimo:'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio máximo que puede costar:'**
  String get maxPrice;

  /// No description provided for @askTaxi.
  ///
  /// In es, this message translates to:
  /// **'Pedir taxi'**
  String get askTaxi;

  /// No description provided for @vehicle.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get vehicle;

  /// No description provided for @settingsHome.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsHome;

  /// No description provided for @map.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get map;

  /// No description provided for @quberPoints.
  ///
  /// In es, this message translates to:
  /// **'Puntos Quber'**
  String get quberPoints;

  /// No description provided for @mapBottomItem.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get mapBottomItem;

  /// No description provided for @requestTaxiBottomItem.
  ///
  /// In es, this message translates to:
  /// **'Pedir Taxi'**
  String get requestTaxiBottomItem;

  /// No description provided for @settingsBottomItem.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsBottomItem;

  /// No description provided for @quberPointsBottomItem.
  ///
  /// In es, this message translates to:
  /// **'Puntos Quber'**
  String get quberPointsBottomItem;

  /// No description provided for @ubicationFailed.
  ///
  /// In es, this message translates to:
  /// **'Su ubicación actual está fuera de los límites de La Habana'**
  String get ubicationFailed;

  /// No description provided for @permissionsDenied.
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación denegado'**
  String get permissionsDenied;

  /// No description provided for @permissionDeniedPermanently.
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación denegado permanentemente'**
  String get permissionDeniedPermanently;

  /// No description provided for @writeUbication.
  ///
  /// In es, this message translates to:
  /// **'Escriba una ubicación...'**
  String get writeUbication;

  /// No description provided for @selectUbication.
  ///
  /// In es, this message translates to:
  /// **'Seleccione ubicación desde el mapa'**
  String get selectUbication;

  /// No description provided for @actualUbication.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación actual'**
  String get actualUbication;

  /// No description provided for @outLimits.
  ///
  /// In es, this message translates to:
  /// **'Su ubicación actual está fuera de los límites de La Habana'**
  String get outLimits;

  /// No description provided for @noResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get noResults;

  /// No description provided for @searchDrivers.
  ///
  /// In es, this message translates to:
  /// **'Buscando conductores...'**
  String get searchDrivers;

  /// No description provided for @selectTravel.
  ///
  /// In es, this message translates to:
  /// **'Seleccione un viaje'**
  String get selectTravel;

  /// No description provided for @updateTravel.
  ///
  /// In es, this message translates to:
  /// **'Actualizar viajes'**
  String get updateTravel;

  /// No description provided for @noTravel.
  ///
  /// In es, this message translates to:
  /// **'Sin viajes disponibles'**
  String get noTravel;

  /// No description provided for @noAssignedTrip.
  ///
  /// In es, this message translates to:
  /// **'No se pudo asignar el viaje'**
  String get noAssignedTrip;

  /// No description provided for @countPeople.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de personas que viajan:'**
  String get countPeople;

  /// No description provided for @pet.
  ///
  /// In es, this message translates to:
  /// **'Mascota:'**
  String get pet;

  /// No description provided for @typeVehicle.
  ///
  /// In es, this message translates to:
  /// **'Tipo de vehículo:'**
  String get typeVehicle;

  /// No description provided for @startTrip.
  ///
  /// In es, this message translates to:
  /// **'Iniciar viaje'**
  String get startTrip;

  /// No description provided for @people.
  ///
  /// In es, this message translates to:
  /// **'Personas'**
  String get people;

  /// No description provided for @from.
  ///
  /// In es, this message translates to:
  /// **'Desde: '**
  String get from;

  /// No description provided for @until.
  ///
  /// In es, this message translates to:
  /// **'Hasta: '**
  String get until;

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido\na Quber'**
  String get welcomeTitle;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In es, this message translates to:
  /// **'Introduzca su número de teléfono'**
  String get enterPhoneNumber;

  /// No description provided for @enterPassword.
  ///
  /// In es, this message translates to:
  /// **'Introduzca su contraseña'**
  String get enterPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingrese un correo válido'**
  String get invalidEmail;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Campo requerido'**
  String get requiredField;

  /// No description provided for @requiredEmail.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingrese su correo'**
  String get requiredEmail;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'Olvidé mi contraseña'**
  String get forgotPassword;

  /// No description provided for @createAccountLogin.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccountLogin;

  /// No description provided for @recoverPassword.
  ///
  /// In es, this message translates to:
  /// **'Recuperar Contraseña'**
  String get recoverPassword;

  /// No description provided for @recoverPasswordDescription.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduzca su número de teléfono. Le enviaremos un código para restablecer su contraseña.'**
  String get recoverPasswordDescription;

  /// No description provided for @sendButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get sendButton;

  /// No description provided for @noReviews.
  ///
  /// In es, this message translates to:
  /// **'Aún sin reseñas del conductor'**
  String get noReviews;

  /// No description provided for @reviewSctHeader.
  ///
  /// In es, this message translates to:
  /// **'Tu opinión nos ayuda a mejorar'**
  String get reviewSctHeader;

  /// No description provided for @reviewTooltip.
  ///
  /// In es, this message translates to:
  /// **'(Califica el viaje de 1 a 5 estrellas)'**
  String get reviewTooltip;

  /// No description provided for @reviewTextHint.
  ///
  /// In es, this message translates to:
  /// **'Ayúdanos a mejorar dejando tu opinión'**
  String get reviewTextHint;

  /// No description provided for @tripCompleted.
  ///
  /// In es, this message translates to:
  /// **'Viaje Finalizado'**
  String get tripCompleted;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Restablecer Contraseña'**
  String get resetPasswordTitle;

  /// No description provided for @verificationCodeHint.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación'**
  String get verificationCodeHint;

  /// No description provided for @newPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get newPasswordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Vuelva a introducir su contraseña'**
  String get confirmPasswordHint;

  /// No description provided for @resetButton.
  ///
  /// In es, this message translates to:
  /// **'Restablecer'**
  String get resetButton;

  /// No description provided for @allFieldsRequiredMessage.
  ///
  /// In es, this message translates to:
  /// **'Complete todos los campos'**
  String get allFieldsRequiredMessage;

  /// No description provided for @passwordsDoNotMatchMessage.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatchMessage;

  /// No description provided for @resetSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'Contraseña restablecida correctamente'**
  String get resetSuccessMessage;

  /// No description provided for @invalidCodeMessage.
  ///
  /// In es, this message translates to:
  /// **'Código inválido o expirado'**
  String get invalidCodeMessage;

  /// No description provided for @unexpectedErrorMessage.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado. Intente más tarde.'**
  String get unexpectedErrorMessage;

  /// No description provided for @codeSendErrorMessage.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar el código. Intente nuevamente.'**
  String get codeSendErrorMessage;

  /// No description provided for @invalidPhoneMessage.
  ///
  /// In es, this message translates to:
  /// **'Número inválido. Debe tener 8 dígitos.'**
  String get invalidPhoneMessage;

  /// No description provided for @incorrectPasswordMessage.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es incorrecta'**
  String get incorrectPasswordMessage;

  /// No description provided for @phoneNotRegisteredMessage.
  ///
  /// In es, this message translates to:
  /// **'El número de teléfono no se encuentra registrado'**
  String get phoneNotRegisteredMessage;

  /// No description provided for @unexpectedErrorLoginMessage.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió algo mal, por favor inténtelo más tarde'**
  String get unexpectedErrorLoginMessage;

  /// No description provided for @identityVerify.
  ///
  /// In es, this message translates to:
  /// **'Verificación de identidad'**
  String get identityVerify;

  /// No description provided for @confirmIdentity.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos confirmar su identidad.'**
  String get confirmIdentity;

  /// No description provided for @noBot.
  ///
  /// In es, this message translates to:
  /// **'Por favor, toma una selfie para confirmar que no eres un bot.'**
  String get noBot;

  /// No description provided for @noUsedImage.
  ///
  /// In es, this message translates to:
  /// **'No usaremos esta imagen como foto de perfil ni se mostrará públicamente.'**
  String get noUsedImage;

  /// No description provided for @verificationUser.
  ///
  /// In es, this message translates to:
  /// **'Este paso es parte de nuestro sistema de verificación para garantizar la seguridad de todos los usuarios.'**
  String get verificationUser;

  /// No description provided for @takeSelfie.
  ///
  /// In es, this message translates to:
  /// **'Tomar Selfie'**
  String get takeSelfie;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get createAccount;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre:'**
  String get name;

  /// No description provided for @nameAndLastName.
  ///
  /// In es, this message translates to:
  /// **'Introduzca su nombre y apellidos'**
  String get nameAndLastName;

  /// No description provided for @phoneNumber.
  ///
  /// In es, this message translates to:
  /// **'Núm. teléfono:'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña:'**
  String get password;

  /// No description provided for @passwordConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña:'**
  String get passwordConfirm;

  /// No description provided for @endRegistration.
  ///
  /// In es, this message translates to:
  /// **'Finalizar Registro'**
  String get endRegistration;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Cuenta creada satisfactoriamente'**
  String get accountCreatedSuccess;

  /// No description provided for @errorCreatingAccount.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error al crear la cuenta'**
  String get errorCreatingAccount;

  /// No description provided for @checkYourInternetConnection.
  ///
  /// In es, this message translates to:
  /// **'Compruebe su conexión a Internet e intente de nuevo'**
  String get checkYourInternetConnection;

  /// No description provided for @nowCanAskForTaxi.
  ///
  /// In es, this message translates to:
  /// **'¡Ya puede ir a por su viaje!'**
  String get nowCanAskForTaxi;

  /// No description provided for @thanks.
  ///
  /// In es, this message translates to:
  /// **'Gracias por confirmar su identidad.'**
  String get thanks;

  /// No description provided for @successConfirm.
  ///
  /// In es, this message translates to:
  /// **'Hemos confirmado su identidad con éxito.'**
  String get successConfirm;

  /// No description provided for @passSecurity.
  ///
  /// In es, this message translates to:
  /// **'Este paso es parte de nuestro sistema de verificación para garantizar la seguridad de todos los usuarios.'**
  String get passSecurity;

  /// No description provided for @driverInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información del Conductor'**
  String get driverInfoTitle;

  /// No description provided for @averageRating.
  ///
  /// In es, this message translates to:
  /// **'Valoración promedio'**
  String get averageRating;

  /// No description provided for @vehiclePlate.
  ///
  /// In es, this message translates to:
  /// **'Chapa del vehículo'**
  String get vehiclePlate;

  /// No description provided for @seatNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de asientos'**
  String get seatNumber;

  /// No description provided for @vehicleType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de vehículo'**
  String get vehicleType;

  /// No description provided for @acceptButton.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get acceptButton;

  /// No description provided for @cancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;

  /// No description provided for @adminSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes del Administrador'**
  String get adminSettingsTitle;

  /// No description provided for @pricesSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Precios'**
  String get pricesSectionTitle;

  /// No description provided for @driverCreditPercentage.
  ///
  /// In es, this message translates to:
  /// **'Porciento de crédito para conductores:'**
  String get driverCreditPercentage;

  /// No description provided for @tripPricePerKm.
  ///
  /// In es, this message translates to:
  /// **'Precio de viaje por KM:'**
  String get tripPricePerKm;

  /// No description provided for @saveButtonPanel.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get saveButtonPanel;

  /// No description provided for @passwordsSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseñas'**
  String get passwordsSectionTitle;

  /// No description provided for @newPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña:'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirme contraseña:'**
  String get confirmPassword;

  /// No description provided for @otherActionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Otras acciones'**
  String get otherActionsTitle;

  /// No description provided for @viewAllTrips.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los viajes'**
  String get viewAllTrips;

  /// No description provided for @viewAllDrivers.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los conductores'**
  String get viewAllDrivers;

  /// No description provided for @nameDriver.
  ///
  /// In es, this message translates to:
  /// **'Nombre:'**
  String get nameDriver;

  /// No description provided for @carRegistration.
  ///
  /// In es, this message translates to:
  /// **'Chapa:'**
  String get carRegistration;

  /// No description provided for @phoneNumberDriver.
  ///
  /// In es, this message translates to:
  /// **'Num. teléfono:'**
  String get phoneNumberDriver;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico:'**
  String get email;

  /// No description provided for @numberOfSeats.
  ///
  /// In es, this message translates to:
  /// **'Número de asientos:'**
  String get numberOfSeats;

  /// No description provided for @saveInformation.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get saveInformation;

  /// No description provided for @myAccount.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get myAccount;

  /// No description provided for @balance.
  ///
  /// In es, this message translates to:
  /// **'Balance:'**
  String get balance;

  /// No description provided for @valuation.
  ///
  /// In es, this message translates to:
  /// **'Valoración acumulada:'**
  String get valuation;

  /// No description provided for @quberCredits.
  ///
  /// In es, this message translates to:
  /// **'Crédito de Quber acumulado:'**
  String get quberCredits;

  /// No description provided for @nextPay.
  ///
  /// In es, this message translates to:
  /// **'Próxima fecha de pago:'**
  String get nextPay;

  /// No description provided for @passwordConfirmDriver.
  ///
  /// In es, this message translates to:
  /// **'Confirme contraseña:'**
  String get passwordConfirmDriver;

  /// No description provided for @passwordDriver.
  ///
  /// In es, this message translates to:
  /// **'Contraseña:'**
  String get passwordDriver;

  /// No description provided for @goBack.
  ///
  /// In es, this message translates to:
  /// **'Regresar'**
  String get goBack;

  /// No description provided for @aboutUsDriver.
  ///
  /// In es, this message translates to:
  /// **'Sobre Nosotros'**
  String get aboutUsDriver;

  /// No description provided for @aboutDevDriver.
  ///
  /// In es, this message translates to:
  /// **'Sobre el desarrollador'**
  String get aboutDevDriver;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @requiredLabel.
  ///
  /// In es, this message translates to:
  /// **'Por favor complete todos los campos obligatorios'**
  String get requiredLabel;

  /// No description provided for @aboutUsTitle.
  ///
  /// In es, this message translates to:
  /// **'Acerca de Nosotros'**
  String get aboutUsTitle;

  /// No description provided for @companyDescription.
  ///
  /// In es, this message translates to:
  /// **'Empresa - Agencia de Taxi'**
  String get companyDescription;

  /// No description provided for @companyAdress.
  ///
  /// In es, this message translates to:
  /// **'Calle 4ta / Central y Mercado, Reparto Martín Pérez, San Miguel del Padrón'**
  String get companyAdress;

  /// No description provided for @companyAboutText.
  ///
  /// In es, this message translates to:
  /// **'Quber es una Empresa dedicada a ofrecer servicios de transporte a través de una red organizada de taxis, enfocada en brindar un servicio seguro, puntual y de calidad. La empresa se compromete con la satisfacción del cliente y el bienestar de sus conductores, promoviendo una experiencia de movilidad confiable, accesible, centrada en el respeto, la responsabilidad y la eficiencia.'**
  String get companyAboutText;

  /// No description provided for @contactAddress.
  ///
  /// In es, this message translates to:
  /// **'Calle 10 entre Línea y 23'**
  String get contactAddress;

  /// No description provided for @tripsPageTitle.
  ///
  /// In es, this message translates to:
  /// **'Viajes'**
  String get tripsPageTitle;

  /// No description provided for @tripPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio del viaje: '**
  String get tripPrice;

  /// No description provided for @tripDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración del viaje: '**
  String get tripDuration;

  /// No description provided for @clientSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Cliente:'**
  String get clientSectionTitle;

  /// No description provided for @clientName.
  ///
  /// In es, this message translates to:
  /// **'Nombre: '**
  String get clientName;

  /// No description provided for @clientPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono: '**
  String get clientPhone;

  /// No description provided for @driverSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Conductor:'**
  String get driverSectionTitle;

  /// No description provided for @driverName.
  ///
  /// In es, this message translates to:
  /// **'Nombre: '**
  String get driverName;

  /// No description provided for @driverPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono: '**
  String get driverPhone;

  /// No description provided for @driverPlate.
  ///
  /// In es, this message translates to:
  /// **'Chapa: '**
  String get driverPlate;

  /// No description provided for @aboutDeveloperTitle.
  ///
  /// In es, this message translates to:
  /// **'Acerca del Desarrollador'**
  String get aboutDeveloperTitle;

  /// No description provided for @softwareCompany.
  ///
  /// In es, this message translates to:
  /// **'Empresa de software'**
  String get softwareCompany;

  /// No description provided for @aboutText.
  ///
  /// In es, this message translates to:
  /// **'Irquen, fundada por tres estudiantes y construida como una familia de amigos, hoy es una empresa de software con bases firmes y visión de futuro. Su propósito es hacer que la digitalización sea rápida y accesible para todos. Su misión es llevar la tecnología a cada rincón, crecer, optimizar y expandirse. Su visión es superar límites, encontrar soluciones y crear lo que aún no existe.'**
  String get aboutText;

  /// No description provided for @identityVerificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Verificación de identidad'**
  String get identityVerificationTitle;

  /// No description provided for @confirmIdentityHeader.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos confirmar su identidad'**
  String get confirmIdentityHeader;

  /// No description provided for @takeSelfieInstruction.
  ///
  /// In es, this message translates to:
  /// **'Por favor, toma una selfie para confirmar que no eres un bot.'**
  String get takeSelfieInstruction;

  /// No description provided for @selfieUsageNote.
  ///
  /// In es, this message translates to:
  /// **'No usaremos esta imagen como foto de perfil ni se mostrará públicamente.'**
  String get selfieUsageNote;

  /// No description provided for @verificationPurpose.
  ///
  /// In es, this message translates to:
  /// **'Este paso es parte de nuestro proceso de verificación para garantizar la seguridad de todos los usuarios.'**
  String get verificationPurpose;

  /// No description provided for @takeSelfieButton.
  ///
  /// In es, this message translates to:
  /// **'Tomar Selfie'**
  String get takeSelfieButton;

  /// No description provided for @identityVerificationHeader.
  ///
  /// In es, this message translates to:
  /// **'Verificación de identidad'**
  String get identityVerificationHeader;

  /// No description provided for @thankYouForVerification.
  ///
  /// In es, this message translates to:
  /// **'Gracias por confirmar su identidad'**
  String get thankYouForVerification;

  /// No description provided for @identityConfirmedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Hemos confirmado su identidad con éxito.'**
  String get identityConfirmedSuccessfully;

  /// No description provided for @verificationBenefits.
  ///
  /// In es, this message translates to:
  /// **'Este proceso nos ayuda a proteger su cuenta y a mantener nuestra comunidad segura para todos los usuarios.'**
  String get verificationBenefits;

  /// No description provided for @createAccountButton.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get createAccountButton;

  /// No description provided for @createAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get createAccountTitle;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre:'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In es, this message translates to:
  /// **'Introduzca su nombre y apellidos'**
  String get nameHint;

  /// No description provided for @plateLabel.
  ///
  /// In es, this message translates to:
  /// **'Chapa:'**
  String get plateLabel;

  /// No description provided for @plateHint.
  ///
  /// In es, this message translates to:
  /// **'Escriba la chapa de su vehículo'**
  String get plateHint;

  /// No description provided for @phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Núm. de teléfono:'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 5566XXXX'**
  String get phoneHint;

  /// No description provided for @seatsLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de asientos:'**
  String get seatsLabel;

  /// No description provided for @seatsHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 4'**
  String get seatsHint;

  /// No description provided for @licenseLabel.
  ///
  /// In es, this message translates to:
  /// **'Licencia de conducción'**
  String get licenseLabel;

  /// No description provided for @attachButton.
  ///
  /// In es, this message translates to:
  /// **'Adjuntar'**
  String get attachButton;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Seleccione su tipo de vehículo:'**
  String get vehicleTypeLabel;

  /// No description provided for @standardVehicle.
  ///
  /// In es, this message translates to:
  /// **'Estándar'**
  String get standardVehicle;

  /// No description provided for @standardDescription.
  ///
  /// In es, this message translates to:
  /// **'La opción más común para viajes diarios. Para 3 o 4 pasajeros, con confort aceptable, buen rendimiento y tarifas accesibles.'**
  String get standardDescription;

  /// No description provided for @familyVehicle.
  ///
  /// In es, this message translates to:
  /// **'Familiar'**
  String get familyVehicle;

  /// No description provided for @familyDescription.
  ///
  /// In es, this message translates to:
  /// **'Espacioso y cómodo, ideal para grupos de 6 o más personas o para viajes con equipaje adicional. Perfecto para traslados en grupo o viajes largos.'**
  String get familyDescription;

  /// No description provided for @comfortVehicle.
  ///
  /// In es, this message translates to:
  /// **'Confort'**
  String get comfortVehicle;

  /// No description provided for @comfortDescription.
  ///
  /// In es, this message translates to:
  /// **'Una experiencia superior en comodidad. Asientos más amplios, suspensión suave, aire acondicionado y mayor atención al detalle. Ideal para quienes buscan un viaje más relajado y placentero.'**
  String get comfortDescription;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña:'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'Introduzca la contraseña deseada'**
  String get passwordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirme contraseña:'**
  String get confirmPasswordLabel;

  /// No description provided for @finishButton.
  ///
  /// In es, this message translates to:
  /// **'Finalizar registro'**
  String get finishButton;

  /// No description provided for @motoTaxiVehicle.
  ///
  /// In es, this message translates to:
  /// **'Mototaxi'**
  String get motoTaxiVehicle;

  /// No description provided for @motoTaxiDescription.
  ///
  /// In es, this message translates to:
  /// **'Vehículo de dos o tres ruedas, ideal para trayectos cortos en zonas con tráfico intenso. Económico, ágil y perfecto para movilizarse rápidamente por calles estrechas.'**
  String get motoTaxiDescription;

  /// No description provided for @updatePasswordSuccess.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get updatePasswordSuccess;

  /// No description provided for @somethingWentWrong.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal, por favor inténtelo más tarde'**
  String get somethingWentWrong;

  /// No description provided for @checkConnection.
  ///
  /// In es, this message translates to:
  /// **'Revise su conexión a internet'**
  String get checkConnection;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @aboutUs.
  ///
  /// In es, this message translates to:
  /// **'Sobre Nosotros'**
  String get aboutUs;

  /// No description provided for @aboutDeveloper.
  ///
  /// In es, this message translates to:
  /// **'Sobre el desarrollador'**
  String get aboutDeveloper;

  /// No description provided for @hintPassword.
  ///
  /// In es, this message translates to:
  /// **'Introduzca la contraseña deseada'**
  String get hintPassword;

  /// No description provided for @labelNameDriver.
  ///
  /// In es, this message translates to:
  /// **'Nombre:'**
  String get labelNameDriver;

  /// No description provided for @labelCarRegistration.
  ///
  /// In es, this message translates to:
  /// **'Chapa:'**
  String get labelCarRegistration;

  /// No description provided for @labelPhoneNumberDriver.
  ///
  /// In es, this message translates to:
  /// **'Num. teléfono:'**
  String get labelPhoneNumberDriver;

  /// No description provided for @labelNumberOfSeats.
  ///
  /// In es, this message translates to:
  /// **'Número de asientos:'**
  String get labelNumberOfSeats;

  /// No description provided for @balanceLabel.
  ///
  /// In es, this message translates to:
  /// **'Balance:'**
  String get balanceLabel;

  /// No description provided for @quberCreditsLabel.
  ///
  /// In es, this message translates to:
  /// **'Crédito de Quber acumulado:'**
  String get quberCreditsLabel;

  /// No description provided for @nextPayLabel.
  ///
  /// In es, this message translates to:
  /// **'Próxima fecha de pago:'**
  String get nextPayLabel;

  /// No description provided for @valuationLabel.
  ///
  /// In es, this message translates to:
  /// **'Valoración acumulada:'**
  String get valuationLabel;

  /// No description provided for @androidOnlyText.
  ///
  /// In es, this message translates to:
  /// **'-'**
  String get androidOnlyText;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Permiso de cámara denegado.'**
  String get cameraPermissionDenied;

  /// No description provided for @goBackButton.
  ///
  /// In es, this message translates to:
  /// **'Regresar'**
  String get goBackButton;

  /// No description provided for @faceDetectionStep.
  ///
  /// In es, this message translates to:
  /// **'1. Detección de rostro'**
  String get faceDetectionStep;

  /// No description provided for @livenessDetectionStep.
  ///
  /// In es, this message translates to:
  /// **'2. Detección de vida'**
  String get livenessDetectionStep;

  /// No description provided for @selfieCapturingStep.
  ///
  /// In es, this message translates to:
  /// **'3. Captura de selfie'**
  String get selfieCapturingStep;

  /// No description provided for @compatibilityErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error de compatibilidad'**
  String get compatibilityErrorTitle;

  /// No description provided for @faceDetectionInstruction.
  ///
  /// In es, this message translates to:
  /// **'Le aconsejamos que coloque su rostro en la zona indicada.'**
  String get faceDetectionInstruction;

  /// No description provided for @livenessDetectionInstruction.
  ///
  /// In es, this message translates to:
  /// **'Le aconsejamos que no actúe de forma rígida, sin pestañear o respirar de manera natural, para asegurar una detección precisa del rostro.'**
  String get livenessDetectionInstruction;

  /// No description provided for @selfieProcessingInstruction.
  ///
  /// In es, this message translates to:
  /// **'Nuestra inteligencia artificial está procesando la selfie. Por favor, manténgase conectado a internet y evite cerrar la aplicación.'**
  String get selfieProcessingInstruction;

  /// No description provided for @deviceNotCompatibleMessage.
  ///
  /// In es, this message translates to:
  /// **'Su dispositivo no es compatible con la verificación facial. Por favor, contacte con soporte técnico o intente con otro dispositivo.'**
  String get deviceNotCompatibleMessage;

  /// No description provided for @imageProcessingErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error de Procesamiento de Imagen'**
  String get imageProcessingErrorTitle;

  /// No description provided for @imageProcessingErrorMessage.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error al procesar su imagen. Por favor, inténtelo de nuevo más tarde.'**
  String get imageProcessingErrorMessage;

  /// No description provided for @cameraPermissionPermanentlyDeniedTitle.
  ///
  /// In es, this message translates to:
  /// **'Permiso de Cámara Requerido'**
  String get cameraPermissionPermanentlyDeniedTitle;

  /// No description provided for @cameraPermissionPermanentlyDeniedMessage.
  ///
  /// In es, this message translates to:
  /// **'El acceso a la cámara ha sido denegado permanentemente. Para usar la verificación de identidad, por favor habilite el permiso de cámara en la configuración de su dispositivo.'**
  String get cameraPermissionPermanentlyDeniedMessage;

  /// No description provided for @goToSettingsButton.
  ///
  /// In es, this message translates to:
  /// **'Ir a Configuración'**
  String get goToSettingsButton;

  /// No description provided for @confirmExitTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar salida'**
  String get confirmExitTitle;

  /// No description provided for @confirmExitMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Está seguro que desea salir? Perderá todo el progreso realizado hasta ahora.'**
  String get confirmExitMessage;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get passwordMinLengthError;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// No description provided for @phoneAlreadyRegistered.
  ///
  /// In es, this message translates to:
  /// **'El número de teléfono ya se encuentra registrado'**
  String get phoneAlreadyRegistered;

  /// No description provided for @registrationError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar su registro. Por favor inténtelo más tarde'**
  String get registrationError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
