import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade package to version 8.0.1.
///
/// Use in [MaterialApp] like this:
///
/// MaterialApp(
///  theme: AppTheme.light,
///  darkTheme: AppTheme.dark,
///  :
/// );
sealed class AppTheme {
  // The defined light theme.
  static ThemeData light = FlexThemeData.light(
    colors: const FlexSchemeColor( // Custom
      primary: Color(0xff004881),
      primaryContainer: Color(0xffd0e4ff),
      primaryLightRef: Color(0xff004881),
      secondary: Color(0xffac3306),
      secondaryContainer: Color(0xffffdbcf),
      secondaryLightRef: Color(0xffac3306),
      tertiary: Color(0xff006875),
      tertiaryContainer: Color(0xff95f0ff),
      tertiaryLightRef: Color(0xff006875),
      appBarColor: Color(0xffffdbcf),
      error: Color(0xffba1a1a),
      errorContainer: Color(0xffffdad6),
    ),
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 8.0,
      segmentedButtonSchemeColor: SchemeColor.primaryContainer,
      inputDecoratorIsFilled: false,
      inputDecoratorRadius: 8.0,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
  // The defined dark theme.
  static ThemeData dark = FlexThemeData.dark(
    colors: const FlexSchemeColor( // Custom
      primary: Color(0xff9fc9ff),
      primaryContainer: Color(0xff00325b),
      primaryLightRef: Color(0xff004881),
      secondary: Color(0xffffb59d),
      secondaryContainer: Color(0xff872100),
      secondaryLightRef: Color(0xffac3306),
      tertiary: Color(0xff86d2e1),
      tertiaryContainer: Color(0xff004e59),
      tertiaryLightRef: Color(0xff006875),
      appBarColor: Color(0xffffdbcf),
      error: Color(0xffffb4ab),
      errorContainer: Color(0xff93000a),
    ),
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 8.0,
      segmentedButtonSchemeColor: SchemeColor.primaryContainer,
      inputDecoratorIsFilled: false,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
