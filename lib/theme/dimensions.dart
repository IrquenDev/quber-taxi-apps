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

  /// Border radius for buttons.
  final double buttonBorderRadius;

  /// Border radius for small cards and components.
  final double cardBorderRadiusSmall;

  /// Border radius for medium cards and components.
  final double cardBorderRadiusMedium;

  /// Border radius for large cards and components.
  final double cardBorderRadiusLarge;

  /// Standard elevation value used for shadows or raised surfaces.
  final double elevation;

  final EdgeInsets contentPadding;

  /// {@macro dimension_extension}
  const DimensionExtension({
    required this.borderRadius,
    required this.buttonBorderRadius,
    required this.cardBorderRadiusSmall,
    required this.cardBorderRadiusMedium,
    required this.cardBorderRadiusLarge,
    required this.elevation,
    required this.contentPadding
  });

  @override
  DimensionExtension copyWith({
    double? borderRadius,
    double? buttonBorderRadius,
    double? cardBorderRadiusSmall,
    double? cardBorderRadiusMedium,
    double? cardBorderRadiusLarge,
    double? elevation,
    EdgeInsets? contentPadding
  }) {
    return DimensionExtension(
      borderRadius: borderRadius ?? this.borderRadius,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      cardBorderRadiusSmall: cardBorderRadiusSmall ?? this.cardBorderRadiusSmall,
      cardBorderRadiusMedium: cardBorderRadiusMedium ?? this.cardBorderRadiusMedium,
      cardBorderRadiusLarge: cardBorderRadiusLarge ?? this.cardBorderRadiusLarge,
      elevation: elevation ?? this.elevation,
      contentPadding: contentPadding ?? this.contentPadding
    );
  }

  @override
  DimensionExtension lerp(ThemeExtension<DimensionExtension>? other, double t) {
    if (other is! DimensionExtension) return this;
    return DimensionExtension(
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      buttonBorderRadius: lerpDouble(buttonBorderRadius, other.buttonBorderRadius, t)!,
      cardBorderRadiusSmall: lerpDouble(cardBorderRadiusSmall, other.cardBorderRadiusSmall, t)!,
      cardBorderRadiusMedium: lerpDouble(cardBorderRadiusMedium, other.cardBorderRadiusMedium, t)!,
      cardBorderRadiusLarge: lerpDouble(cardBorderRadiusLarge, other.cardBorderRadiusLarge, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      contentPadding: EdgeInsets.lerp(contentPadding, other.contentPadding, t)!,
    );
  }
}