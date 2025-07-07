import 'package:quber_taxi/enums/asset_dpi.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

enum TaxiType {

  standard,
  familiar,
  comfort;

  static String nameOf(TaxiType type, AppLocalizations localizations) {
    return switch(type) {
      TaxiType.standard => localizations.standardVehicle,
      TaxiType.familiar => localizations.familyVehicle,
      TaxiType.comfort => localizations.comfortVehicle
    };
  }

  static String descriptionOf(TaxiType type, AppLocalizations localizations) {
    return switch(type) {
      TaxiType.standard => localizations.standardDescription,
      TaxiType.familiar => localizations.familyDescription,
      TaxiType.comfort => localizations.comfortDescription
    };
  }

  String assetRef(AssetDpi dpi) => 'assets/images/vehicles/${dpi.name}/$name.png';

  String get apiValue => name.toUpperCase();

  /// Resolves a [TaxiType] from a given string value.
  static TaxiType resolve(String value) {
    return TaxiType.values.firstWhere((e) => e.apiValue.toLowerCase() == value.toLowerCase());
  }
}