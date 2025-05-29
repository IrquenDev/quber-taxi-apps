enum TaxiType {

  standard("Estándar", "assets/images/v1/estandar_car.png", "STANDARD"),
  familiar("Familiar", "assets/images/v1/family_car.png", "FAMILIAR"),
  comfort("Confort", "assets/images/v1/confort_car.png", "COMFORT");

  final String displayText;
  final String assetRef;
  final String apiValue;
  const TaxiType(this.displayText, this.assetRef, this.apiValue);

  /// Resolves a [TaxiType] from a given string value.
  static TaxiType resolve(String value) {
    return TaxiType.values.firstWhere(
            (e) => e.apiValue == value,
        orElse: () => throw Exception()
    );
  }
}