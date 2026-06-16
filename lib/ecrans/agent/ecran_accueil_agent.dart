// -----------------------------------------------------------------
// Écran Accueil Agent — TerangaSkills
//
// Comportement scroll :
//   • Header bleu (avatar + nom + zone) → se réduit au scroll
//   • SliverAppBar pinned : garde une top bar compacte visible
//   • Carte Scan, Actions rapides, Activités restent scrollables
//   • BottomNav fixe avec bouton scan central surélevé
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../configuration/theme.dart';

class EcranAccueilAgent extends StatefulWidget {
  const EcranAccueilAgent({super.key});

  @override
  State<EcranAccueilAgent> createState() => _EcranAccueilAgentState();
}

class _EcranAccueilAgentState extends State<EcranAccueilAgent> {
  int _indexNav = 0;

  // ─── Hauteur du header expanded ─────────────────────────────────
  static const double _hauteurHeaderExpanded = 140.0;
  static const double _hauteurHeaderCollapsed = 70.0;

  @override
  Widget build(BuildContext context) {
    // Barre de statut blanche sur fond bleu
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: ThemeApplication.couleurFond,
      extendBody: true, // le contenu passe sous la bottom nav (effet glassmorphism)

      // ── BODY : CustomScrollView avec Slivers ──────────────────────
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── SliverAppBar : header qui se réduit ───────────────────
          SliverAppBar(
          expandedHeight: _hauteurHeaderExpanded,
          collapsedHeight: _hauteurHeaderCollapsed,
          pinned: true,
          stretch: false,
          backgroundColor: ThemeApplication.couleurPrimaire,
          elevation: 0,
          automaticallyImplyLeading: false,

          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: _EnteteAgent(),
          ),
        ),

          // ── Contenu scrollable ────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Carte Scanner hero
                const _CarteScan(),
                const SizedBox(height: 20),

                // Actions rapides
                const _ActionsRapides(),
                const SizedBox(height: 28),

