// -----------------------------------------------------------------
// Écran : Mes Signalements
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../configuration/theme.dart';
import '../../models/modele_signalement.dart';
import '../../widgets/widget_carte_signalement.dart';
import '../../widgets/widget_barre_navigation.dart';

class EcranMesSignalements extends StatefulWidget {
  const EcranMesSignalements({super.key});

  @override
  State<EcranMesSignalements> createState() => _EcranMesSignalementsState();
}

class _EcranMesSignalementsState extends State<EcranMesSignalements> {
  final TextEditingController _rechercheController = TextEditingController();
  StatutSignalement? _filtreActif;
  String _recherche = '';
  int _indexNav = 1;

  // ── Données fictives — à remplacer par un appel API ─────────────
  static const _tousSignalements = [
    ModeleSignalement(
      id: '001',
      nom: 'Moussa Diop',
      typeDocument: 'CIN',
      lieu: 'Dakar',
      date: 'Il y a 10 min',
      statut: StatutSignalement.synchronise,
      numeroDocument: 'SN-2024-001234',
      dateNaissance: '12/03/1985',
      nationalite: 'Sénégalaise',
      noteAgent: 'Document authentique, aucune anomalie détectée.',
    ),
    ModeleSignalement(
      id: '002',
      nom: 'Fatou Ndiaye',
      typeDocument: 'Passeport',
      lieu: 'Thiès',
      date: 'Il y a 45 min',
      statut: StatutSignalement.enCours,
      numeroDocument: 'SN-P-2023-005678',
      dateNaissance: '07/11/1992',
      nationalite: 'Sénégalaise',
      noteAgent: 'Vérification en cours, anomalie sur la photo.',
    ),
    ModeleSignalement(
      id: '003',
      nom: 'Amadou Fall',
      typeDocument: 'Permis de conduire',
      lieu: 'Saint-Louis',
      date: 'Hier, 18:24',
      statut: StatutSignalement.horsLigne,
      numeroDocument: 'PC-2022-009012',
      dateNaissance: '23/06/1978',
      nationalite: 'Sénégalaise',
      noteAgent: 'En attente de synchronisation réseau.',
    ),
    ModeleSignalement(
      id: '004',
      nom: 'Khady Seck',
      typeDocument: 'CIN',
      lieu: 'Kaolack',
      date: 'Hier, 15:10',
      statut: StatutSignalement.synchronise,
      numeroDocument: 'SN-2023-007890',
      dateNaissance: '15/09/1990',
      nationalite: 'Sénégalaise',
      noteAgent: 'Document valide.',
    ),
    ModeleSignalement(
      id: '005',
      nom: 'Ibrahima Bâ',
      typeDocument: 'Titre de séjour',
      lieu: 'Ziguinchor',
      date: '20/06/2025',
      statut: StatutSignalement.erreur,
      numeroDocument: 'TS-2024-003456',
      dateNaissance: '01/01/1980',
      nationalite: 'Guinéenne',
      noteAgent: 'Incohérence détectée entre les données et le document.',
    ),
    ModeleSignalement(
      id: '006',
      nom: 'Aissatou Diallo',
      typeDocument: 'Passeport',
      lieu: 'Dakar',
      date: '19/06/2025',
      statut: StatutSignalement.synchronise,
      numeroDocument: 'GN-P-2022-001122',
      dateNaissance: '30/04/1995',
      nationalite: 'Guinéenne',
      noteAgent: 'Contrôle terminé, document conforme.',
    ),
  ];

