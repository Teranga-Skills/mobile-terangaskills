// -----------------------------------------------------------------
// Thème global de l'application TerangaSkills
// Centralise les couleurs, styles et Google Fonts (Material 3)
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeApplication {

  // ─── PALETTE DE COULEURS ────────────────────────────────────────

  static const Color couleurPrimaire         = Color(0xFF0C3F5E);
  static const Color couleurFondSombre       = Color(0xFF12202F);
  static const Color couleurSecondaire       = Color(0xFF1E8449);

  static const Color couleurDanger           = Color(0xFFC0392B);
  static const Color couleurAvertissement    = Color(0xFFE67E22);

  static const Color couleurFond             = Color(0xFFF5F6FA);
  static const Color couleurSurface          = Color(0xFFEEF1FB);
  static const Color couleurTexte            = Color(0xFF2C3E50);
  static const Color couleurTexteSecondaire  = Color(0xFF7F8C8D);
  static const Color couleurBordure          = Color(0xFFDDE1EA);

  static const Color blanc                   = Color(0xFFFFFFFF);
  static const Color dotActif                = couleurPrimaire;
  static const Color dotInactif              = Color(0xFFD1D5DB);

  // ─── LOGIQUE DE SCORE ───────────────────────────────────────────

  static Color couleurSelonScore(int score) {
    if (score >= 70) return couleurDanger;
    if (score >= 40) return couleurAvertissement;
    return couleurSecondaire;
  }

  // ─── STYLES DE TEXTE ────────────────────────────────────────────

  static TextStyle get titrePrincipal => GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: couleurTexte,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static TextStyle get titreSecondaire => GoogleFonts.montserrat(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    color: couleurTexteSecondaire,
    height: 1.4,
  );

  static TextStyle get corpsMedium => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: couleurTexteSecondaire,
    height: 1.6,
  );

  static TextStyle get legende => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: couleurTexteSecondaire,
    height: 1.5,
  );

  static TextStyle get labelBouton => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: blanc,
    letterSpacing: 0.2,
  );

  static TextStyle get labelSecondaire => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: couleurTexteSecondaire,
  );

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
        foregroundColor: blanc,
        elevation: 0,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: couleurPrimaire,
          foregroundColor: blanc,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
        fillColor: blanc,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: couleurTexteSecondaire),
      ),

      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 6),
      ),
    );
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
}