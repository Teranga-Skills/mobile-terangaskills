// -----------------------------------------------------------------
// Widget : Carte d'activité / signalement réutilisable
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import '../configuration/theme.dart';

class DonneesActivite {
  final String nom;
  final String info;
  final String statut;
  final Color couleurFond;
  final Color couleurTexte;

  const DonneesActivite({
    required this.nom,
    required this.info,
    required this.statut,
    required this.couleurFond,
    required this.couleurTexte,
  });
}

class WidgetCarteActivite extends StatelessWidget {
  final DonneesActivite donnees;

  const WidgetCarteActivite({
    super.key,
    required this.donnees,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeApplication.blanc,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Avatar + infos ──────────────────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEF0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 24,
                  color: Color(0xFF464554),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donnees.nom,
                    style: ThemeApplication.corpsMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    donnees.info,
                    style: ThemeApplication.legende.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF464554),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Badge statut ────────────────────────────────────
          _BadgeStatut(
            statut: donnees.statut,
            couleurFond: donnees.couleurFond,
            couleurTexte: donnees.couleurTexte,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Badge statut (SYNCHRONISÉ / EN COURS / HORS-LIGNE)
// ─────────────────────────────────────────────────────────────────
class _BadgeStatut extends StatelessWidget {
  final String statut;
  final Color couleurFond;
  final Color couleurTexte;

  const _BadgeStatut({
    required this.statut,
    required this.couleurFond,
    required this.couleurTexte,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: couleurFond,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        statut,
        style: TextStyle(
          color: couleurTexte,
          fontSize: 10,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

