enum TravelState {

  canceled("Cancelado", "CANCELED"),
  waiting("En espera", "WAITING"),
  accepted("Aceptado", "ACCEPTED"),
  inProgress("En progreso", "IN_PROGRESS"),
  completed("Completado", "COMPLETED");

  final String displayText;
  final String apiValue;
  const TravelState(this.displayText, this.apiValue);

  /// Resolves a [TravelState] from a given string value.
  static TravelState resolve(String value) {
    return TravelState.values.firstWhere(
            (e) => e.apiValue == value,
        orElse: () => throw Exception()
    );
  }
}