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
  /// **'Seleccione la ubicación de destino'**
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

  /// No description provided for @distance.
  ///
  /// In es, this message translates to:
  /// **'Distancia:'**
  String get distance;

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

  /// No description provided for @price.
  ///
  /// In es, this message translates to:
  /// **'Precio:'**
  String get price;

  /// No description provided for @minPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio mínimo:'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio máximo:'**
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

  /// No description provided for @tooltipAboutEstimations.
  ///
  /// In es, this message translates to:
  /// **'Las estimaciones que se presentan a continuación, a pesar de ser muy prescisas, siguen siendo valores aproximados. Refiérase a ellas como una guía. La distancia y precio reales se calcularán durante la travesía.'**
  String get tooltipAboutEstimations;

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

  /// No description provided for @select.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar'**
  String get select;

  /// No description provided for @origin.
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get origin;

  /// No description provided for @destination.
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get destination;

  /// No description provided for @marker.
  ///
  /// In es, this message translates to:
  /// **'Marcador'**
  String get marker;

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
  /// **'P. Quber'**
  String get quberPointsBottomItem;

  /// No description provided for @quberPoints.
  ///
  /// In es, this message translates to:
  /// **'Puntos Quber'**
  String get quberPoints;

  /// No description provided for @accumulatedPoints.
  ///
  /// In es, this message translates to:
  /// **'Puntos acumulados'**
  String get accumulatedPoints;

  /// No description provided for @quberPointsEarned.
  ///
  /// In es, this message translates to:
  /// **'Puntos Quber Ganados'**
  String get quberPointsEarned;

  /// No description provided for @inviteFriendsDescription.
  ///
  /// In es, this message translates to:
  /// **'Invita amigos con tu código de referido para ganar más puntos. Úsalos para comprar descuentos en tus viajes.'**
  String get inviteFriendsDescription;

  /// No description provided for @driverCredit.
  ///
  /// In es, this message translates to:
  /// **'Crédito del Conductor'**
  String get driverCredit;

  /// No description provided for @driverCreditDescription.
  ///
  /// In es, this message translates to:
  /// **'Saldo disponible en tu cuenta. Este crédito se actualiza después de cada viaje completado.'**
  String get driverCreditDescription;

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

  /// No description provided for @locationError.
  ///
  /// In es, this message translates to:
  /// **'Error al obtener la ubicación'**
  String get locationError;

  /// No description provided for @destinationsLimitedToHavana.
  ///
  /// In es, this message translates to:
  /// **'Los destinos están limitados a La Habana'**
  String get destinationsLimitedToHavana;

  /// No description provided for @selectLocation.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar ubicación'**
  String get selectLocation;

  /// No description provided for @tapMapToSelectLocation.
  ///
  /// In es, this message translates to:
  /// **'Toque el mapa para seleccionar una ubicación'**
  String get tapMapToSelectLocation;

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

  /// No description provided for @noResultsTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Upps!'**
  String get noResultsTitle;

  /// No description provided for @noResultsMessage.
  ///
  /// In es, this message translates to:
  /// **'Nuestro proveedor no fue capaz de encontrar resultados similares.'**
  String get noResultsMessage;

  /// No description provided for @noResultsHint.
  ///
  /// In es, this message translates to:
  /// **'Intenta con una búsqueda más genérica y luego afínala desde el mapa.'**
  String get noResultsHint;

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
  /// **'Iniciar Viaje (Cliente Recogido)'**
  String get startTrip;

  /// No description provided for @people.
  ///
  /// In es, this message translates to:
  /// **'Personas'**
  String get people;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado exitosamente'**
  String get profileUpdatedSuccessfully;

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

  /// No description provided for @locationNotFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación no encontrada'**
  String get locationNotFoundTitle;

  /// No description provided for @locationNotFoundMessage.
  ///
  /// In es, this message translates to:
  /// **'Aún no hemos encontrado su ubicación.'**
  String get locationNotFoundMessage;

  /// No description provided for @locationNotFoundHint.
  ///
  /// In es, this message translates to:
  /// **'Seleccione este botón para intentar de nuevo.'**
  String get locationNotFoundHint;

  /// No description provided for @locationNotFoundButton.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get locationNotFoundButton;

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
  /// **'Porciento de crédito para Quber:'**
  String get driverCreditPercentage;

  /// No description provided for @tripPricePerKm.
  ///
  /// In es, this message translates to:
  /// **'Precio de viaje por KM y vehículo:'**
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

  /// No description provided for @tripPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio del Viaje'**
  String get tripPriceLabel;

  /// No description provided for @tripDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Tiempo Transcurrido'**
  String get tripDurationLabel;

  /// No description provided for @tripDistanceLabel.
  ///
  /// In es, this message translates to:
  /// **'Distancia Recorrida'**
  String get tripDistanceLabel;

  /// No description provided for @originLabel.
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get originLabel;

  /// No description provided for @destinationLabel.
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get destinationLabel;

  /// No description provided for @dateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get dateLabel;

  /// No description provided for @quberCreditLabel.
  ///
  /// In es, this message translates to:
  /// **'Crédito para Quber'**
  String get quberCreditLabel;

  /// No description provided for @commentsLabel.
  ///
  /// In es, this message translates to:
  /// **'comentarios'**
  String get commentsLabel;

  /// No description provided for @minutesLabel.
  ///
  /// In es, this message translates to:
  /// **'minutos'**
  String get minutesLabel;

  /// No description provided for @kilometersLabel.
  ///
  /// In es, this message translates to:
  /// **'Km'**
  String get kilometersLabel;

  /// No description provided for @currencyLabel.
  ///
  /// In es, this message translates to:
  /// **'CUP'**
  String get currencyLabel;

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

  /// No description provided for @titlePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Aquí debería aparecer un texto, pero parece que no se ha cargado.'**
  String get titlePlaceholder;

  /// No description provided for @descriptionPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Aquí debería aparecer una descripción, pero parece que no se ha cargado. Por favor, espere un momento. Si el problema persiste, cierre la aplicación y vuelva a abrirla.'**
  String get descriptionPlaceholder;

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

  /// No description provided for @creatingAccount.
  ///
  /// In es, this message translates to:
  /// **'Creando cuenta...'**
  String get creatingAccount;

  /// No description provided for @newTrip.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Viaje'**
  String get newTrip;

  /// No description provided for @noConnection.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get noConnection;

  /// No description provided for @noConnectionMessage.
  ///
  /// In es, this message translates to:
  /// **'La app no podrá continuar sin conexión a internet'**
  String get noConnectionMessage;

  /// No description provided for @needsApproval.
  ///
  /// In es, this message translates to:
  /// **'Necesita Aprobación'**
  String get needsApproval;

  /// No description provided for @needsApprovalMessage.
  ///
  /// In es, this message translates to:
  /// **'Su cuenta está en proceso de activación. Para continuar, por favor preséntese en nuestras oficinas para la revisión técnica de su vehículo y la firma del contrato. Nos encontramos en Calle 4ta / Central y mercado, reparto Martín Pérez, San Miguel del Padrón. Una vez complete este paso, podrá comenzar a usar la app normalmente y se mostrarán las peticiones de viaje disponibles.'**
  String get needsApprovalMessage;

  /// No description provided for @weWaitForYou.
  ///
  /// In es, this message translates to:
  /// **'¡Le esperamos!'**
  String get weWaitForYou;

  /// No description provided for @paymentSoon.
  ///
  /// In es, this message translates to:
  /// **'Pago próximo'**
  String get paymentSoon;

  /// No description provided for @paymentPending.
  ///
  /// In es, this message translates to:
  /// **'Pago pendiente'**
  String get paymentPending;

  /// No description provided for @inThreeDays.
  ///
  /// In es, this message translates to:
  /// **'en 3 días'**
  String get inThreeDays;

  /// No description provided for @dayAfterTomorrow.
  ///
  /// In es, this message translates to:
  /// **'pasado mañana'**
  String get dayAfterTomorrow;

  /// No description provided for @tomorrow.
  ///
  /// In es, this message translates to:
  /// **'mañana'**
  String get tomorrow;

  /// No description provided for @paymentReminderSoon.
  ///
  /// In es, this message translates to:
  /// **'Le recordamos que su próxima fecha de pago es {timeText}.'**
  String paymentReminderSoon(Object timeText);

  /// No description provided for @paymentReminderToday.
  ///
  /// In es, this message translates to:
  /// **'La fecha de pago programada para hoy ha llegado. Tiene hasta 4 días para realizar el pago.'**
  String get paymentReminderToday;

  /// No description provided for @paymentExpired.
  ///
  /// In es, this message translates to:
  /// **'La fecha límite para el pago previamente fijado para el día {date} ha expirado.'**
  String paymentExpired(Object date);

  /// No description provided for @paymentOverdue.
  ///
  /// In es, this message translates to:
  /// **'La fecha de pago programada fue el {date}. Tiene {days} {daysText} para realizar el pago.'**
  String paymentOverdue(Object date, Object days, Object daysText);

  /// No description provided for @paymentLastDay.
  ///
  /// In es, this message translates to:
  /// **'La fecha de pago programada fue el {date}. Hoy es su último día para realizar el pago.'**
  String paymentLastDay(Object date);

  /// No description provided for @day.
  ///
  /// In es, this message translates to:
  /// **'día'**
  String get day;

  /// No description provided for @days.
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get days;

  /// No description provided for @paymentOfficeInfo.
  ///
  /// In es, this message translates to:
  /// **' Por favor, diríjase a nuestra oficina en Calle 4ta / Central y mercado, reparto Martín Pérez, San Miguel del Padrón para realizarlo. Puede consultar el monto accediendo a su perfil en la app.'**
  String get paymentOfficeInfo;

  /// No description provided for @thanksForAttention.
  ///
  /// In es, this message translates to:
  /// **'Gracias por su atención.'**
  String get thanksForAttention;

  /// No description provided for @distanceFixed.
  ///
  /// In es, this message translates to:
  /// **'Distancia: {distance}km'**
  String distanceFixed(Object distance);

  /// No description provided for @distanceMinimum.
  ///
  /// In es, this message translates to:
  /// **'Distancia Mínima: {distance}km'**
  String distanceMinimum(Object distance);

  /// No description provided for @distanceMaximum.
  ///
  /// In es, this message translates to:
  /// **'Distancia Máxima: {distance}km'**
  String distanceMaximum(Object distance);

  /// No description provided for @priceFixedCost.
  ///
  /// In es, this message translates to:
  /// **'Precio: {price} CUP'**
  String priceFixedCost(Object price);

  /// No description provided for @priceMinimumCost.
  ///
  /// In es, this message translates to:
  /// **'Precio mínimo que puede costar: {price} CUP'**
  String priceMinimumCost(Object price);

  /// No description provided for @priceMaximumCost.
  ///
  /// In es, this message translates to:
  /// **'Precio máximo que puede costar: {price} CUP'**
  String priceMaximumCost(Object price);

  /// No description provided for @driverStateNotConfirmed.
  ///
  /// In es, this message translates to:
  /// **'No confirmado'**
  String get driverStateNotConfirmed;

  /// No description provided for @driverStateCanPay.
  ///
  /// In es, this message translates to:
  /// **'Puede pagar'**
  String get driverStateCanPay;

  /// No description provided for @driverStatePaymentRequired.
  ///
  /// In es, this message translates to:
  /// **'Pago requerido'**
  String get driverStatePaymentRequired;

  /// No description provided for @driverStateEnabled.
  ///
  /// In es, this message translates to:
  /// **'Habilitado'**
  String get driverStateEnabled;

  /// No description provided for @driverStateDisabled.
  ///
  /// In es, this message translates to:
  /// **'Deshabilitado'**
  String get driverStateDisabled;

  /// No description provided for @filterByName.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por nombre'**
  String get filterByName;

  /// No description provided for @filterByPhone.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por teléfono'**
  String get filterByPhone;

  /// No description provided for @filterByState.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por estado'**
  String get filterByState;

  /// No description provided for @allStates.
  ///
  /// In es, this message translates to:
  /// **'Todos los estados'**
  String get allStates;

  /// No description provided for @clearFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get clearFilters;

  /// No description provided for @drivers.
  ///
  /// In es, this message translates to:
  /// **'Conductores'**
  String get drivers;

  /// No description provided for @noDriversYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay conductores'**
  String get noDriversYet;

  /// No description provided for @noDriversFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron conductores con los filtros aplicados'**
  String get noDriversFound;

  /// No description provided for @confirmAccount.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Cuenta'**
  String get confirmAccount;

  /// No description provided for @confirmPayment.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Pago'**
  String get confirmPayment;

  /// No description provided for @actions.
  ///
  /// In es, this message translates to:
  /// **'Acciones'**
  String get actions;

  /// No description provided for @recharge.
  ///
  /// In es, this message translates to:
  /// **'Recargar'**
  String get recharge;

  /// No description provided for @rechargeAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto a recargar'**
  String get rechargeAmount;

  /// No description provided for @credit.
  ///
  /// In es, this message translates to:
  /// **'Crédito'**
  String get credit;

  /// No description provided for @creditAmount.
  ///
  /// In es, this message translates to:
  /// **'Crédito: {amount} CUP'**
  String creditAmount(Object amount);

  /// No description provided for @rechargeSuccess.
  ///
  /// In es, this message translates to:
  /// **'Crédito recargado exitosamente'**
  String get rechargeSuccess;

  /// No description provided for @rechargeError.
  ///
  /// In es, this message translates to:
  /// **'Error al recargar el crédito'**
  String get rechargeError;

  /// No description provided for @invalidAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto inválido'**
  String get invalidAmount;

  /// No description provided for @blockAccount.
  ///
  /// In es, this message translates to:
  /// **'Bloquear cuenta'**
  String get blockAccount;

  /// No description provided for @enableAccount.
  ///
  /// In es, this message translates to:
  /// **'Habilitar cuenta'**
  String get enableAccount;

  /// No description provided for @errorTryLater.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal, por favor inténtelo más tarde'**
  String get errorTryLater;

  /// No description provided for @peopleCount.
  ///
  /// In es, this message translates to:
  /// **'{count} personas'**
  String peopleCount(Object count);

  /// No description provided for @withPet.
  ///
  /// In es, this message translates to:
  /// **'Con mascota'**
  String get withPet;

  /// No description provided for @withoutPet.
  ///
  /// In es, this message translates to:
  /// **'Sin mascota'**
  String get withoutPet;

  /// No description provided for @fromLocation.
  ///
  /// In es, this message translates to:
  /// **'Desde: {location}'**
  String fromLocation(Object location);

  /// No description provided for @toLocation.
  ///
  /// In es, this message translates to:
  /// **'Hasta: {location}'**
  String toLocation(Object location);

  /// No description provided for @acceptTrip.
  ///
  /// In es, this message translates to:
  /// **'Aceptar Viaje'**
  String get acceptTrip;

  /// No description provided for @acceptTripConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Se le notificará al cliente que se ha aceptado su solicitud de viaje. Su ubicación se comenzará a compartir solo con él.'**
  String get acceptTripConfirmMessage;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In es, this message translates to:
  /// **'Para comenzar a compartir su ubicación con el cliente se necesita su acceso explícito'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionBlocked.
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación bloqueado. Habilitar nuevamente en ajustes'**
  String get locationPermissionBlocked;

  /// No description provided for @invalidCreditPercentage.
  ///
  /// In es, this message translates to:
  /// **'El porcentaje debe estar entre 0 y 100'**
  String get invalidCreditPercentage;

  /// No description provided for @invalidPrice.
  ///
  /// In es, this message translates to:
  /// **'El precio debe ser mayor a 0'**
  String get invalidPrice;

  /// No description provided for @passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get passwordMinLength;

  /// No description provided for @tripDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción del viaje'**
  String get tripDescription;

  /// No description provided for @myDiscountCode.
  ///
  /// In es, this message translates to:
  /// **'Mi código de descuento:'**
  String get myDiscountCode;

  /// No description provided for @inviteFriendDiscount.
  ///
  /// In es, this message translates to:
  /// **'Invita a un amigo a usar la app y pídele que ingrese tu código al registrarse o desde Ajustes. Así recibirá un 10% de descuento en su próximo viaje.'**
  String get inviteFriendDiscount;

  /// No description provided for @copied.
  ///
  /// In es, this message translates to:
  /// **'Copiado'**
  String get copied;

  /// No description provided for @accountVerification.
  ///
  /// In es, this message translates to:
  /// **'Verificación de cuenta'**
  String get accountVerification;

  /// No description provided for @verificationCodeMessage.
  ///
  /// In es, this message translates to:
  /// **'Le hemos enviado un código de verificación a su número de teléfono por WhatsApp, por favor coloque el código a continuación.'**
  String get verificationCodeMessage;

  /// No description provided for @verificationCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación'**
  String get verificationCodeLabel;

  /// No description provided for @verificationCodeHint.
  ///
  /// In es, this message translates to:
  /// **'Ingrese el código'**
  String get verificationCodeHint;

  /// No description provided for @sendCode.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get sendCode;

  /// No description provided for @resendCode.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get resendCode;

  /// No description provided for @sendingCode.
  ///
  /// In es, this message translates to:
  /// **'Enviando código...'**
  String get sendingCode;

  /// No description provided for @verifying.
  ///
  /// In es, this message translates to:
  /// **'Verificando...'**
  String get verifying;

  /// No description provided for @sendCodeError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar el código. Intente nuevamente.'**
  String get sendCodeError;

  /// No description provided for @verifyCodeError.
  ///
  /// In es, this message translates to:
  /// **'Error al verificar el código. Intente nuevamente.'**
  String get verifyCodeError;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación inválido'**
  String get invalidVerificationCode;

  /// No description provided for @verificationCodeExpired.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación expirado'**
  String get verificationCodeExpired;

  /// No description provided for @tripRequestCancelled.
  ///
  /// In es, this message translates to:
  /// **'Se ha cancelado la solicitud de este viaje'**
  String get tripRequestCancelled;

  /// No description provided for @operationSuccessful.
  ///
  /// In es, this message translates to:
  /// **'Operación realizada con éxito'**
  String get operationSuccessful;

  /// No description provided for @errorChangingConfiguration.
  ///
  /// In es, this message translates to:
  /// **'Error. No se pudo cambiar la configuración'**
  String get errorChangingConfiguration;

  /// No description provided for @errorChangingPassword.
  ///
  /// In es, this message translates to:
  /// **'Error. No se pudo cambiar la contraseña'**
  String get errorChangingPassword;

  /// No description provided for @couldNotOpenPhoneDialer.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el marcador de teléfono'**
  String get couldNotOpenPhoneDialer;

  /// No description provided for @favoritesBottomItem.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favoritesBottomItem;

  /// No description provided for @myMarkers.
  ///
  /// In es, this message translates to:
  /// **'Mis marcadores'**
  String get myMarkers;

  /// No description provided for @notAvailable.
  ///
  /// In es, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @currency.
  ///
  /// In es, this message translates to:
  /// **'CUP'**
  String get currency;

  /// No description provided for @kilometers.
  ///
  /// In es, this message translates to:
  /// **'km'**
  String get kilometers;

  /// No description provided for @minutes.
  ///
  /// In es, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In es, this message translates to:
  /// **'¿Listo para Viajar?'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Con solo seleccionar el municipio de destino'**
  String get onboardingPage1Subtitle;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In es, this message translates to:
  /// **'podrá viajar de forma rápida y segura'**
  String get onboardingPage1Description;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In es, this message translates to:
  /// **'Pero primero'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Subtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo supo de nosotros?'**
  String get onboardingPage2Subtitle;

  /// No description provided for @referralSourceFriend.
  ///
  /// In es, this message translates to:
  /// **'Por un amigo'**
  String get referralSourceFriend;

  /// No description provided for @referralSourcePoster.
  ///
  /// In es, this message translates to:
  /// **'Por un cartel'**
  String get referralSourcePoster;

  /// No description provided for @referralSourcePlayStore.
  ///
  /// In es, this message translates to:
  /// **'Por PlayStore'**
  String get referralSourcePlayStore;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In es, this message translates to:
  /// **'¿Tienes un código de referido?'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Ayuda a tu amigo y gana beneficios'**
  String get onboardingPage3Subtitle;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In es, this message translates to:
  /// **'Introduce un código de referido para que tu amigo obtenga un descuento en su próximo viaje. Si no dispones de uno, puedes continuar.'**
  String get onboardingPage3Description;

  /// No description provided for @onboardingPage3InputHint.
  ///
  /// In es, this message translates to:
  /// **'Introduzca su Código de referido'**
  String get onboardingPage3InputHint;

  /// No description provided for @onboardingPage4Title.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo se calcula el precio del viaje?'**
  String get onboardingPage4Title;

  /// No description provided for @onboardingPage4Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Basado en la distancia y el destino'**
  String get onboardingPage4Subtitle;

  /// No description provided for @onboardingPage4Description.
  ///
  /// In es, this message translates to:
  /// **'La aplicación irá calculando y mostrando el precio en tiempo real según la distancia que se va recorriendo. Así dependiendo del municipio al que te dirijas, se te mostrará al inicio un rango estimado de precio. Esto te permite hacer paradas y visitar múltiples destinos con mayor libertad.'**
  String get onboardingPage4Description;

  /// No description provided for @onboardingPage5Title.
  ///
  /// In es, this message translates to:
  /// **'Puntos Quber'**
  String get onboardingPage5Title;

  /// No description provided for @onboardingPage5Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Viaja y gana descuentos'**
  String get onboardingPage5Subtitle;

  /// No description provided for @onboardingPage5Description.
  ///
  /// In es, this message translates to:
  /// **'Cada vez que realizas un viaje o alguien introduce tu código de referido, acumulas Puntos Quber. Estos puntos te permiten obtener descuentos en futuros viajes. ¡Viaja más y ahorra más!'**
  String get onboardingPage5Description;

  /// No description provided for @tripAccepted.
  ///
  /// In es, this message translates to:
  /// **'Viaje Aceptado'**
  String get tripAccepted;

  /// No description provided for @tripAcceptedDescription.
  ///
  /// In es, this message translates to:
  /// **'Un conductor ha aceptado su solicitud. Ahora está en espera de su llegada. Podrá ver su ubicación en tiempo real en el mapa. Le pediremos confirmación cuando esté listo para recogerle.'**
  String get tripAcceptedDescription;

  /// No description provided for @seeDriverLocation.
  ///
  /// In es, this message translates to:
  /// **'Ver ubicación del conductor'**
  String get seeDriverLocation;

  /// No description provided for @noDriverLocation.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay ubicación del conductor'**
  String get noDriverLocation;

  /// No description provided for @pickupConfirmationInfo.
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado una notificación al cliente. Una vez la acepte, comenzará el viaje.'**
  String get pickupConfirmationInfo;

  /// No description provided for @pickupConfirmationTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmación de recogida'**
  String get pickupConfirmationTitle;

  /// No description provided for @pickupConfirmationMessage.
  ///
  /// In es, this message translates to:
  /// **'El conductor ha indicado que su recogida se ha realizado. Confirme únicamente si ya se encuentra con el conductor; una vez confirmada, dará inicio el viaje.'**
  String get pickupConfirmationMessage;

  /// No description provided for @pickupConfirmationSentTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmación enviada'**
  String get pickupConfirmationSentTitle;

  /// No description provided for @nameAboutDev.
  ///
  /// In es, this message translates to:
  /// **'Irquen'**
  String get nameAboutDev;

  /// No description provided for @emailAboutDev.
  ///
  /// In es, this message translates to:
  /// **'qnecesitas.desarrollo@gmail.com'**
  String get emailAboutDev;

  /// No description provided for @phoneAboutDev.
  ///
  /// In es, this message translates to:
  /// **'+5355759386'**
  String get phoneAboutDev;

  /// No description provided for @websiteAboutDev.
  ///
  /// In es, this message translates to:
  /// **'https://qnecesitas.nat.cu'**
  String get websiteAboutDev;

  /// No description provided for @nameAboutUs.
  ///
  /// In es, this message translates to:
  /// **'Quber'**
  String get nameAboutUs;

  /// No description provided for @phoneAboutUs.
  ///
  /// In es, this message translates to:
  /// **'+53 52417814'**
  String get phoneAboutUs;

  /// No description provided for @copiedToClipboard.
  ///
  /// In es, this message translates to:
  /// **'Copiado al portapapeles'**
  String get copiedToClipboard;

  /// No description provided for @reviewSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar tu valoración'**
  String get reviewSaveError;

  /// No description provided for @reviewThankYou.
  ///
  /// In es, this message translates to:
  /// **'Gracias por tu tiempo'**
  String get reviewThankYou;

  /// No description provided for @reviewsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las reseñas'**
  String get reviewsLoadError;

  /// No description provided for @dateFormat.
  ///
  /// In es, this message translates to:
  /// **'d \'de\' MMMM \'de\' y'**
  String get dateFormat;
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
