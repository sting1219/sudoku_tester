import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color scaffoldBackground = Color(0xFF0F172A);
  static const Color cardBackground = Color(0xFF1E293B);
  static const Color accentColor = Color(0xFF00E5FF);
  static const Color indigoAccent = Colors.indigoAccent;
  static const Color dangerColor = Colors.redAccent;
  static const Color successColor = Colors.greenAccent;
  static const Color hintColor = Colors.amber;
  static const Color textBody = Colors.white70;
  static const Color textHeadline = Colors.white;
  static const Color dialogBackground = Color(0xFF0F1A15);
}

class AppStyles {
  static TextStyle get headlineMedium => GoogleFonts.cinzel(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textHeadline,
  );

  static TextStyle get bodyLarge =>
      const TextStyle(fontSize: 16, color: AppColors.textBody);

  static TextStyle get battleLogText => const TextStyle(
    fontSize: 13,
    color: Colors.white,
    fontFamily: 'monospace',
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
    ],
  );
}
