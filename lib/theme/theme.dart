import "package:flutter/material.dart";
import "package:quber_taxi/theme/dimensions.dart";

class MaterialTheme {

  final TextTheme textTheme;

  final dimensions = const DimensionExtension(
      borderRadius: 20.0,
      buttonBorderRadius: 8.0,
      cardBorderRadiusSmall: 8.0,
      cardBorderRadiusMedium: 12.0,
      cardBorderRadiusLarge: 16.0,
      elevation: 4.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
  );

  final iconSize = 28.0;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light, 
      primary: Color(0xfffbb735),   
      surfaceTint: Color(0xfffbb735),
      onPrimary: Color(0xff151515),
      primaryContainer: Color(0xfffbb735),
      onPrimaryContainer: Color(0xff6c4a00),
      secondary: Color(0xff000000),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff2b2b2b),
      onSecondaryContainer: Color(0xff858383),
      tertiary: Color(0xff005e53),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00796b),
      onTertiaryContainer: Color(0xffa1feec),
      error: Color(0xff900708),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffb3261e),
      onErrorContainer: Color(0xffffcbc4),
      surface: Color(0xffeff2f9), 
      onSurface: Color(0xff2b2b2b), 
      surfaceVariant: Color(0xfffef1d7),
      onSurfaceVariant: Color(0xff45474b),
      outline: Color(0xff75777b),
      outlineVariant: Color(0xffc5c6cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffffba38),
      primaryFixed: Color(0xffffdeac),
      onPrimaryFixed: Color(0xff281900),
      primaryFixedDim: Color(0xffffba38),
      onPrimaryFixedVariant: Color(0xff604100),
      secondaryFixed: Color(0xffe5e2e1),
      onSecondaryFixed: Color(0xff2b2b2b),
      secondaryFixedDim: Color(0xffc8c6c5),
      onSecondaryFixedVariant: Color(0xff474646),
      tertiaryFixed: Color(0xff97f3e2),
      onTertiaryFixed: Color(0xff00201b),
      tertiaryFixedDim: Color(0xff7ad7c6),
      onTertiaryFixedVariant: Color(0xff005047),
      surfaceDim: Color(0xffddd9d9),
      surfaceBright: Color(0xffeff2f9),
      surfaceContainerLowest: Color(0xfff5f5f5), 
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e7),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xffd50000),
      surfaceTint: Color(0xfffbb735),
      onPrimary: Color(0xff151515),
      primaryContainer: Color(0xff916500),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff000000),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff2b2b2b),
      onSecondaryContainer: Color(0xffa8a6a6),
      tertiary: Color(0xff003e36),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00796b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740003),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffb3261e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xffd1d6e3),
      onSurface: Color(0xff111111),
      surfaceVariant: Color(0xfffef1d7),
      onSurfaceVariant: Color(0xff34363a),
      outline: Color(0xff505356),
      outlineVariant: Color(0xff6b6d71),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffffba38),
      primaryFixed: Color(0xff916500),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff724e00),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6e6d6c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff555454),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff067b6d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff006055),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xffeff2f9),
      surfaceContainerLowest: Color(0xfff5f5f5),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xffebe7e7),
      surfaceContainerHigh: Color(0xffdfdcdb),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xfffd0000),
      surfaceTint: Color(0xfffbb735),
      onPrimary: Color(0xff151515),
      primaryContainer: Color(0xff634300),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff000000),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff2b2b2b),
      onSecondaryContainer: Color(0xffd2d0cf),
      tertiary: Color(0xff00332c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff005349),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff610002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff950c0b),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xffeff2f9),
      onSurface: Color(0xff000000),
      surfaceVariant: Color(0xfffef1d7),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2a2c30),
      outlineVariant: Color(0xff47494d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffffba38),
      primaryFixed: Color(0xff634300),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff462e00),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4a4949),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff333232),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff005349),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003a32),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b7),
      surfaceBright: Color(0xffeff2f9),
      surfaceContainerLowest: Color(0xfff5f5f5),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color(0xffd7d4d3),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffdaa1),
      surfaceTint: Color(0xffffba38),
      onPrimary: Color(0xff432c00),
      primaryContainer: Color(0xfffbb735),
      onPrimaryContainer: Color(0xff6c4a00),
      secondary: Color(0xffc8c6c5),
      onSecondary: Color(0xff313030),
      secondaryContainer: Color(0xff151515),
      onSecondaryContainer: Color(0xff807f7e),
      tertiary: Color(0xff7ad7c6),
      onTertiary: Color(0xff003730),
      tertiaryContainer: Color(0xff00796b),
      onTertiaryContainer: Color(0xffa1feec),
      error: Color(0xffffb4aa),
      onError: Color(0xff690003),
      errorContainer: Color(0xffb3261e),
      onErrorContainer: Color(0xffffcbc4),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      surfaceVariant: Color(0xfffef1d7),
      onSurfaceVariant: Color(0xffc5c6cb),
      outline: Color(0xff8f9195),
      outlineVariant: Color(0xff45474b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xfffbb735),
      primaryFixed: Color(0xffffdeac),
      onPrimaryFixed: Color(0xff281900),
      primaryFixedDim: Color(0xffffba38),
      onPrimaryFixedVariant: Color(0xff604100),
      secondaryFixed: Color(0xffe5e2e1),
      onSecondaryFixed: Color(0xff2b2b2b),
      secondaryFixedDim: Color(0xffc8c6c5),
      onSecondaryFixedVariant: Color(0xff474646),
      tertiaryFixed: Color(0xff97f3e2),
      onTertiaryFixed: Color(0xff00201b),
      tertiaryFixedDim: Color(0xff7ad7c6),
      onTertiaryFixedVariant: Color(0xff005047),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff2b2b2b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2a2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffdaa1),
      surfaceTint: Color(0xffffba38),
      onPrimary: Color(0xffff0000),
      primaryContainer: Color(0xfffbb735),
      onPrimaryContainer: Color(0xff472f00),
      secondary: Color(0xffdedcdb),
      onSecondary: Color(0xff262525),
      secondaryContainer: Color(0xff929090),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff91eddc),
      onTertiary: Color(0xff002b25),
      tertiaryContainer: Color(0xff40a090),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540002),
      errorContainer: Color(0xfffa5a4a),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      surfaceVariant: Color(0xfffef1d7),
      onSurfaceVariant: Color(0xffdbdce0),
      outline: Color(0xffb0b2b6),
      outlineVariant: Color(0xff8f9094),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff614200),
      primaryFixed: Color(0xffffdeac),
      onPrimaryFixed: Color(0xff1a0f00),
      primaryFixedDim: Color(0xffffba38),
      onPrimaryFixedVariant: Color(0xffcf0707),
      secondaryFixed: Color(0xffe5e2e1),
      onSecondaryFixed: Color(0xff111111),
      secondaryFixedDim: Color(0xffc8c6c5),
      onSecondaryFixedVariant: Color(0xff363636),
      tertiaryFixed: Color(0xff97f3e2),
      onTertiaryFixed: Color(0xff001511),
      tertiaryFixedDim: Color(0xff7ad7c6),
      onTertiaryFixedVariant: Color(0xff003e36),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282828),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffedd7),
      surfaceTint: Color(0xffffba38),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xfffbb735),
      onPrimaryContainer: Color(0xff140b00),
      secondary: Color(0xfff2efef),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc4c2c1),
      onSecondaryContainer: Color(0xff0b0b0b),
      tertiary: Color(0xffb0ffef),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff76d3c2),
      onTertiaryContainer: Color(0xff000e0b),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea3),
      onErrorContainer: Color(0xff220000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeff0f4),
      outlineVariant: Color(0xffc1c2c7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff614200),
      primaryFixed: Color(0xffffdeac),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffba38),
      onPrimaryFixedVariant: Color(0xff1a0f00),
      secondaryFixed: Color(0xffe5e2e1),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc8c6c5),
      onSecondaryFixedVariant: Color(0xff111111),
      tertiaryFixed: Color(0xff97f3e2),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff7ad7c6),
      onTertiaryFixedVariant: Color(0xff001511),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff51504f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff474646),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: iconSize
    ),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: dimensions.contentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        suffixIconColor: colorScheme.onSurface
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            disabledBackgroundColor: colorScheme.onSurface.withAlpha(32),
            foregroundColor: colorScheme.onPrimaryContainer,
            disabledForegroundColor: colorScheme.onSurface.withAlpha(94),
            padding: dimensions.contentPadding,
            side: BorderSide.none,
            elevation: dimensions.elevation
        )
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero
      )
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          disabledBackgroundColor: colorScheme.onSurface.withAlpha(32),
          foregroundColor: colorScheme.onPrimaryContainer,
          disabledForegroundColor: colorScheme.onSurface.withAlpha(96),
          padding: dimensions.contentPadding,
          side: BorderSide.none,
          elevation: dimensions.elevation,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(dimensions.borderRadius * 0.5))),
        )
    ),
    dividerColor: colorScheme.outlineVariant,
    extensions: <ThemeExtension<dynamic>>[dimensions]
  );
}