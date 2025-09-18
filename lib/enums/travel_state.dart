enum TravelState {

  canceled("CANCELED"),
  waiting("WAITING"),
  accepted("ACCEPTED"),
  inProgress("IN_PROGRESS"),
  completed("COMPLETED");

  const TravelState(this.apiValue);

  final String apiValue;

  /// Resolves a [TravelState] from a given string value.
  static TravelState resolve(String value) {
    return TravelState.values.firstWhere((e) => e.apiValue == value);
  }
}