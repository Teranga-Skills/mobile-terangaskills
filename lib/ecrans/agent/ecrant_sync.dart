// -----------------------------------------------------------------
// Écran : Synchronisation Agent
// File d'attente hors-ligne + progression + actions
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../configuration/theme.dart';
import '../../widgets/widget_barre_navigation.dart';

// ─── Modèle local ────────────────────────────────────────────────

enum StatutSync { enAttente, enCours, succes, erreur }

class _DocumentSync {
  final String id;
  final String typeDocument;
  final String date;
  final String lieu;
  final StatutSync statut;
  final String? imageUrl;

  const _DocumentSync({
    required this.id,
    required this.typeDocument,
    required this.date,
    required this.lieu,
    required this.statut,
    this.imageUrl,
  });

  String get libelle {
    switch (statut) {
      case StatutSync.enAttente: return 'EN ATTENTE';
      case StatutSync.enCours:   return 'EN COURS';
      case StatutSync.succes:    return 'SYNCHRONISÉ';
      case StatutSync.erreur:    return 'ERREUR';
    }
  }

  Color get couleurFond {
    switch (statut) {
      case StatutSync.enAttente: return const Color(0xFFFFDBCB);
      case StatutSync.enCours:   return const Color(0xFFDBEAFE);
      case StatutSync.succes:    return const Color(0xFFDCFCE7);
      case StatutSync.erreur:    return const Color(0xFFFFE4E4);
    }
  }

  Color get couleurTexte {
    switch (statut) {
      case StatutSync.enAttente: return const Color(0xFF341100);
      case StatutSync.enCours:   return const Color(0xFF1D4ED8);
      case StatutSync.succes:    return const Color(0xFF15803D);
      case StatutSync.erreur:    return const Color(0xFFC0392B);
    }
  }
}

// ─── Données mock ─────────────────────────────────────────────────

const _documentsEnAttente = [
  _DocumentSync(
    id: '001',
    typeDocument: 'Extrait de Naissance',
    date: '18 Mai 2024 • 14:22',
    lieu: 'Mairie de Dakar Plateau',
    statut: StatutSync.enAttente,
  ),
  _DocumentSync(
    id: '002',
    typeDocument: 'Casier Judiciaire',
    date: '18 Mai 2024 • 10:45',
    lieu: 'Tribunal de Saint-Louis',
    statut: StatutSync.enAttente,
  ),
  _DocumentSync(
    id: '003',
    typeDocument: 'Certificat de Résidence',
    date: '17 Mai 2024 • 16:30',
    lieu: 'Commissariat Central de Thiès',
    statut: StatutSync.enAttente,
  ),
];

// ─────────────────────────────────────────────────────────────────
// ÉCRAN PRINCIPAL
// ─────────────────────────────────────────────────────────────────

class EcranSynchronisation extends StatefulWidget {
  const EcranSynchronisation({super.key});

  @override
  State<EcranSynchronisation> createState() => _EcranSynchronisationState();
}

