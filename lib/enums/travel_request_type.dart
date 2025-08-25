enum TravelRequestType {

  online,
  offline;

  String get apiValue => name.toUpperCase();

  /// Resolves a [TravelState] from a given string value.
  static TravelRequestType resolve(String value) {
    return TravelRequestType.values.firstWhere((e) => e.apiValue == value);
  }
}