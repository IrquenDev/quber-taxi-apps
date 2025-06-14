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
  String get vehicle => 'vehículo';

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
  String get writeUbication => 'Escribe una ubicación...';

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
  String get searchDrivers => 'Buscando Conductores...';

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
  String get startTrip => 'Iniciar Viaje';

  @override
  String get people => 'personas';

  @override
  String get from => 'Desde: ';

  @override
  String get until => 'Hasta: ';
}
