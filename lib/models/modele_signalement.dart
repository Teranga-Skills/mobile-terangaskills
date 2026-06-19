// -----------------------------------------------------------------
// Modèle : Signalement
// -----------------------------------------------------------------

import 'package:flutter/material.dart';

enum StatutSignalement {
  synchronise,
  enCours,
  horsLigne,
  erreur,
  suspect,
  fraude;

  String get libelle {
    switch (this) {
      case StatutSignalement.synchronise: return 'SYNCHRONISÉ';
      case StatutSignalement.enCours:     return 'EN COURS';
      case StatutSignalement.horsLigne:   return 'HORS-LIGNE';
      case StatutSignalement.erreur:      return 'ERREUR';
      case StatutSignalement.suspect:     return 'SUSPECT';
      case StatutSignalement.fraude:      return 'FRAUDE';
    }
  }

  Color get couleurFond {
    switch (this) {
      case StatutSignalement.synchronise: return const Color(0xFFDCFCE7);
      case StatutSignalement.enCours:     return const Color(0xFFDBEAFE);
      case StatutSignalement.horsLigne:   return const Color(0xFFEEEEF0);
      case StatutSignalement.erreur:      return const Color(0xFFFFE4E4);
      case StatutSignalement.suspect:     return const Color(0xFFFEF3C7);
      case StatutSignalement.fraude:      return const Color(0xFFFFE4E4);
    }
  }

  Color get couleurTexte {
    switch (this) {
      case StatutSignalement.synchronise: return const Color(0xFF15803D);
      case StatutSignalement.enCours:     return const Color(0xFF1D4ED8);
      case StatutSignalement.horsLigne:   return const Color(0xFF464554);
      case StatutSignalement.erreur:      return const Color(0xFFC0392B);
      case StatutSignalement.suspect:     return const Color(0xFFD97706);
      case StatutSignalement.fraude:      return const Color(0xFFDC2626);
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
  final String? cheminImage;
  
  // Nouveaux champs pour la gestion de la fraude & comparaison
  final String? decision;
  final int? fraudScore;
  final String? originalNom;
  final String? originalPrenom;
  final String? originalNumero;
  final String? originalDateNaissance;

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
    this.cheminImage,
    this.decision,
    this.fraudScore,
    this.originalNom,
    this.originalPrenom,
    this.originalNumero,
    this.originalDateNaissance,
  });

  String get initiales {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom.isNotEmpty ? nom.substring(0, nom.length >= 2 ? 2 : 1).toUpperCase() : '??';
  }
}

