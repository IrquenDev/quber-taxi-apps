enum TaxiType {

  mdpiStandard("Estándar", "assets/images/vehicles/mdpi/standard.png", "STANDARD"),
  hdpiStandard("Estándar", "assets/images/vehicles/hdpi/standard.png", "STANDARD"),
  xhdpiStandard("Estándar", "assets/images/vehicles/xhdpi/standard.png", "STANDARD"),

  mdpiFamiliar("Familiar", "assets/images/vehicles/mdpi/familiar.png", "FAMILIAR"),
  hdpiFamiliar("Familiar", "assets/images/vehicles/hdpi/familiar.png", "FAMILIAR"),
  xhdpiFamiliar("Familiar", "assets/images/vehicles/xhdpi/familiar.png", "FAMILIAR"),

  mdpiComfort("Confort", "assets/images/vehicles/mdpi/comfort.png", "COMFORT"),
  hdpiComfort("Confort", "assets/images/vehicles/hdpi/comfort.png", "COMFORT"),
  xhdpiComfort("Confort", "assets/images/vehicles/xhdpi/comfort.png", "COMFORT");

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