                // Activités récentes
                const _SectionActivites(),
              ]),
            ),
          ),
        ],
      ),

      // ── BOTTOM NAV FIXE ──────────────────────────────────────────
      bottomNavigationBar: _BarreNavigation(
        indexCourant: _indexNav,
        onTap: (i) => setState(() => _indexNav = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ENTÊTE EXPANDED
// ─────────────────────────────────────────────────────────────────

class _EnteteAgent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: ThemeApplication.couleurPrimaire,
      padding: EdgeInsets.only(
        top: topPadding + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar + nom + zone
          Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://i.pravatar.cc/52',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF4060D0),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bonjour, Moussa',
                    style: ThemeApplication.titrePrincipal.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xCCD0D0FF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Dakar-Plateau',
                        style: ThemeApplication.legende.copyWith(
                          color: const Color(0xCCD0D0FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Bouton notification
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                // Badge notification
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4757),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ENTÊTE COLLAPSED (visible après scroll)
// ─────────────────────────────────────────────────────────────────

class _EnteteCollapsed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Mini avatar + nom compact
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://i.pravatar.cc/34',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF4060D0),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Moussa · Dakar-Plateau',
                  style: ThemeApplication.corpsMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // Notif
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CARTE SCANNER HERO
// ─────────────────────────────────────────────────────────────────

class _CarteScan extends StatefulWidget {
  const _CarteScan();

  @override
  State<_CarteScan> createState() => _CarteScanState();
}

class _CarteScanState extends State<_CarteScan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: ThemeApplication.blanc,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x264749CD),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône avec animation pulsation
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: ThemeApplication.couleurPrimaire.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 42,
                color: ThemeApplication.couleurPrimaire,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Scanner un document',
            textAlign: TextAlign.center,
            style: ThemeApplication.titrePrincipal.copyWith(
              fontSize: 22,
              color: const Color(0xFF1A1C1E),
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'L\'IA extrait et analyse les\ninformations clés en quelques secondes.',
            textAlign: TextAlign.center,
            style: ThemeApplication.corpsMedium.copyWith(
              color: const Color(0xFF464554),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // Bouton Lancer le scan
          GestureDetector(
            onTap: () {
              // TODO : Navigator.pushNamed(context, Routes.cameraDocument)
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: ThemeApplication.couleurPrimaire,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x664749CD),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
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
// ACTIONS RAPIDES
// ─────────────────────────────────────────────────────────────────

class _ActionsRapides extends StatelessWidget {
  const _ActionsRapides();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CarteAction(
            icone: Icons.list_alt_outlined,
            couleurFondIcone: const Color(0x1400677E),
            label: 'Mes signalements',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CarteAction(
            icone: Icons.sync_rounded,
            couleurFondIcone: const Color(0x14742F00),
            label: 'Sync',
            badge: '2',
            onTap: () {},
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
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: ThemeApplication.blanc,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ThemeApplication.couleurBordure.withOpacity(0.3),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 4,
              offset: Offset(0, 2),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: couleurFondIcone,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icone,
                    size: 22,
                    color: ThemeApplication.couleurTexte,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: ThemeApplication.labelSecondaire.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF1A1C1E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Badge
            if (badge != null)
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: ThemeApplication.couleurDanger,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: Colors.white, width: 2),
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
  const _SectionActivites();

  static const _activites = [
    _DonneesActivite(
      nom: 'Moussa Diop',
      info: 'Il y a 10 min • Dakar',
      statut: 'SYNCHRONISÉ',
      couleurFond: Color(0xFFDCFCE7),
      couleurTexte: Color(0xFF15803D),
    ),
    _DonneesActivite(
      nom: 'Fatou Ndiaye',
      info: 'Il y a 45 min • Thiès',
      statut: 'EN COURS',
      couleurFond: Color(0xFFDBEAFE),
      couleurTexte: Color(0xFF1D4ED8),
    ),
    _DonneesActivite(
      nom: 'Amadou Fall',
      info: 'Hier, 18:24 • Saint-Louis',
      statut: 'HORS-LIGNE',
      couleurFond: Color(0xFFEEEEF0),
      couleurTexte: Color(0xFF464554),
    ),
    _DonneesActivite(
      nom: 'Khady Seck',
      info: 'Hier, 15:10 • Kaolack',
      statut: 'SYNCHRONISÉ',
      couleurFond: Color(0xFFDCFCE7),
      couleurTexte: Color(0xFF15803D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activités Récentes',
              style: ThemeApplication.titrePrincipal.copyWith(
                fontSize: 18,
                color: const Color(0xFF1A1C1E),
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Voir tout',
                style: ThemeApplication.labelSecondaire.copyWith(
                  color: ThemeApplication.couleurPrimaire,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Liste des activités
        ...List.generate(
          _activites.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CarteActivite(donnees: _activites[i]),
          ),
        ),
      ],
    );
  }
}

// Modèle de données local (immuable)
class _DonneesActivite {
  final String nom;
  final String info;
  final String statut;
  final Color couleurFond;
  final Color couleurTexte;

  const _DonneesActivite({
    required this.nom,
    required this.info,
    required this.statut,
    required this.couleurFond,
    required this.couleurTexte,
  });
}

class _CarteActivite extends StatelessWidget {
  final _DonneesActivite donnees;

  const _CarteActivite({required this.donnees});

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
          // Avatar + infos
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

          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: donnees.couleurFond,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              donnees.statut,
              style: TextStyle(
                color: donnees.couleurTexte,
                fontSize: 10,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BOTTOM NAVIGATION BAR FIXE
// ─────────────────────────────────────────────────────────────────

class _BarreNavigation extends StatelessWidget {
  final int indexCourant;
  final ValueChanged<int> onTap;

  const _BarreNavigation({
    required this.indexCourant,
    required this.onTap,
  });

  static const _items = [
    _ItemNavData(icone: Icons.home_outlined, iconeActif: Icons.home_rounded, label: 'Home'),
    _ItemNavData(icone: Icons.contacts_outlined, iconeActif: Icons.contacts_rounded, label: 'Contacts'),
    _ItemNavData(icone: Icons.notifications_outlined, iconeActif: Icons.notifications_rounded, label: 'Notifs'),
    _ItemNavData(icone: Icons.settings_outlined, iconeActif: Icons.settings_rounded, label: 'Réglages'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Item 0 - Home
              _buildItem(0),
              // Item 1 - Contacts
              _buildItem(1),

              // ── Bouton SCAN central surélevé ─────────────────────
              GestureDetector(
                onTap: () {
                  // TODO : Navigator.pushNamed(context, Routes.cameraDocument)
                },
                child: Container(
                  width: 58,
                  height: 58,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: ThemeApplication.couleurPrimaire,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x664749CD),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),

              // Item 2 - Notifications
              _buildItem(2),
              // Item 3 - Réglages
              _buildItem(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    // Décalage d'index : 0,1 avant le scan, 2,3 pour les items après
    final itemIndex = index < 2 ? index : index + 1;
    final estActif = indexCourant == itemIndex;
    final item = _items[index];

    return GestureDetector(
      onTap: () => onTap(itemIndex),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              estActif ? item.iconeActif : item.icone,
              size: 24,
              color: estActif
                  ? ThemeApplication.couleurPrimaire
                  : const Color(0xFF888888),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Montserrat',
                fontWeight: estActif ? FontWeight.w600 : FontWeight.w400,
                color: estActif
                    ? ThemeApplication.couleurPrimaire
                    : const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemNavData {
  final IconData icone;
  final IconData iconeActif;
  final String label;

  const _ItemNavData({
    required this.icone,
    required this.iconeActif,
    required this.label,
  });
}