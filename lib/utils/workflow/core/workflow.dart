import 'package:quber_taxi/utils/workflow/core/step.dart';

/// A generic and composable workflow pipeline for sequentially processing
/// a value through a series of conditional [WorkflowStep]s.
///
/// The [Workflow] is designed to model a flexible chain of actions or
/// transformations that are applied to a value of type [T], based on
/// custom logic defined in each step.
///
/// This pattern can be used for:
/// - Data validation pipelines
/// - Transformation sequences
/// - Business logic workflows
/// - Action pipelines (e.g., form processing, task execution, etc.)
///
/// Example:
/// ```dart
/// final workflow = Workflow<String>()
///   .step(TrimStep())
///   .step(ToUpperCaseStep())
///   .withDefault((value) => "$value_default")
///   .breakOnFirstApply(true);
///
/// final result = workflow.proceed(" hello ");
/// print(result); // "HELLO" (or with default if no steps matched)
/// ```
///
/// Each step determines whether it should be applied via [WorkflowStep.canApply].
class Workflow<T> {

  final List<WorkflowStep<T>> _steps = [];
  bool _stopAfterFirstMatch = false;
  T Function(T value)? _defaultHandler;

  /// Adds a new [WorkflowStep] to the workflow pipeline.
  ///
  /// Steps are applied in the order they are added.
  Workflow<T> step(WorkflowStep<T> step) {
    _steps.add(step);
    return this;
  }

  /// Configures the workflow to stop after the first step that applies.
  ///
  /// If set to `true`, only the first applicable step will be executed.
  Workflow<T> breakOnFirstApply(bool enabled) {
    _stopAfterFirstMatch = enabled;
    return this;
  }

  /// Provides a default fallback transformation if no steps were applied.
  ///
  /// The function receives the original [value], and its result will be
  /// returned from [proceed] if no steps matched.
  Workflow<T> withDefault(T Function(T value) handler) {
    _defaultHandler = handler;
    return this;
  }

  /// Executes the workflow starting from an initial value [initialValue].
  ///
  /// For each step, if [WorkflowStep.canApply] returns true, then
  /// [WorkflowStep.apply] is invoked. If [breakOnFirstApply] was enabled,
  /// the workflow stops after the first applicable step.
  ///
  /// If no step was applicable and a [withDefault] handler was defined,
  /// it will be invoked and its result returned.
  ///
  /// Returns the final value after processing.
  T proceed(T initialValue) {
    T value = initialValue;
    bool anyApplied = false;
    for (final step in _steps) {
      if (step.canApply(value)) {
        value = step.apply(value);
        anyApplied = true;
        if (_stopAfterFirstMatch) break;
      }
    }
    return !anyApplied && _defaultHandler != null ? _defaultHandler!(initialValue) : value;
  }
}