import 'package:quber_taxi/l10n/app_localizations.dart';

enum ClientAccountState {
  blocked(apiValue: "BLOCKED"),
  active(apiValue: "ACTIVE");

  final String apiValue;

  const ClientAccountState({required this.apiValue});

  static String imageOf(ClientAccountState state) {
    return switch (state) {
      ClientAccountState.blocked => "assets/icons/locked.png",
      ClientAccountState.active => "assets/icons/ready.png"
    };
  }

  static String nameOf(ClientAccountState state, AppLocalizations localizations) {
    return switch (state) {
      ClientAccountState.blocked => localizations.clientStateBlocked,
      ClientAccountState.active => localizations.clientStateActive
    };
  }

  /// Resolves a [ClientAccountState] from a given string value. Normally used in [Client.fromJson]
  static ClientAccountState resolve(String value) {
    return ClientAccountState.values.firstWhere((e) => e.apiValue == value);
  }
}