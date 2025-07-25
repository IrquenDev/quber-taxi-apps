import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

enum DriverAccountState {

  notConfirmed(apiValue: "NOT_CONFIRMED"),
  canPay(apiValue: "CAN_PAY"),
  paymentRequired(apiValue: "PAYMENT_REQUIRED"),
  enabled(apiValue: "ENABLED"),
  disabled(apiValue: "DISABLED");

  final String apiValue;

  static IconData iconOf(DriverAccountState state) {
    return switch (state) {
      DriverAccountState.notConfirmed => Icons.watch_later_outlined,
      DriverAccountState.canPay => Icons.payment_outlined,
      DriverAccountState.paymentRequired => Icons.payment_outlined,
      DriverAccountState.enabled => Icons.done_outline,
      DriverAccountState.disabled => Icons.lock_outline
    };
  }

  static String nameOf(DriverAccountState state, AppLocalizations localizations) {
    return switch (state) {
      DriverAccountState.notConfirmed => localizations.driverStateNotConfirmed,
      DriverAccountState.canPay => localizations.driverStateCanPay,
      DriverAccountState.paymentRequired => localizations.driverStatePaymentRequired,
      DriverAccountState.enabled => localizations.driverStateEnabled,
      DriverAccountState.disabled => localizations.driverStateDisabled
    };
  }

  const DriverAccountState({required this.apiValue});

  /// Resolves a [DriverAccountState] from a given string value. Normally used in [Driver.fromJson]
  static DriverAccountState resolve(String value) {
    return DriverAccountState.values.firstWhere((e) => e.apiValue == value);
  }
}