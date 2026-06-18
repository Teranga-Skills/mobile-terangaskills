// -----------------------------------------------------------------
// Pop-up : Résultat de l'analyse IA (score de fraude)
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import '../configuration/theme.dart';

class WidgetPopupScoreIa extends StatelessWidget {
  final String decision;
  final int fraudScore;
  final Map<String, dynamic>? matchedData;
  final String nomScan;
  final String? prenomScan;
  final String numeroScan;
  final String dateNaissanceScan;
  final bool chargementEnvoi;
  final VoidCallback onEnvoyer;
  final VoidCallback onTerminer;

  const WidgetPopupScoreIa({
    super.key,
    required this.decision,
    required this.fraudScore,
    this.matchedData,
    required this.nomScan,
    this.prenomScan,
    required this.numeroScan,
    required this.dateNaissanceScan,
    this.chargementEnvoi = false,
    required this.onEnvoyer,
    required this.onTerminer,
  });

  Color get _couleurDecision {
    if (decision == 'FRAUD') return ThemeApplication.couleurDanger;
    if (decision == 'SUSPECT') return ThemeApplication.couleurAvertissement;
    return ThemeApplication.couleurSecondaire;
  }

  IconData get _iconeDecision {
    if (decision == 'FRAUD') return Icons.gpp_bad_rounded;
    if (decision == 'SUSPECT') return Icons.warning_amber_rounded;
    return Icons.verified_user_rounded;
  }

  String get _labelDecision {
    if (decision == 'FRAUD') return 'FRAUDE DÉTECTÉE';
    if (decision == 'SUSPECT') return 'FRAUDE SUSPECTE';
    return 'DOCUMENT VALIDE';
  }

  String get _messageDecision {
    if (decision == 'FRAUD') {
      return 'Le numéro d\'identification extrait n\'existe pas dans les registres officiels.';
    }
    if (decision == 'SUSPECT') {
      return 'Le numéro correspond à un citoyen existant, mais le nom ou le prénom ne correspond pas.';
    }
    return 'Les données extraites sont cohérentes avec les registres officiels.';
  }

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurDecision;
    final afficherComparaison =
        matchedData != null && (decision == 'SUSPECT' || decision == 'FRAUD');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: ThemeApplication.blanc,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── En-tête ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: BoxDecoration(
                  color: couleur.withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: couleur.withOpacity(0.15),
                        border: Border.all(color: couleur, width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$fraudScore%',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: couleur,
                            ),
                          ),
                          Text(
                            'Risque',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: couleur.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_iconeDecision, color: couleur, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          _labelDecision,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: couleur,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Résultat de l\'analyse IA',
                      style: ThemeApplication.corpsMedium.copyWith(
                        fontSize: 13,
                        color: ThemeApplication.couleurTexteSecondaire,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Message ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  _messageDecision,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: Color(0xFF4A5568),
                    height: 1.5,
                  ),
                ),
              ),

              // ─── Comparaison ─────────────────────────────────────
              if (afficherComparaison) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comparaison des données',
                        style: ThemeApplication.titrePrincipal.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: ThemeApplication.couleurFond,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _ligneComparaison(
                              'Numéro ID',
                              numeroScan,
                              matchedData!['numero_identification']?.toString() ?? '',
                            ),
                            const Divider(height: 14),
                            _ligneComparaison(
                              'Nom',
                              nomScan,
                              matchedData!['nom']?.toString() ?? '',
                            ),
                            const Divider(height: 14),
                            _ligneComparaison(
                              'Prénom',
                              prenomScan ?? '',
                              matchedData!['prenom']?.toString() ?? '',
                            ),
                            const Divider(height: 14),
                            _ligneComparaison(
                              'Naissance',
                              dateNaissanceScan,
                              matchedData!['date_naissance']?.toString() ?? '',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ─── Boutons ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: chargementEnvoi ? null : onEnvoyer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeApplication.couleurSecondaire,
                          disabledBackgroundColor:
                              ThemeApplication.couleurSecondaire.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          elevation: 0,
                        ),
                        child: chargementEnvoi
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Envoyer à l\'admin',
                                    style: ThemeApplication.labelBouton.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: chargementEnvoi ? null : onTerminer,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ThemeApplication.couleurPrimaire),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                        child: Text(
                          'Terminer',
                          style: ThemeApplication.labelBouton.copyWith(
                            color: ThemeApplication.couleurPrimaire,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ligneComparaison(String champ, String scan, String base) {
    final diff = scan.trim().toLowerCase() != base.trim().toLowerCase();
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            champ,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Scanné', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(
                scan.isEmpty ? '—' : scan,
                style: TextStyle(
                  fontSize: 12,
                  color: diff ? ThemeApplication.couleurDanger : Colors.black87,
                  fontWeight: diff ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Base SQL', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(
                base.isEmpty ? '—' : base,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
