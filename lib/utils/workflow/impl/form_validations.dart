import 'package:quber_taxi/utils/workflow/core/step.dart';

/// Base class for form validation steps.
abstract class FormValidationStep implements WorkflowStep<String?> {
  
  /// The error message to return when validation Applies.
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