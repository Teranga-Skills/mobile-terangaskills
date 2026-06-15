// -----------------------------------------------------------------
// Widgets spécifiques à l'écran d'onboarding
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../configuration/theme.dart';

// ─── Carte illustration ──────────────────────────────────────────

class CarteIllustration extends StatelessWidget {
  final Color couleur;
  final IconData icone;

  const CarteIllustration({
    super.key,
    required this.couleur,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Icon(
        icone,
        size: 96,
        color: couleur.computeLuminance() > 0.5
            ? ThemeApplication.couleurPrimaire.withOpacity(0.8)
            : ThemeApplication.blanc,
      ),
    );
  }
}

// ─── Note informative ────────────────────────────────────────────

class CarteNote extends StatelessWidget {
  final String texte;

  const CarteNote({super.key, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeApplication.couleurSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeApplication.couleurBordure),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: ThemeApplication.couleurPrimaire,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texte, style: ThemeApplication.legende),
          ),
        ],
      ),
    );
  }
}

// ─── Indicateurs de progression (dots) ──────────────────────────

class IndicateursDots extends StatelessWidget {
  final int indexCourant;
  final int total;

  const IndicateursDots({
    super.key,
    required this.indexCourant,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final estActif = index == indexCourant;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6),
          width: estActif ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: estActif
                ? ThemeApplication.dotActif
                : ThemeApplication.dotInactif,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

// ─── Bouton icône circulaire ─────────────────────────────────────

class BoutonIconeCirculaire extends StatelessWidget {
  final IconData icone;
  final VoidCallback onTap;

  const BoutonIconeCirculaire({
    super.key,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: ThemeApplication.couleurSurface,
          shape: BoxShape.circle,
          border: Border.all(color: ThemeApplication.couleurBordure),
        ),
        child: Icon(
          icone,
          size: 18,
          color: ThemeApplication.couleurTexte,
        ),
      ),
    );
  }
}