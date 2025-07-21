import 'package:quber_taxi/utils/workflow/core/step.dart';

/// Base class for form validation steps.
abstract class FormValidationStep implements WorkflowStep<String?> {

  /// {@template errorMessage}
  /// The error message to return when validation Applies.
  /// {@endtemplate}
  final String errorMessage;

  FormValidationStep({required this.errorMessage});

  /// Defines whether this step should apply given [value].
  @override
  bool canApply(String? value);

  /// Returns the error message (always [errorMessage]).
  @override
  String? apply(String? value) => errorMessage;
}

/// Applies if the value is null or empty.
class RequiredStep extends FormValidationStep {

  RequiredStep({required super.errorMessage});

  @override
  bool canApply(String? value) => value == null || value.trim().isEmpty;
}

/// Applies if the value's length is less than [min].
class MinLengthStep extends FormValidationStep {

  final int min;

  MinLengthStep({required this.min, required super.errorMessage});

  @override
  bool canApply(String? value) => value == null || value.length < min;
}

/// Applies if [value] and [other] are not equal.
class MatchOtherStep extends FormValidationStep {
  final String? other;

  MatchOtherStep({required this.other, required super.errorMessage});

  @override
  bool canApply(String? value) => value != other;
}

/// Applies if the value is not a valid percentage (0-100).
class ValidPercentageStep extends FormValidationStep {

  ValidPercentageStep({required super.errorMessage});

  @override
  bool canApply(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    try {
      final percentage = double.parse(value);
      return percentage < 0 || percentage > 100;
    } catch (e) {
      return true; // Invalid number format
    }
  }
}

/// Applies if the value is not a valid positive number.
class ValidPositiveNumberStep extends FormValidationStep {

  ValidPositiveNumberStep({required super.errorMessage});

  @override
  bool canApply(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    try {
      final number = double.parse(value);
      return number <= 0;
    } catch (e) {
      return true; // Invalid number format
    }
  }
}