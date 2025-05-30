enum TaxiType {

  standard("Estándar", "assets/images/vehicles/v1/standard.png", "STANDARD"),
  familiar("Familiar", "assets/images/vehicles/v1/familiar.png", "FAMILIAR"),
  comfort("Confort", "assets/images/vehicles/v1/comfort.png", "COMFORT");

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