import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  static const _lightColors = CustomColorScheme(isDark: false);
  static const _darkColors = CustomColorScheme(isDark: true);

  static ThemeData get lightTheme => _buildTheme(_lightColors);
  static ThemeData get darkTheme => _buildTheme(_darkColors);

  static ThemeData _buildTheme(CustomColorScheme colors) => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: colors.primary,
        brightness: colors.brightness,
        fontFamily: GoogleFonts.inter().fontFamily,
        scaffoldBackgroundColor: colors.background,
        textTheme: _buildTextTheme(colors),
        elevatedButtonTheme: _buildElevatedButtonTheme(colors),
        inputDecorationTheme: _buildInputDecorationTheme(colors),
        chipTheme: _buildChipTheme(colors),
        cardTheme: _buildCardTheme(colors),
      );

  static TextTheme _buildTextTheme(CustomColorScheme colors) => TextTheme(
        headlineLarge: _getTextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          font: GoogleFonts.inter,
          color: colors.onSurface,
        ),
        headlineSmall: _getTextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          font: GoogleFonts.inter,
          color: colors.onSurface,
        ),
        bodyMedium: _getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          font: GoogleFonts.roboto,
          color: colors.onSurface,
        ),
      );

  static TextStyle _getTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Function font,
    required Color color,
  }) =>
      font(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      );

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
          CustomColorScheme colors) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors.onPrimary,
          backgroundColor: colors.primary,
          fixedSize: const Size(double.infinity, 53),
          minimumSize: const Size(double.infinity, 53),
          maximumSize: const Size(double.infinity, 53),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  static InputDecorationTheme _buildInputDecorationTheme(
          CustomColorScheme colors) =>
      InputDecorationTheme(
        border: _buildInputBorder(),
        filled: true,
        disabledBorder: _buildInputBorder(),
        enabledBorder: _buildInputBorder(),
        focusedBorder: _buildInputBorder(radius: 8.0),
        fillColor: colors.surface,
        hoverColor: colors.primary.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 20.0,
        ),
        floatingLabelStyle: _buildLabelStyle(colors),
        labelStyle: _buildLabelStyle(colors),
      );

  static OutlineInputBorder _buildInputBorder({double radius = 10.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Colors.transparent),
      );

  static TextStyle _buildLabelStyle(CustomColorScheme colors) =>
      GoogleFonts.inter(
        fontSize: 12,
        color: colors.onSurface.withOpacity(0.5),
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      );

  static ChipThemeData _buildChipTheme(CustomColorScheme colors) =>
      ChipThemeData(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(20.0),
        ),
        deleteIconBoxConstraints: const BoxConstraints(
          minHeight: 21,
          minWidth: 57,
        ),
        color: WidgetStatePropertyAll(colors.primary),
        backgroundColor: colors.surface,
        disabledColor: colors.primary.withOpacity(0.1),
        selectedColor: colors.primary,
        secondarySelectedColor: colors.secondary,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: colors.onPrimary,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: colors.primary,
          fontWeight: FontWeight.w500,
        ),
        brightness: colors.brightness,
      );

  static CardTheme _buildCardTheme(CustomColorScheme colors) => CardTheme(
        color: colors.surface,
        shadowColor: colors.shadow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      );
}
