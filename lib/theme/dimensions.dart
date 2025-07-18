import 'package:flutter/material.dart';
import 'dart:ui';

/// A custom [ThemeExtension] that centralizes commonly used dimensional properties.
///
/// This extension promotes consistent visual design across the app by avoiding
/// magic numbers in layout and styling code.
///
/// ### Typical Use Cases:
/// - TextField and Card border radius.
/// - Elevation for shadows or layered elements.
/// - Centralizing UI metrics to match design system guidelines.
///
/// ### Usage
///
/// ```dart
/// final dimensions = Theme.of(context).extension<DimensionExtension>()!;
///
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: dimensions.borderRadius,
///     boxShadow: [
///       BoxShadow(
///         blurRadius: dimensions.elevation,
///         color: Colors.black26,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Benefits:
/// - Promotes visual consistency.
/// - Reduces boilerplate and hardcoded values.
/// - Enables theme interpolation for animations or theme switching
///
/// ### Extending This Class:
/// Add any other commonly used design constants, such as:
/// - `spacing`
/// - `animation durations`
/// - `padding`
///
/// Be sure to update `copyWith` and `lerp` when new fields are added.
@immutable
class DimensionExtension extends ThemeExtension<DimensionExtension> {

  /// Default border radius used across the app.
  final double borderRadius;

  /// Standard elevation value used for shadows or raised surfaces.
  final double elevation;

  final EdgeInsets contentPadding;

  /// {@macro dimension_extension}
  const DimensionExtension({
    required this.borderRadius,
    required this.elevation,
    required this.contentPadding
  });

  @override
  DimensionExtension copyWith({
    double? borderRadius,
    double? elevation,
    EdgeInsets? contentPadding
  }) {
    return DimensionExtension(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      contentPadding: contentPadding ?? this.contentPadding
    );
  }

  @override
  DimensionExtension lerp(ThemeExtension<DimensionExtension>? other, double t) {
    if (other is! DimensionExtension) return this;
    return DimensionExtension(
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      contentPadding: EdgeInsets.lerp(contentPadding, other.contentPadding, t)!,
    );
  }
}