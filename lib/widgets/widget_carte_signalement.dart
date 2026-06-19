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
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEF0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  signalement.initiales,
                  style: TextStyle(
                    color: ThemeApplication.couleurPrimaire,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    signalement.typeDocument,
                    style: ThemeApplication.legende.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF464554),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    signalement.date,
                    style: ThemeApplication.legende.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF464554),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Badge à droite
            _BadgeStatut(statut: signalement.statut),
          ],
        ),
      ),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  final StatutSignalement statut;

  const _BadgeStatut({
    required this.statut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statut.couleurFond,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        statut.libelle.toUpperCase(),
        style: TextStyle(
          color: statut.couleurTexte,
          fontSize: 11,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.55,
        ),
      ),
    );
  }
}
