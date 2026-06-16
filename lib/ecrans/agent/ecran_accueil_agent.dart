import 'package:flutter/material.dart';
import '../../configuration/theme.dart';
// import '../../configuration/routes.dart';

class AcceuilAgent extends StatelessWidget {
  const AcceuilAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApplication.couleurFond,
      body: Column(
        children: [
          // ── HEADER BLEU ──────────────────────────────────────────
          _EnteteAgent(),

          // ── CONTENU SCROLLABLE ───────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Carte Scanner ────────────────────────────────
                  _CarteScan(),

                  const SizedBox(height: 24),

                  // ── Actions rapides ──────────────────────────────
                  _ActionsRapides(),

                  const SizedBox(height: 24),

                  // ── Activités récentes ───────────────────────────
                  _SectionActivites(),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── BOTTOM NAV BAR ───────────────────────────────────────────
      bottomNavigationBar: _BarreNavigation(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ENTÊTE
// ─────────────────────────────────────────────────────────────────
class _EnteteAgent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ThemeApplication.couleurPrimaire,
      padding: const EdgeInsets.only(
        top: 56,
        left: 20,
        right: 20,
        bottom: 64,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar + nom
          Row(
            spacing: 12,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2, color: Color(0xFFE1E0FF)),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://placehold.co/48x48',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, Moussa',
                    style: ThemeApplication.titrePrincipal.copyWith(
                      fontSize: 20,
                      color: const Color(0xFFD0D0FF),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    spacing: 4,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xFFD0D0FF),
                      ),
                      Text(
                        'Dakar-Plateau',
                        style: ThemeApplication.legende.copyWith(
                          color: const Color(0xFFD0D0FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Bouton notif
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x19D0D0FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CARTE SCANNER
// ─────────────────────────────────────────────────────────────────
class _CarteScan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: ThemeApplication.blanc,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x264749CD),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0x0C2D2DB5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.document_scanner_outlined,
              size: 40,
              color: ThemeApplication.couleurPrimaire,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Scanner un document',
            textAlign: TextAlign.center,
            style: ThemeApplication.titrePrincipal.copyWith(
              fontSize: 24,
              color: const Color(0xFF1A1C1E),
              letterSpacing: -0.24,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'L\'IA extrait et analyse les\ninformations clés en quelques secondes.',
            textAlign: TextAlign.center,
            style: ThemeApplication.corpsMedium.copyWith(
              color: const Color(0xFF464554),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 32),

          // Bouton Lancer le scan
          GestureDetector(
            onTap: () {
              // TODO : navigation vers caméra
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: ShapeDecoration(
                color: ThemeApplication.couleurPrimaire,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x664749CD),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  Text(
                    'Lancer le scan',
                    style: ThemeApplication.labelBouton,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACTIONS RAPIDES (Mes signalements + Sync)
// ─────────────────────────────────────────────────────────────────
class _ActionsRapides extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: _CarteAction(
            icone: Icons.list_alt_outlined,
            couleurFondIcone: const Color(0x1900677E),
            label: 'Mes signalements',
            onTap: () {
              // TODO : navigation
            },
          ),
        ),
        Expanded(
          child: _CarteAction(
            icone: Icons.sync,
            couleurFondIcone: const Color(0x19742F00),
            label: 'Sync',
            badge: '2',
            onTap: () {
              // TODO : synchronisation
            },
          ),
        ),
      ],
    );
  }
}

class _CarteAction extends StatelessWidget {
  final IconData icone;
  final Color couleurFondIcone;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _CarteAction({
    required this.icone,
    required this.couleurFondIcone,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: ShapeDecoration(
          color: ThemeApplication.blanc,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: ThemeApplication.couleurBordure.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: couleurFondIcone,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icone, size: 20, color: ThemeApplication.couleurTexte),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: ThemeApplication.labelSecondaire.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
              ],
            ),

            // Badge rouge
            if (badge != null)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: ShapeDecoration(
                    color: ThemeApplication.couleurDanger,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SECTION ACTIVITÉS RÉCENTES
// ─────────────────────────────────────────────────────────────────
class _SectionActivites extends StatelessWidget {
  final List<Map<String, dynamic>> _activites = const [
    {
      'nom': 'Moussa Diop',
      'info': 'Il y a 10 min • Dakar',
      'statut': 'SYNCHRONISÉ',
      'couleurFond': Color(0xFFDCFCE7),
      'couleurTexte': Color(0xFF15803D),
    },
    {
      'nom': 'Fatou Ndiaye',
      'info': 'Il y a 45 min • Thiès',
      'statut': 'EN COURS',
      'couleurFond': Color(0xFFDBEAFE),
      'couleurTexte': Color(0xFF1D4ED8),
    },
    {
      'nom': 'Amadou Fall',
      'info': 'Hier, 18:24 • Saint-Louis',
      'statut': 'HORS-LIGNE',
      'couleurFond': Color(0xFFEEEEF0),
      'couleurTexte': Color(0xFF464554),
    },
    {
      'nom': 'Khady Seck',
      'info': 'Hier, 15:10 • Kaolack',
      'statut': 'SYNCHRONISÉ',
      'couleurFond': Color(0xFFDCFCE7),
      'couleurTexte': Color(0xFF15803D),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre + Voir tout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activités Récentes',
              style: ThemeApplication.titrePrincipal.copyWith(
                fontSize: 20,
                color: const Color(0xFF1A1C1E),
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO : voir tout
              },
              child: Text(
                'Voir tout',
                style: ThemeApplication.labelSecondaire.copyWith(
                  color: const Color(0xFF2D2DB5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Liste
        Column(
          spacing: 12,
          children: _activites
              .map((a) => _CarteActivite(
                    nom: a['nom'],
                    info: a['info'],
                    statut: a['statut'],
                    couleurFondBadge: a['couleurFond'],
                    couleurTexteBadge: a['couleurTexte'],
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _CarteActivite extends StatelessWidget {
  final String nom;
  final String info;
  final String statut;
  final Color couleurFondBadge;
  final Color couleurTexteBadge;

  const _CarteActivite({
    required this.nom,
    required this.info,
    required this.statut,
    required this.couleurFondBadge,
    required this.couleurTexteBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: ThemeApplication.blanc,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar + infos
          Row(
            spacing: 12,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: ThemeApplication.corpsMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info,
                    style: ThemeApplication.legende.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF464554),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: ShapeDecoration(
              color: couleurFondBadge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Text(
              statut,
              style: TextStyle(
                color: couleurTexteBadge,
                fontSize: 11,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BOTTOM NAVIGATION BAR
// ─────────────────────────────────────────────────────────────────
class _BarreNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 52,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ItemNav(
                icone: Icons.home_outlined,
                iconeActif: Icons.home,
                label: 'Home',
                estActif: true,
              ),
              _ItemNav(
                icone: Icons.contacts_outlined,
                label: 'Contact',
              ),

              // Bouton central scan
              GestureDetector(
                onTap: () {
                  // TODO : navigation caméra
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: ShapeDecoration(
                    color: ThemeApplication.couleurPrimaire,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x664749CD),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),

              _ItemNav(
                icone: Icons.notifications_outlined,
                label: 'Notifications',
              ),
              _ItemNav(
                icone: Icons.settings_outlined,
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNav extends StatelessWidget {
  final IconData icone;
  final IconData? iconeActif;
  final String label;
  final bool estActif;

  const _ItemNav({
    required this.icone,
    required this.label,
    this.iconeActif,
    this.estActif = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        Icon(
          estActif ? (iconeActif ?? icone) : icone,
          size: 24,
          color: estActif
              ? ThemeApplication.couleurPrimaire
              : const Color(0xFF888888),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Montserrat',
            fontWeight: estActif ? FontWeight.w600 : FontWeight.w400,
            color: estActif
                ? ThemeApplication.couleurPrimaire
                : const Color(0xFF888888),
            letterSpacing: 0.12,
          ),
        ),
      ],
    );
  }
}

