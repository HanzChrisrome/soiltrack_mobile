import 'package:flutter/material.dart';

var lColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color(0xFF134F14),
  primary: const Color.fromARGB(255, 245, 245, 245),
  onPrimary: const Color(0xFF134F14),
  secondary: const Color.fromARGB(255, 31, 31, 31),
  onSecondary: const Color.fromARGB(255, 13, 70, 14),
  surface: const Color(0xFFEBEBEB),
  onSurface: const Color(0xFF000000),
);

// Dark Mode ColorScheme
var dColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color(0xFF134F14),
  primary: const Color.fromARGB(255, 50, 50, 50),
  onPrimary: const Color(0xFF134F14),
  secondary: const Color.fromARGB(255, 30, 30, 30),
  onSecondary: const Color(0xFFBBDEFB),
  surface: const Color(0xFF121212),
  onSurface: const Color(0xFFE0E0E0),
);
