// -----------------------------------------------------------------
// Thème global de l'application DetectSen (TerangaSkills)
// Centralise les couleurs, styles et Google Fonts (Material 3)
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeApplication {

  // ─── PALETTE DE COULEURS ────────────────────────────────────────

  static const Color couleurPrimaire = Color(0xFF5780FA);
  static const Color couleurFondSombre = Color(0xFF12202F);
  static const Color couleurSecondaire = Color(0xFF1E8449);

  static const Color couleurDanger = Color(0xFFC0392B);
  static const Color couleurAvertissement = Color(0xFFE67E22);

  static const Color couleurFond = Color(0xFFF5F6FA);
  static const Color couleurTexte = Color(0xFF2C3E50);
  static const Color couleurTexteSecondaire = Color(0xFF7F8C8D);

  // ─── LOGIQUE DE SCORE ───────────────────────────────────────────

  static Color couleurSelonScore(int score) {
    if (score >= 70) return couleurDanger;
    if (score >= 40) return couleurAvertissement;
    return couleurSecondaire;
  }

  // ─── THÈME SOMBRE ───────────────────────────────────────────────

  static ThemeData get themeSombre {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: couleurFondSombre,
    colorScheme: ColorScheme.fromSeed(
      seedColor: couleurPrimaire,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.montserratTextTheme(
      ThemeData.dark().textTheme,
    ),
  );
}
  // ─── THÈME CLAIR ────────────────────────────────────────────────

  static ThemeData get themeClair {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: couleurFond,

      colorScheme: ColorScheme.fromSeed(
        seedColor: couleurPrimaire,
        primary: couleurPrimaire,
        secondary: couleurSecondaire,
        error: couleurDanger,
        brightness: Brightness.light,
      ),

      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData.light().textTheme,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: couleurPrimaire,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: couleurPrimaire,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          color: couleurTexteSecondaire,
        ),
      ),

      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 6),
      ),
    );
  }
}