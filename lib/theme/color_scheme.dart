import 'package:flutter/material.dart';

var lColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color(0xFF134F14),
  primary: const Color.fromARGB(255, 255, 255, 255),
  onPrimary: const Color(0xFF134F14),
  secondary: const Color.fromARGB(255, 31, 29, 29),
  onSecondary: const Color.fromARGB(255, 74, 241, 77),
  surface: const Color.fromARGB(255, 248, 248, 248),
  onSurface: const Color.fromARGB(255, 100, 100, 100),
);

// Dark Mode ColorScheme
var dColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color(0xFF134F14),
  primary: const Color.fromARGB(255, 90, 90, 90),
  onPrimary: const Color(0xFF134F14),
  secondary: const Color.fromARGB(255, 30, 30, 30),
  onSecondary: const Color(0xFFBBDEFB),
  surface: const Color(0xFF121212),
  onSurface: const Color(0xFFE0E0E0),
);
