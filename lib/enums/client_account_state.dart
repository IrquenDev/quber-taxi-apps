enum ClientAccountState {
  blocked(apiValue: "BLOCKED"),
  active(apiValue: "ACTIVE");

  final String apiValue;

  const ClientAccountState({required this.apiValue});

  /// Resolves a [ClientAccountState] from a given string value. Normally used in [Client.fromJson]
  static ClientAccountState resolve(String value) {
    return ClientAccountState.values.firstWhere((e) => e.apiValue == value);
  }
}