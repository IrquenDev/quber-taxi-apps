/// Represents a single conditional step within a [Workflow] pipeline.
///
/// A [WorkflowStep] defines logic for:
/// - Checking whether it should be applied to a given value ([canApply])
/// - Transforming or processing that value ([apply])
///
/// This interface is intended to be implemented for specific use cases,
/// such as:
/// - Input sanitization
/// - Field validation
/// - Business rule enforcement
/// - State transitions
///
/// Example:
/// ```dart
/// class TrimStep implements WorkflowStep<String> {
///   @override
///   bool canApply(String value) => value.trim() != value;
///
///   @override
///   String apply(String value) => value.trim();
/// }
/// ```
abstract interface class WorkflowStep<T> {

  /// Determines whether this step should be applied to the given [value].
  ///
  /// This allows skipping steps conditionally based on input or state.
  bool canApply(T value);

  /// Applies this step's transformation or action to the [value].
  ///
  /// Only called if [canApply] returned true. The returned value is passed
  /// to the next step in the [Workflow].
  T apply(T value);
}