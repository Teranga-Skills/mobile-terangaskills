// lib/configuration/theme.dart
// -----------------------------------------------------------------
// Thème global de l'application DetectSen (TerangaSkills)
// Centralise les couleurs, polices et styles Material 3
// -----------------------------------------------------------------

import 'package:flutter/material.dart';

class ThemeApplication {

  // ─── PALETTE DE COULEURS "DetectSen" ────────────────────────────

  // Couleur principale : bleu vif, identité de marque (écran d'accueil,
  // boutons principaux, éléments mis en avant)
  static const Color couleurPrimaire = Color(0xFF5780FA);

  // Couleur de fond sombre : utilisée pour les écrans d'onboarding
  // et potentiellement un mode "sombre" du dashboard
  static const Color couleurFondSombre = Color(0xFF12202F);

  // Couleur secondaire : vert, pour les actions positives
  // (validation d'un signalement, succès de synchronisation)
  static const Color couleurSecondaire = Color(0xFF1E8449);

  // Couleurs d'alerte : utilisées pour les scores de risque IA
  static const Color couleurDanger = Color(0xFFC0392B);
  static const Color couleurAvertissement = Color(0xFFE67E22);

  // Couleurs neutres (écrans clairs : formulaires, dashboard)
  static const Color couleurFond = Color(0xFFF5F6FA);
  static const Color couleurTexte = Color(0xFF2C3E50);
  static const Color couleurTexteSecondaire = Color(0xFF7F8C8D);

  // -----------------------------------------------------------------
  // Couleur associée à un niveau de score de risque
  // -----------------------------------------------------------------
  static Color couleurSelonScore(int score) {
    if (score >= 70) return couleurDanger;
    if (score >= 40) return couleurAvertissement;
    return couleurSecondaire;
  }

  // ─── NOM DE LA POLICE (Montserrat) ──────────────────────────────
  // Doit correspondre exactement au nom déclaré dans pubspec.yaml
  static const String policePrincipale = 'Montserrat';

  // ─── THÈME SOMBRE (écrans d'onboarding / accueil) ───────────────
  static ThemeData get themeSombre {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: couleurFondSombre,
      fontFamily: policePrincipale,
      colorScheme: ColorScheme.fromSeed(
        seedColor: couleurPrimaire,
        brightness: Brightness.dark,
      ),
    );
  }

  // ─── THÈME CLAIR (Material 3 - formulaires, dashboard) ──────────
  static ThemeData get themeClair {
    return ThemeData(
      useMaterial3: true,
      fontFamily: policePrincipale,
      scaffoldBackgroundColor: couleurFond,

      colorScheme: ColorScheme.fromSeed(
        seedColor: couleurPrimaire,
        primary: couleurPrimaire,
        secondary: couleurSecondaire,
        error: couleurDanger,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: couleurPrimaire,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: policePrincipale,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: couleurPrimaire,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: policePrincipale,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: couleurTexteSecondaire),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: couleurTexte,
          fontFamily: policePrincipale,
        ),
        bodyMedium: TextStyle(
          color: couleurTexte,
          fontSize: 15,
        ),
        bodySmall: TextStyle(
          color: couleurTexteSecondaire,
          fontSize: 13,
        ),
      ),
    );
  }
}

