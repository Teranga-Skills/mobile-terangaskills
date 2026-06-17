// -----------------------------------------------------------------
// Écran : Capture et Analyse Document par IA (OCR)
// -----------------------------------------------------------------

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../configuration/routes.dart';
import '../../configuration/theme.dart';
import '../../providers/provider_signalements.dart';

class EcranCameraDocument extends StatefulWidget {
  const EcranCameraDocument({super.key});

  @override
  State<EcranCameraDocument> createState() => _EcranCameraDocumentState();
}

class _EcranCameraDocumentState extends State<EcranCameraDocument> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageSelectionnee;
  bool _analyseEnCours = false;

  @override
  void initState() {
    super.initState();
    // Ouvrir automatiquement la caméra après le premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prendrePhoto();
    });
  }

  // Prendre une photo avec la caméra
  Future<void> _prendrePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _imageSelectionnee = photo;
        });
      } else if (_imageSelectionnee == null) {
        // Si l'utilisateur annule la prise de photo lors du chargement initial
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _afficherErreur("Impossible d'ouvrir l'appareil photo : $e");
      if (mounted && _imageSelectionnee == null) {
        Navigator.pop(context);
      }
    }
  }

  // Lancer l'analyse OCR / IA
  Future<void> _lancerAnalyse() async {
    if (_imageSelectionnee == null) return;

    setState(() => _analyseEnCours = true);

    final provider = Provider.of<ProviderSignalements>(context, listen: false);
    final resultatOcr = await provider.executerOcr(_imageSelectionnee!.path);

    setState(() => _analyseEnCours = false);

    if (!mounted) return;

    if (resultatOcr != null) {
      // Aller à l'écran formulaire avec les données extraites
      Navigator.pushReplacementNamed(
        context,
        Routes.nouveauSignalement,
        arguments: resultatOcr,
      );
    } else {
      _afficherErreur("L'analyse du document a échoué. Passage en mode manuel.");
      // Mode dégradé : formulaire vide
      Navigator.pushReplacementNamed(
        context,
        Routes.nouveauSignalement,
        arguments: <String, dynamic>{},
      );
    }
  }

  // Afficher un SnackBar d'erreur
  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Montserrat')),
        backgroundColor: ThemeApplication.couleurDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApplication.couleurFondSombre,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Numérisation Acte',
          style: ThemeApplication.titrePrincipal.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ─── Contenu Principal ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Cadrez le document d\'état civil dans la zone ci-dessous.',
                  textAlign: TextAlign.center,
                  style: ThemeApplication.corpsMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),

                // ─── Cadre du Document / Prévisualisation ────────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _imageSelectionnee != null
                            ? ThemeApplication.couleurPrimaire
                            : Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: _imageSelectionnee != null
                          ? Image.file(
                              File(_imageSelectionnee!.path),
                              fit: BoxFit.cover,
                            )
                          : _construireViseurVide(),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ─── Actions du bas ──────────────────────────────────────────
                if (_imageSelectionnee == null)
                  _construireBoutonOption(
                    label: 'Ouvrir l\'appareil photo',
                    icone: Icons.camera_alt_rounded,
                    onTap: _prendrePhoto,
                  )
                else
                  Column(
                    children: [
                      _construireBoutonOption(
                        label: 'Lancer l\'analyse IA (GPT-4o)',
                        icone: Icons.auto_awesome_rounded,
                        onTap: _lancerAnalyse,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _imageSelectionnee = null),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: const Text(
                                'Recommencer',
                                style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  Routes.nouveauSignalement,
                                  arguments: <String, dynamic>{},
                                );
                              },
                              child: Text(
                                'Saisie Manuelle',
                                style: TextStyle(
                                  color: ThemeApplication.couleurPrimaire,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ─── Overlay d'Analyse IA (Premium Loading) ────────────────────────
          if (_analyseEnCours)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: ThemeApplication.couleurFondSombre.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ThemeApplication.couleurPrimaire,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Extraction IA en cours...',
                        textAlign: TextAlign.center,
                        style: ThemeApplication.titrePrincipal.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Le copilote IA structure les données de l\'acte de naissance et vérifie la cohérence sémantique...',
                        textAlign: TextAlign.center,
                        style: ThemeApplication.corpsMedium.copyWith(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Viseur vide
  Widget _construireViseurVide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.document_scanner_outlined,
          size: 72,
          color: Colors.white.withOpacity(0.15),
        ),
        const SizedBox(height: 16),
        Text(
          'Aucun document sélectionné',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Bouton personnalisé
  Widget _construireBoutonOption({
    required String label,
    required IconData icone,
    required VoidCallback onTap,
    bool estSecondaire = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: estSecondaire ? Colors.white.withOpacity(0.08) : ThemeApplication.couleurPrimaire,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: estSecondaire
              ? []
              : const [
                  BoxShadow(
                    color: Color(0x444749CD),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: ThemeApplication.labelBouton.copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