class _EcranSynchronisationState extends State<EcranSynchronisation>
    with SingleTickerProviderStateMixin {
  int _indexNav = 2; // onglet Sync actif
  bool _syncEnCours = false;
  double _progression = 0.0;

  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  // ── Lancer la synchronisation (simulation) ───────────────────────
  Future<void> _lancerSync() async {
    setState(() {
      _syncEnCours = true;
      _progression = 0.0;
    });

    // Simulation progression par étapes
    for (final p in [0.2, 0.45, 0.6, 0.80, 1.0]) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _progression = p);
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _syncEnCours = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              '${_documentsEnAttente.length} documents synchronisés',
              style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: ThemeApplication.couleurSecondaire,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      ),
    );
  }

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

          // ── SliverAppBar ──────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: ThemeApplication.couleurPrimaire,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _EnteteSync(nbEnAttente: _documentsEnAttente.length),
            ),
          ),

          // ── Bannière hors-ligne ───────────────────────────────
          SliverToBoxAdapter(
            child: _BanniereHorsLigne(nbEnAttente: _documentsEnAttente.length),
          ),

          // ── File d'attente ────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _TitreSection(
                titre: 'File d\'attente',
                sousTitre: '${_documentsEnAttente.length} rapports en attente de synchronisation',
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CarteDocument(document: _documentsEnAttente[i]),
                ),
                childCount: _documentsEnAttente.length,
              ),
            ),
          ),

          // ── Carte sync ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
            sliver: SliverToBoxAdapter(
              child: _CarteSync(
                syncEnCours: _syncEnCours,
                progression: _progression,
                onSyncTap: _syncEnCours ? null : _lancerSync,
              ),
            ),
          ),
        ],
      ),

      // ── Bottom nav ────────────────────────────────────────────
      bottomNavigationBar: WidgetBarreNavigation(
        indexCourant: _indexNav,
        onTap: (i) => setState(() => _indexNav = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ENTÊTE
// ─────────────────────────────────────────────────────────────────

class _EnteteSync extends StatelessWidget {
  final int nbEnAttente;

  const _EnteteSync({required this.nbEnAttente});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      color: ThemeApplication.couleurPrimaire,
      padding: EdgeInsets.only(
        top: top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Synchronisation',
                style: ThemeApplication.titrePrincipal.copyWith(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$nbEnAttente document${nbEnAttente > 1 ? 's' : ''} en attente',
                style: ThemeApplication.legende.copyWith(
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Badge compteur
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$nbEnAttente',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BANNIÈRE HORS-LIGNE
// ─────────────────────────────────────────────────────────────────

class _BanniereHorsLigne extends StatelessWidget {
  final int nbEnAttente;

  const _BanniereHorsLigne({required this.nbEnAttente});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ThemeApplication.couleurAvertissement,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Les données seront synchronisées plus tard',
              style: ThemeApplication.corpsMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TITRE SECTION
// ─────────────────────────────────────────────────────────────────

class _TitreSection extends StatelessWidget {
  final String titre;
  final String sousTitre;

  const _TitreSection({required this.titre, required this.sousTitre});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: ThemeApplication.titrePrincipal.copyWith(
            fontSize: 22,
            color: const Color(0xFF1A1C1E),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sousTitre,
          style: ThemeApplication.corpsMedium.copyWith(
            color: const Color(0xFF464554),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CARTE DOCUMENT EN ATTENTE
// ─────────────────────────────────────────────────────────────────

class _CarteDocument extends StatelessWidget {
  final _DocumentSync document;

  const _CarteDocument({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC7C5D6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A4749CD),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Miniature document
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFC0C1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 28,
              color: Color(0xFF5780FA),
            ),
          ),

          const SizedBox(width: 16),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre + badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        document.typeDocument,
                        style: ThemeApplication.corpsMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1C1E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _BadgeStatut(
                      libelle: document.libelle,
                      couleurFond: document.couleurFond,
                      couleurTexte: document.couleurTexte,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Date
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: ThemeApplication.couleurTexteSecondaire,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      document.date,
                      style: ThemeApplication.legende.copyWith(
                        color: const Color(0xFF464554),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Lieu
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: ThemeApplication.couleurTexteSecondaire,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        document.lieu,
                        style: ThemeApplication.legende.copyWith(
                          color: const Color(0xFF464554),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
// CARTE SYNCHRONISATION (progression + bouton)
// ─────────────────────────────────────────────────────────────────

class _CarteSync extends StatelessWidget {
  final bool syncEnCours;
  final double progression;
  final VoidCallback? onSyncTap;

  const _CarteSync({
    required this.syncEnCours,
    required this.progression,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeApplication.couleurPrimaire.withOpacity(0.15)),
        boxShadow: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
          BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Ligne statut + pourcentage ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Icône animée si en cours
                  syncEnCours
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              ThemeApplication.couleurPrimaire,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.sync_rounded,
                          size: 16,
                          color: ThemeApplication.couleurPrimaire,
                        ),
                  const SizedBox(width: 8),
                  Text(
                    syncEnCours
                        ? 'Synchronisation en cours...'
                        : 'Prêt à synchroniser',
                    style: ThemeApplication.corpsMedium.copyWith(
                      color: ThemeApplication.couleurPrimaire,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (syncEnCours)
                Text(
                  '${(progression * 100).toInt()}%',
                  style: ThemeApplication.titrePrincipal.copyWith(
                    fontSize: 16,
                    color: ThemeApplication.couleurPrimaire,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),

          // ── Barre de progression ───────────────────────────────
          if (syncEnCours) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progression),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE8E8EA),
                  valueColor: AlwaysStoppedAnimation(
                    ThemeApplication.couleurPrimaire,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ── Bouton principal ───────────────────────────────────
          GestureDetector(
            onTap: onSyncTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: syncEnCours
                    ? ThemeApplication.couleurPrimaire.withOpacity(0.6)
                    : ThemeApplication.couleurPrimaire,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: syncEnCours
                    ? []
                    : const [
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
                  Icon(
                    syncEnCours ? Icons.hourglass_top_rounded : Icons.sync_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    syncEnCours ? 'Synchronisation...' : 'Synchroniser maintenant',
                    style: ThemeApplication.labelBouton,
                  ),
                ],
              ),
            ),
          ),

          // ── Info dernière sync ─────────────────────────────────
          const SizedBox(height: 14),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: ThemeApplication.couleurTexteSecondaire,
                ),
                const SizedBox(width: 5),
                Text(
                  'Dernière sync : Aujourd\'hui, 08:14',
                  style: ThemeApplication.legende.copyWith(
                    color: ThemeApplication.couleurTexteSecondaire,
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
// BADGE STATUT
// ─────────────────────────────────────────────────────────────────

class _BadgeStatut extends StatelessWidget {
  final String libelle;
  final Color couleurFond;
  final Color couleurTexte;

  const _BadgeStatut({
    required this.libelle,
    required this.couleurFond,
    required this.couleurTexte,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleurFond,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        libelle,
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