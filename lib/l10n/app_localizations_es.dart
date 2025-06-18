// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get unknown => 'Municipio no reconocido:';

  @override
  String get originName => 'Seleccione el lugar de origen';

  @override
  String get destinationName => 'Seleccione el municipio de destino';

  @override
  String get carPrefer => '¿Qué tipo de vehículo prefiere?';

  @override
  String get howTravels => '¿Cuántas personas viajan?';

  @override
  String get pets => '¿Lleva mascota?';

  @override
  String get minDistance => 'Distancia mínima:';

  @override
  String get maxDistance => 'Distancia máxima:';

  @override
  String get minPrice => 'Precio mínimo:';

  @override
  String get maxPrice => 'Precio máximo que puede costar:';

  @override
  String get askTaxi => 'Pedir taxi';

  @override
  String get vehicle => 'Vehículo';

  @override
  String get map => 'Mapa';

  @override
  String get quberPoints => 'Puntos Quber';

  @override
  String get ubicationFailed =>
      'Su ubicación actual está fuera de los límites de La Habana';

  @override
  String get permissionsDenied => 'Permiso de ubicación denegado';

  @override
  String get permissionDeniedPermanently =>
      'Permiso de ubicación denegado permanentemente';

  @override
  String get writeUbication => 'Escriba una ubicación...';

  @override
  String get selectUbication => 'Seleccione ubicación desde el mapa';

  @override
  String get actualUbication => 'Usar mi ubicación actual';

  @override
  String get outLimits =>
      'Su ubicación actual está fuera de los límites de La Habana';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get searchDrivers => 'Buscando conductores...';

  @override
  String get selectTravel => 'Seleccione un viaje';

  @override
  String get updateTravel => 'Actualizar viajes';

  @override
  String get noTravel => 'Sin viajes disponibles';

  @override
  String get noAssignedTrip => 'No se pudo asignar el viaje';

  @override
  String get countPeople => 'Cantidad de personas que viajan:';

  @override
  String get pet => 'Mascota:';

  @override
  String get typeVehicle => 'Tipo de vehículo:';

  @override
  String get startTrip => 'Iniciar viaje';

  @override
  String get people => 'Personas';

  @override
  String get from => 'Desde: ';

  @override
  String get until => 'Hasta: ';

  @override
  String get welcomeTitle => 'Bienvenido\na Quber';

  @override
  String get enterEmail => 'Introduzca su correo';

  @override
  String get enterPassword => 'Introduzca su contraseña';

  @override
  String get invalidEmail => 'Ingrese un correo válido';

  @override
  String get requiredField => 'Campo requerido';

  @override
  String get requiredEmail => 'Por favor ingrese su correo';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get createAccountLogin => 'Crear cuenta';

  @override
  String get recoverPassword => 'Recuperar Contraseña';

  @override
  String get recoverPasswordDescription =>
      'Por favor, introduzca su correo electrónico. Le enviaremos un enlace para restablecer su contraseña.';

  @override
  String get sendButton => 'Enviar';
}
