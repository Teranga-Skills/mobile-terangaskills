// -----------------------------------------------------------------
// Widget : Carte signalement réutilisable
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import '../configuration/theme.dart';
import '../models/modele_signalement.dart';

class WidgetCarteSignalement extends StatelessWidget {
  final ModeleSignalement signalement;
  final VoidCallback onTap;

  const WidgetCarteSignalement({
    super.key,
    required this.signalement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeApplication.blanc,
          borderRadius: BorderRadius.circular(20),
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
          children: [
            // ── Avatar initiales ──────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ThemeApplication.couleurPrimaire.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  signalement.initiales,
                  style: TextStyle(
                    color: ThemeApplication.couleurPrimaire,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Infos ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signalement.nom,
                    style: ThemeApplication.corpsMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${signalement.typeDocument} • ${signalement.lieu}',
                    style: ThemeApplication.legende.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF464554),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    signalement.date,
                    style: ThemeApplication.legende.copyWith(
                      fontSize: 11,
                      color: ThemeApplication.couleurTexteSecondaire,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Badge statut ─────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _BadgeStatut(statut: signalement.statut),
                const SizedBox(height: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFFCBCBCB),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  final StatutSignalement statut;

  const _BadgeStatut({required this.statut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statut.couleurFond,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        statut.libelle,
        style: TextStyle(
          color: statut.couleurTexte,
          fontSize: 10,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

