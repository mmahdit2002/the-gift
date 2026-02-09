import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFFFB7C5); // Cherry blossom pink
  static const Color deepPink = Color(0xFFFF69B4); // Hot pink
  static const Color backgroundPink = Color(0xFFFFF0F5); // Lavender blush
  static const Color textDark = Color(0xFF5D4037); // Brownish (classic Hello Kitty text color)

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryPink,
      scaffoldBackgroundColor: backgroundPink,
      textTheme: GoogleFonts.quicksandTextTheme().apply(bodyColor: textDark, displayColor: textDark),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: deepPink),
    );
  }

  // Neumorphic Decoration (Soft extruded look)
  static BoxDecoration neumorphicDecoration({Color color = backgroundPink, double radius = 20, bool isPressed = false}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: isPressed
          ? [] // No shadow looks pressed in (flat)
          : [
              BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-6, -6), blurRadius: 10),
              BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(6, 6), blurRadius: 10),
            ],
      border: isPressed ? Border.all(color: Colors.black.withOpacity(0.05), width: 2) : null,
    );
  }

  // Glassmorphic Decoration (Frosted glass)
  static BoxDecoration glassDecoration({double radius = 20}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      boxShadow: [BoxShadow(color: deepPink.withOpacity(0.1), blurRadius: 16, spreadRadius: 2)],
    );
  }
}
