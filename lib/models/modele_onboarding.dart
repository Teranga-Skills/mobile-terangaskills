// -----------------------------------------------------------------
// Modèle de données pour une page d'onboarding
// -----------------------------------------------------------------

import 'package:flutter/material.dart';

class ModelePageOnboarding {
  final String titre;
  final String sousTitre;
  final String? note;
  final Color couleurIllustration;
  final IconData iconeIllustration;

  const ModelePageOnboarding({
    required this.titre,
    required this.sousTitre,
    this.note,
    required this.couleurIllustration,
    required this.iconeIllustration,
  });
}

// ─── Contenu des 3 écrans ───────────────────────────────────────

const List<ModelePageOnboarding> pagesOnboarding = [
  ModelePageOnboarding(
    titre: 'Gardiens de\nl\'identité nationale',
    sousTitre: 'Protéger l\'état civil sénégalais',
    note:
        'Vous êtes en première ligne pour défendre chaque citoyen contre la fraude documentaire.',
    couleurIllustration: Color(0xFFE8F0FE),
    iconeIllustration: Icons.shield_outlined,
  ),
  ModelePageOnboarding(
    titre: 'Simple.\nRapide.\nIntelligent.',
    sousTitre: 'L\'IA analyse, vous décidez',
    note:
        'Pas de réseau ? Aucun problème. Vos signalements sont sauvegardés et synchronisés dès que la connexion revient.',
    couleurIllustration: Color(0xFFE6F4EA),
    iconeIllustration: Icons.document_scanner_outlined,
  ),
  ModelePageOnboarding(
    titre: 'Votre mission\ncommence ici',
    sousTitre: 'Connectez-vous pour accéder à votre espace agent',
    note:
        'Vos données sont chiffrées. Chaque action est tracée dans un journal d\'audit sécurisé.',
    couleurIllustration: Color(0xFFFCE8E6),
    iconeIllustration: Icons.verified_user_outlined,
  ),
];