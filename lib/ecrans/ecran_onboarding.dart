// -----------------------------------------------------------------
// Écran d'onboarding — 3 pages avec PageView
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../configuration/routes.dart';
import '../../configuration/theme.dart';
import '../../models/modele_onboarding.dart';
import '../../widgets/widget_bouton_primaire.dart';
import '../../widgets/widgets_onboarding.dart';


class EcranOnboarding extends StatefulWidget {
  const EcranOnboarding({super.key});

  @override
  State<EcranOnboarding> createState() => _EcranOnboardingState();
}

class _EcranOnboardingState extends State<EcranOnboarding> {
  final PageController _controleurPage = PageController();
  int _indexCourant = 0;

  bool get _estDernierePage =>
      _indexCourant == pagesOnboarding.length - 1;

  @override
  void dispose() {
    _controleurPage.dispose();
    super.dispose();
  }

  // ─── Navigation ─────────────────────────────────────────────────

  void _pageSuivante() {
    if (!_estDernierePage) {
      _controleurPage.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _versConnexion();
    }
  }

  void _pagePrecedente() {
    if (_indexCourant > 0) {
      _controleurPage.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _versConnexion() {
    Navigator.pushReplacementNamed(context, Routes.connexion);
  }

  // ─── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApplication.couleurFond,
      body: SafeArea(
        child: Column(
          children: [
            _construireBoutonPasser(),
            Expanded(
              child: PageView.builder(
                controller: _controleurPage,
                onPageChanged: (index) =>
                    setState(() => _indexCourant = index),
                itemCount: pagesOnboarding.length,
                itemBuilder: (_, index) => _VuePageOnboarding(
                  page: pagesOnboarding[index],
                ),
              ),
            ),
            _construireControlesNavigation(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Bouton "Passer" ────────────────────────────────────────────

  Widget _construireBoutonPasser() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, right: 24),
        child: AnimatedOpacity(
          opacity: _estDernierePage ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: TextButton(
            onPressed: _estDernierePage ? null : _versConnexion,
            child: Text('Passer', style: ThemeApplication.labelSecondaire),
          ),
        ),
      ),
    );
  }

  // ─── Contrôles du bas ───────────────────────────────────────────

  Widget _construireControlesNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IndicateursDots(
            indexCourant: _indexCourant,
            total: pagesOnboarding.length,
          ),
          Row(
            children: [
              if (_indexCourant > 0) ...[
                BoutonIconeCirculaire(
                  icone: Icons.arrow_back_ios_new_rounded,
                  onTap: _pagePrecedente,
                ),
                const SizedBox(width: 12),
              ],
              WidgetBoutonPrimaire(
                label: _estDernierePage ? 'Commencez' : 'Suivant',
                onTap: _pageSuivante,
                estExpanse: _estDernierePage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Vue d'une page ─────────────────────────────────────────────

class _VuePageOnboarding extends StatelessWidget {
  final ModelePageOnboarding page;

  const _VuePageOnboarding({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CarteIllustration(
              couleur: page.couleurIllustration,
              cheminSvg: page.cheminSvg,
            ),
          ),
          const SizedBox(height: 48),
          Text(page.titre, style: ThemeApplication.titrePrincipal),
          const SizedBox(height: 12),
          Text(page.sousTitre, style: ThemeApplication.titreSecondaire),
          // if (page.note != null) ...[
          //   const SizedBox(height: 20),
          //   CarteNote(texte: page.note!),
          // ],
        ],
      ),
    );
  }
}