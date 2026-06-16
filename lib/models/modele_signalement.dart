// -----------------------------------------------------------------
// Modèle : Signalement
// -----------------------------------------------------------------

import 'package:flutter/material.dart';

enum StatutSignalement {
  synchronise,
  enCours,
  horsLigne,
  erreur;

  String get libelle {
    switch (this) {
      case StatutSignalement.synchronise: return 'SYNCHRONISÉ';
      case StatutSignalement.enCours:     return 'EN COURS';
      case StatutSignalement.horsLigne:   return 'HORS-LIGNE';
      case StatutSignalement.erreur:      return 'ERREUR';
    }
  }

  Color get couleurFond {
    switch (this) {
      case StatutSignalement.synchronise: return const Color(0xFFDCFCE7);
      case StatutSignalement.enCours:     return const Color(0xFFDBEAFE);
      case StatutSignalement.horsLigne:   return const Color(0xFFEEEEF0);
      case StatutSignalement.erreur:      return const Color(0xFFFFE4E4);
    }
  }

  Color get couleurTexte {
    switch (this) {
      case StatutSignalement.synchronise: return const Color(0xFF15803D);
      case StatutSignalement.enCours:     return const Color(0xFF1D4ED8);
      case StatutSignalement.horsLigne:   return const Color(0xFF464554);
      case StatutSignalement.erreur:      return const Color(0xFFC0392B);
    }
  }
}

class ModeleSignalement {
  final String id;
  final String nom;
  final String typeDocument;
  final String lieu;
  final String date;
  final StatutSignalement statut;
  final String? numeroDocument;
  final String? dateNaissance;
  final String? nationalite;
  final String? noteAgent;

  const ModeleSignalement({
    required this.id,
    required this.nom,
    required this.typeDocument,
    required this.lieu,
    required this.date,
    required this.statut,
    this.numeroDocument,
    this.dateNaissance,
    this.nationalite,
    this.noteAgent,
  });

  String get initiales {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom.substring(0, 2).toUpperCase();
  }
}