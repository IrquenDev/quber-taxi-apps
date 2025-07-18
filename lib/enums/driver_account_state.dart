import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/driver.dart';

enum DriverAccountState {

  notConfirmed(apiValue: "NOT_CONFIRMED"),
  paymentRequired(apiValue: "PAYMENT_REQUIRED"),
  enabled(apiValue: "ENABLED"),
  disabled(apiValue: "DISABLED");

  final String apiValue;

  static IconData iconOf(DriverAccountState state) {
    return switch (state) {
      DriverAccountState.notConfirmed => Icons.watch_later_outlined,
      DriverAccountState.paymentRequired => Icons.payment_outlined,
      DriverAccountState.enabled => Icons.done_outline,
      DriverAccountState.disabled => Icons.lock_outline
    };
  }

  const DriverAccountState({required this.apiValue});

  /// Resolves a [DriverAccountState] from a given string value. Normally used in [Driver.fromJson]
  static DriverAccountState resolve(String value) {
    return DriverAccountState.values.firstWhere((e) => e.apiValue == value);
  }
}