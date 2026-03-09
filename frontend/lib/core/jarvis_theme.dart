import 'package:flutter/material.dart';

/// Central color constants and theme for the JARVIS app.
class JarvisTheme {
  JarvisTheme._();

  // ─── Plasma blob colors ───
  static const Color colorDeep   = Color(0xFF001A1A);
  static const Color colorMid    = Color(0xFF00A8A8);
  static const Color colorBright = Color(0xFF01F2F2);
  static const Color shellColor  = Color(0xFF01F2F2);

  // ─── Background gradient ───
  static const Color bgCenter = Color(0xFF0B1520);
  static const Color bgMid    = Color(0xFF07101A);
  static const Color bgEdge   = Color(0xFF000000);

  // ─── Grid colors ───
  static const Color gridGrey = Color(0xFF9BA3AA);
  static const Color pulseTeal = Color(0xFF01F2F2);

  // ─── App theme ───
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgEdge,
    colorScheme: const ColorScheme.dark(
      primary: colorBright,
      secondary: colorMid,
      surface: bgCenter,
    ),
    fontFamily: 'Roboto',
  );
}
