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
  /// **'Seleccione el lugar de origen'**
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

  /// No description provided for @familyVehicle.
  ///
  /// In es, this message translates to:
  /// **'Familiar'**
  String get familyVehicle;
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
