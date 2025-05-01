import 'package:flutter/material.dart';

/// A custom [ThemeExtension] that centralizes commonly used custom colors.
///
/// This extension helps ensure color consistency across the app by avoiding
/// hardcoded color values and encouraging adherence to the design system.
///
/// ### Typical Use Cases:
/// - Define and access brand or theme-specific colors.
/// - Easily switch between color themes (e.g., light/dark/custom).
/// - Improve readability and maintainability of color usage.
///
/// ### Usage
///
/// ```dart
/// final colors = Theme.of(context).extension<ColorExtension>()!;
///
/// Container(
///   color: colors.lightestColor,
///   child: Text(
///     'Hello',
///     style: TextStyle(color: colors.darkestColor),
///   ),
/// )
/// ```
///
/// ### Benefits:
/// - Centralizes color definitions.
/// - Enables smooth interpolation when switching themes.
/// - Reduces the need for scattered color constants.
///
/// ### Extending This Class:
/// You can add other color roles or semantic tokens as needed, such as:
/// - `successColor`
/// - `warningColor`
///
/// Be sure to update `copyWith` and `lerp` when new fields are added.
@immutable
class ColorExtension extends ThemeExtension<ColorExtension> {
  /// The lightest shade used, often for backgrounds or highlights.
  final Color lightestColor;

  /// The darkest shade used, suitable for text or contrast elements.
  final Color darkestColor;

  /// A neutral tone used for borders, dividers, or muted backgrounds.
  final Color neutralColor;

  /// {@macro color_extension}
  const ColorExtension({
    required this.lightestColor,
    required this.darkestColor,
    required this.neutralColor,
  });

  @override
  ColorExtension copyWith({
    Color? lightestColor,
    Color? darkestColor,
    Color? neutralColor,
  }) {
    return ColorExtension(
      lightestColor: lightestColor ?? this.lightestColor,
      darkestColor: darkestColor ?? this.darkestColor,
      neutralColor: neutralColor ?? this.neutralColor,
    );
  }

  @override
  ColorExtension lerp(ThemeExtension<ColorExtension>? other, double t) {
    if (other is! ColorExtension) return this;
    return ColorExtension(
      lightestColor: Color.lerp(lightestColor, other.lightestColor, t)!,
      darkestColor: Color.lerp(darkestColor, other.darkestColor, t)!,
      neutralColor: Color.lerp(neutralColor, other.neutralColor, t)!,
    );
  }
}