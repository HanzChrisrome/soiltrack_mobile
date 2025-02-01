import 'package:soiltrack_mobile/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData().copyWith(
  colorScheme: lColorScheme,
  textTheme: TextTheme(
    titleLarge: GoogleFonts.dmSans(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: lColorScheme.onPrimary,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: lColorScheme.onSurface,
    ),
    titleSmall: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
      color: lColorScheme.onSurface,
    ),
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: lColorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: lColorScheme.onSurface,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: lColorScheme.onSurface,
    ),
  ),
);

ThemeData darkTheme = ThemeData().copyWith(
  colorScheme: dColorScheme,
  textTheme: TextTheme(
    titleLarge: GoogleFonts.dmSans(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: dColorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: dColorScheme.onSurface,
    ),
    titleSmall: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: dColorScheme.onSurface,
    ),
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: dColorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: dColorScheme.onSurface,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: dColorScheme.onSurface,
    ),
  ),
);
