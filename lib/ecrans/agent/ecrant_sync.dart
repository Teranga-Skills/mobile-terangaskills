// -----------------------------------------------------------------
// Écran : Synchronisation Agent
// File d'attente hors-ligne + progression + actions
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../configuration/theme.dart';
import '../../widgets/widget_barre_navigation.dart';
import '../../widgets/widget_carte_signalement.dart';
import '../../providers/provider_signalements.dart';
import 'ecran_mes_signalements.dart';

// ─────────────────────────────────────────────────────────────────
// ÉCRAN PRINCIPAL
// ─────────────────────────────────────────────────────────────────

class EcranSynchronisation extends StatefulWidget {
  const EcranSynchronisation({super.key});

  @override
  State<EcranSynchronisation> createState() => _EcranSynchronisationState();
}

class _EcranSynchronisationState extends State<EcranSynchronisation> {
  int _indexNav = 2; // onglet Sync actif

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final provider = Provider.of<ProviderSignalements>(context);
    final documentsEnAttente = provider.fileAttenteHorsLigne;

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
              background: _EnteteSync(nbEnAttente: documentsEnAttente.length),
            ),
          ),

          // ── Bannière hors-ligne ───────────────────────────────
          SliverToBoxAdapter(
            child: _BanniereHorsLigne(
              nbEnAttente: documentsEnAttente.length,
              estEnLigne: provider.estEnLigne,
            ),
          ),

          // ── File d'attente ────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _TitreSection(
                titre: 'File d\'attente',
                sousTitre: '${documentsEnAttente.length} rapport${documentsEnAttente.length > 1 ? 's' : ''} en attente de synchronisation',
              ),
            ),
          ),

          if (documentsEnAttente.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_done_outlined,
                        size: 64,
                        color: ThemeApplication.couleurPrimaire.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun document en attente',
                        style: ThemeApplication.corpsMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WidgetCarteSignalement(
                      signalement: documentsEnAttente[i],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EcranDetailSignalement(
                              signalement: documentsEnAttente[i],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  childCount: documentsEnAttente.length,
                ),
              ),
            ),

          // ── Carte sync ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
            sliver: SliverToBoxAdapter(
              child: _CarteSync(
                syncEnCours: provider.syncEnCours,
                progression: provider.progressionSync,
                nbDocuments: documentsEnAttente.length,
                estEnLigne: provider.estEnLigne,
                onSyncTap: (provider.syncEnCours || documentsEnAttente.isEmpty || !provider.estEnLigne)
                    ? null
                    : () => provider.synchroniserFileAttente(),
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
          Expanded(
            child: Column(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$nbEnAttente document${nbEnAttente > 1 ? 's' : ''} en attente',
                  style: ThemeApplication.legende.copyWith(
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
// BANNIÈRE HORS-LIGNE / EN LIGNE
// ─────────────────────────────────────────────────────────────────

class _BanniereHorsLigne extends StatelessWidget {
  final int nbEnAttente;
  final bool estEnLigne;

  const _BanniereHorsLigne({required this.nbEnAttente, required this.estEnLigne});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: estEnLigne ? ThemeApplication.couleurSecondaire : ThemeApplication.couleurAvertissement,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            estEnLigne ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              estEnLigne
                  ? 'Vous êtes en ligne. Les rapports en attente peuvent être synchronisés.'
                  : 'Mode Hors-ligne actif. Les données seront synchronisées plus tard.',
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
// CARTE SYNCHRONISATION (progression + bouton)
// ─────────────────────────────────────────────────────────────────

class _CarteSync extends StatelessWidget {
  final bool syncEnCours;
  final double progression;
  final int nbDocuments;
  final bool estEnLigne;
  final VoidCallback? onSyncTap;

  const _CarteSync({
    required this.syncEnCours,
    required this.progression,
    required this.nbDocuments,
    required this.estEnLigne,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool desactive = onSyncTap == null;

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
              Expanded(
                child: Row(
                  children: [
                    // Icône animée si en cours
                    syncEnCours
                        ? const SizedBox(
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
                            color: desactive ? Colors.grey : ThemeApplication.couleurPrimaire,
                          ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncEnCours
                            ? 'Synchronisation en cours...'
                            : !estEnLigne
                                ? 'Hors-ligne - Synchronisation impossible'
                                : nbDocuments == 0
                                    ? 'Tous les documents sont synchronisés'
                                    : 'Prêt à synchroniser',
                        style: ThemeApplication.corpsMedium.copyWith(
                          color: desactive && !syncEnCours ? Colors.grey : ThemeApplication.couleurPrimaire,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                color: desactive
                    ? Colors.grey.withOpacity(0.5)
                    : ThemeApplication.couleurPrimaire,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: desactive
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
                  'Dernière sync : Aujourd\'hui, à l\'instant',
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