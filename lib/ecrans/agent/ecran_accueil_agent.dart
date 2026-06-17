// -----------------------------------------------------------------
// Écran Accueil Agent — TerangaSkills
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../configuration/theme.dart';
import '../../widgets/widget_barre_navigation.dart';
import '../../widgets/widget_carte_signalement.dart';
import '../../widgets/widget_entete_agent.dart';
import '../../configuration/routes.dart';
import '../../providers/provider_signalements.dart';
import 'ecran_mes_signalements.dart';

class EcranAccueilAgent extends StatefulWidget {
  const EcranAccueilAgent({super.key});

  @override
  State<EcranAccueilAgent> createState() => _EcranAccueilAgentState();
}

class _EcranAccueilAgentState extends State<EcranAccueilAgent> {
  int _indexNav = 0;

  static const double _hauteurHeaderExpanded  = 140.0;
  static const double _hauteurHeaderCollapsed = 70.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: ThemeApplication.couleurFond,
      extendBody: true,

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── SliverAppBar : header qui se réduit ───────────────
          const SliverAppBar(
            expandedHeight: _hauteurHeaderExpanded,
            collapsedHeight: _hauteurHeaderCollapsed,
            pinned: true,
            stretch: false,
            backgroundColor: ThemeApplication.couleurPrimaire,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: EnteteAgent(),
            ),
          ),

          // ── Contenu scrollable ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                const _CarteScan(),
                const SizedBox(height: 20),

                const _ActionsRapides(),
                const SizedBox(height: 28),

                // ── Section activités récentes ───────────────────
                _SectionActivites(),
              ]),
            ),
          ),
        ],
      ),

      // ── WidgetBarreNavigation ─────────────────────────────────
      bottomNavigationBar: WidgetBarreNavigation(
        indexCourant: _indexNav,
        onTap: (i) => setState(() => _indexNav = i),
        onScanTap: () {
          Navigator.pushNamed(context, Routes.cameraDocument);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CARTE SCANNER
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
              child: const Icon(
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

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.cameraDocument);
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
                  const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Lancer le scan', style: ThemeApplication.labelBouton),
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
    final provider = Provider.of<ProviderSignalements>(context);
    final nbHorsLigne = provider.fileAttenteHorsLigne.length;

    return Row(
      children: [
        Expanded(
          child: _CarteAction(
            icone: Icons.list_alt_outlined,
            couleurFondIcone: const Color(0x1400677E),
            label: 'Mes signalements',
            onTap: () {
              Navigator.pushNamed(context, Routes.mesSignalements);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CarteAction(
            icone: Icons.sync_rounded,
            couleurFondIcone: const Color(0x14742F00),
            label: 'Sync',
            badge: nbHorsLigne > 0 ? nbHorsLigne.toString() : null,
            onTap: () {
              Navigator.pushNamed(context, Routes.synchronisation);
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
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        color: ThemeApplication.couleurPrimaire,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SECTION ACTIVITÉS — utilise WidgetCarteSignalement
// ─────────────────────────────────────────────────────────────────
class _SectionActivites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderSignalements>(context);
    
    // Combiner les signalements récents (max 4)
    final activites = provider.signalements.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── En-tête section ─────────────────────────────────────
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
              onTap: () => Navigator.pushNamed(context, Routes.mesSignalements),
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

        // ── Liste avec WidgetCarteSignalement ────────────────────
        if (provider.chargement && activites.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (activites.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Aucune activité récente',
                style: ThemeApplication.corpsMedium,
              ),
            ),
          )
        else
          ...List.generate(
            activites.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WidgetCarteSignalement(
                signalement: activites[i],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EcranDetailSignalement(signalement: activites[i]),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