  List<ModeleSignalement> get _signalementsFiltres {
    return _tousSignalements.where((s) {
      final matchRecherche = _recherche.isEmpty ||
          s.nom.toLowerCase().contains(_recherche.toLowerCase()) ||
          s.lieu.toLowerCase().contains(_recherche.toLowerCase()) ||
          s.typeDocument.toLowerCase().contains(_recherche.toLowerCase());

      final matchFiltre =
          _filtreActif == null || s.statut == _filtreActif;

      return matchRecherche && matchFiltre;
    }).toList();
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  void _ouvrirDetails(ModeleSignalement signalement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EcranDetailSignalement(signalement: signalement),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final resultats = _signalementsFiltres;

    return Scaffold(
      backgroundColor: ThemeApplication.couleurFond,
      extendBody: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── AppBar ─────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: ThemeApplication.couleurPrimaire,
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: ThemeApplication.couleurPrimaire,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre + retour
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Mes Signalements',
                          style: ThemeApplication.titrePrincipal.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Text(
                        '${_tousSignalements.length} signalements au total',
                        style: ThemeApplication.legende.copyWith(
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Recherche + filtres sticky ─────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _EnteteRechercheDelegate(
              recherche: _rechercheController,
              filtreActif: _filtreActif,
              onRecherche: (v) => setState(() => _recherche = v),
              onFiltre: (f) => setState(
                () => _filtreActif = _filtreActif == f ? null : f,
              ),
            ),
          ),

          // ── Liste résultats ────────────────────────────────────
          resultats.isEmpty
              ? SliverFillRemaining(child: _EtatVide())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: WidgetCarteSignalement(
                          signalement: resultats[i],
                          onTap: () => _ouvrirDetails(resultats[i]),
                        ),
                      ),
                      childCount: resultats.length,
                    ),
                  ),
                ),
        ],
      ),

      bottomNavigationBar: WidgetBarreNavigation(
        indexCourant: _indexNav,
        onTap: (i) => setState(() => _indexNav = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EN-TÊTE RECHERCHE + FILTRES (sticky)
// ─────────────────────────────────────────────────────────────────
class _EnteteRechercheDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController recherche;
  final StatutSignalement? filtreActif;
  final ValueChanged<String> onRecherche;
  final ValueChanged<StatutSignalement> onFiltre;

  const _EnteteRechercheDelegate({
    required this.recherche,
    required this.filtreActif,
    required this.onRecherche,
    required this.onFiltre,
  });

  @override
  double get minExtent => 120;
  @override
  double get maxExtent => 120;

  @override
  bool shouldRebuild(_EnteteRechercheDelegate old) =>
      old.filtreActif != filtreActif || old.recherche.text != recherche.text;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: ThemeApplication.couleurFond,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          // ── Champ recherche ──────────────────────────────────
          SizedBox(
            height: 46,
            child: TextField(
              controller: recherche,
              onChanged: onRecherche,
              style: ThemeApplication.corpsMedium.copyWith(
                color: ThemeApplication.couleurTexte,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un nom, lieu, document...',
                hintStyle: ThemeApplication.corpsMedium.copyWith(
                  color: ThemeApplication.couleurTexteSecondaire,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: ThemeApplication.couleurTexteSecondaire,
                  size: 20,
                ),
                suffixIcon: recherche.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: ThemeApplication.couleurTexteSecondaire,
                        ),
                        onPressed: () {
                          recherche.clear();
                          onRecherche('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: ThemeApplication.blanc,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeApplication.couleurPrimaire,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Filtres chips ────────────────────────────────────
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: StatutSignalement.values
                  .map((s) => _ChipFiltre(
                        statut: s,
                        estActif: filtreActif == s,
                        onTap: () => onFiltre(s),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipFiltre extends StatelessWidget {
  final StatutSignalement statut;
  final bool estActif;
  final VoidCallback onTap;

  const _ChipFiltre({
    required this.statut,
    required this.estActif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: estActif ? ThemeApplication.couleurPrimaire : ThemeApplication.blanc,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: estActif
                ? ThemeApplication.couleurPrimaire
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          statut.libelle,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: estActif ? Colors.white : ThemeApplication.couleurTexteSecondaire,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ÉTAT VIDE
// ─────────────────────────────────────────────────────────────────
class _EtatVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ThemeApplication.couleurPrimaire.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 36,
              color: ThemeApplication.couleurPrimaire,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat',
            style: ThemeApplication.titrePrincipal.copyWith(
              fontSize: 18,
              color: const Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Essayez un autre terme ou filtre',
            style: ThemeApplication.corpsMedium.copyWith(
              color: ThemeApplication.couleurTexteSecondaire,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ÉCRAN DÉTAIL SIGNALEMENT
// ─────────────────────────────────────────────────────────────────
class EcranDetailSignalement extends StatelessWidget {
  final ModeleSignalement signalement;

  const EcranDetailSignalement({
    super.key,
    required this.signalement,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApplication.couleurFond,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── AppBar avec avatar ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: ThemeApplication.couleurPrimaire,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: ThemeApplication.couleurPrimaire,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 8),

                    // Bouton retour
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Avatar grand format
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          signalement.initiales,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      signalement.nom,
                      style: ThemeApplication.titrePrincipal.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      signalement.typeDocument,
                      style: ThemeApplication.legende.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu détail ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Badge statut centré
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: signalement.statut.couleurFond,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      signalement.statut.libelle,
                      style: TextStyle(
                        color: signalement.statut.couleurTexte,
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Carte infos document
                _CarteInfos(
                  titre: 'Informations du document',
                  icone: Icons.badge_outlined,
                  enfants: [
                    _LigneInfo(
                      label: 'Type',
                      valeur: signalement.typeDocument,
                    ),
                    _LigneInfo(
                      label: 'Numéro',
                      valeur: signalement.numeroDocument ?? '—',
                    ),
                    _LigneInfo(
                      label: 'Date de naissance',
                      valeur: signalement.dateNaissance ?? '—',
                    ),
                    _LigneInfo(
                      label: 'Nationalité',
                      valeur: signalement.nationalite ?? '—',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Carte infos contrôle
                _CarteInfos(
                  titre: 'Informations du contrôle',
                  icone: Icons.location_on_outlined,
                  enfants: [
                    _LigneInfo(label: 'Lieu', valeur: signalement.lieu),
                    _LigneInfo(label: 'Date', valeur: signalement.date),
                    _LigneInfo(
                      label: 'Réf.',
                      valeur: '#${signalement.id}',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Note agent
                if (signalement.noteAgent != null)
                  _CarteInfos(
                    titre: 'Note de l\'agent',
                    icone: Icons.notes_rounded,
                    enfants: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          signalement.noteAgent!,
                          style: ThemeApplication.corpsMedium.copyWith(
                            color: const Color(0xFF464554),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                // Bouton action selon statut
                if (signalement.statut == StatutSignalement.horsLigne ||
                    signalement.statut == StatutSignalement.erreur)
                  GestureDetector(
                    onTap: () {
                      // TODO : resynchroniser
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
                            Icons.sync_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Resynchroniser',
                            style: ThemeApplication.labelBouton,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// COMPOSANTS DÉTAIL
// ─────────────────────────────────────────────────────────────────
class _CarteInfos extends StatelessWidget {
  final String titre;
  final IconData icone;
  final List<Widget> enfants;

  const _CarteInfos({
    required this.titre,
    required this.icone,
    required this.enfants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre section
          Row(
            children: [
              Icon(icone, size: 18, color: ThemeApplication.couleurPrimaire),
              const SizedBox(width: 8),
              Text(
                titre,
                style: ThemeApplication.corpsMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEF1FB)),
          const SizedBox(height: 12),
          ...enfants,
        ],
      ),
    );
  }
}

class _LigneInfo extends StatelessWidget {
  final String label;
  final String valeur;

  const _LigneInfo({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ThemeApplication.legende.copyWith(
              color: ThemeApplication.couleurTexteSecondaire,
              fontSize: 13,
            ),
          ),
          Text(
            valeur,
            style: ThemeApplication.corpsMedium.copyWith(
              color: const Color(0xFF1A1C1E),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
