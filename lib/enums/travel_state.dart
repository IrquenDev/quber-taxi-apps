enum TravelState {

  canceled,
  waiting,
  accepted,
  inProgress,
  completed;

  String get apiValue => name.toUpperCase();

  /// Resolves a [TravelState] from a given string value.
  static TravelState resolve(String value) {
    return TravelState.values.firstWhere((e) => e.apiValue == value);
  }
}