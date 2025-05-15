import 'package:flutter/material.dart';
import 'package:quber_taxi/theme/colors.dart';
import 'package:quber_taxi/theme/dimensions.dart';

// ---- Colors ----

// The app primary color, most commonly used color to to emphasize components.
// Available in Theme.of(context).colorScheme.primaryColor.
// @Temporal
const _primaryColor = Color(0xFFFBB735);

// The neutral app color to use in disabled (or unselected if applies)
// Available in Theme.of(context).extension<ColorExtension>()!.neutralColor
const _neutralColor = Colors.grey;

// The lightest app color.
// Available in Theme.of(context).extension<ColorExtension>()!.lightestColor.
const _lightestColor = Colors.white;

// The darkest app color.
// Available in Theme.of(context).extension<ColorExtension>()!.darkestColor.
const _darkestColor = Colors.black;

// The default icon color around the app. Available in Theme.of(context).iconTheme.color.
final _defaultIconColor = _darkestColor.withAlpha(175);

// ---- Dimensions ----

// The default border ratio of all components to which it applies.
// Available in Theme.of(context).extension<DimensionExtension>()!.borderRadius.
const _defaultBorderRadius = 20.0;

// The default border ratio of all components to which it applies.
// Available in Theme.of(context).extension<DimensionExtension>()!.elevation.
const _defaultElevation = 4.0;

// The default border ratio of all components to which it applies.
// Available in Theme.of(context).extension<DimensionExtension>()!.contentPadding.
const _defaultContentPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

// The default size for any icon.
// Available in Theme.of(context).iconTheme.size.
const _defaultIconSize = 28.0;

/// The app theme itself. Only `light mode` will be available for now.
final appTheme = ThemeData(

  brightness: Brightness.light,

  colorScheme: ColorScheme.light(
    primary: _primaryColor
  ),

  iconTheme: IconThemeData(
    color: _defaultIconColor,
    size: _defaultIconSize
  ),

  inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightestColor,
      contentPadding: _defaultContentPadding,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: _neutralColor),
      suffixIconColor: _defaultIconColor
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _lightestColor,
        padding: _defaultContentPadding,
        side: BorderSide.none,
        elevation: _defaultElevation
      )
  ),

  // Custom theme extension.
  // Available in ... final appTheme = Theme.of(context).extension<SomeXExtension>()!;
  extensions: <ThemeExtension<dynamic>>[
    const ColorExtension(
        lightestColor: _lightestColor,
        darkestColor: _darkestColor,
        neutralColor: _neutralColor
    ),
    const DimensionExtension(
        borderRadius: BorderRadius.all(Radius.circular(_defaultBorderRadius)),
        elevation: _defaultElevation,
        contentPadding: _defaultContentPadding
    )
  ]
);