// -----------------------------------------------------------------
// Écran : Nouveau Signalement (Formulaire tactile / Dégradé)
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../configuration/routes.dart';
import '../../configuration/theme.dart';
import '../../providers/provider_signalements.dart';
import '../../providers/provider_authentification.dart';
import '../../widgets/widget_champ_texte.dart';
import '../../widgets/widget_popup_score_ia.dart';
import '../../utils/util_identification.dart';

class EcranNouveauSignalement extends StatefulWidget {
  const EcranNouveauSignalement({super.key});

  @override
  State<EcranNouveauSignalement> createState() => _EcranNouveauSignalementState();
}

class _EcranNouveauSignalementState extends State<EcranNouveauSignalement> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nomController;
  late final TextEditingController _numeroDocumentController;
  late final TextEditingController _dateNaissanceController;
  late final TextEditingController _nationaliteController;
  late final TextEditingController _lieuController;
  late final TextEditingController _noteAgentController;

  String _typeDocument = 'CIN';
  bool _donneesInitialisees = false;
  String? _cheminImage;
  String? _analyseId;
  String? _decision;
  int? _fraudScore;
  Map<String, dynamic>? _matchedData;
  String? _prenomScan;
  bool _analyseEnCours = false;
  bool _envoiEnCours = false;

  final List<String> _typesDocuments = [
    'CIN',
    'Passeport',
    'Permis de conduire',
    'Extrait de Naissance',
    'Casier Judiciaire',
    'Certificat de Résidence',
    'Titre de séjour'
  ];

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _numeroDocumentController = TextEditingController();
    _dateNaissanceController = TextEditingController();
    _nationaliteController = TextEditingController();
    _lieuController = TextEditingController();
    _noteAgentController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_donneesInitialisees) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (arguments != null && arguments.isNotEmpty) {
        _nomController.text = arguments['nom'] ?? '';
        _typeDocument = _typesDocuments.contains(arguments['typeDocument'])
            ? arguments['typeDocument']
            : 'CIN';
        _numeroDocumentController.text = UtilIdentification.sanitiser(
          arguments['numeroDocument']?.toString(),
        );
        _dateNaissanceController.text = arguments['dateNaissance'] ?? '';
        _nationaliteController.text = arguments['nationalite'] ?? 'Sénégalaise';
        _lieuController.text = arguments['lieu'] ?? '';
        _noteAgentController.text = arguments['noteAgent'] ?? '';
        _cheminImage = arguments['cheminImage'];
        _analyseId = arguments['analyse_id'];
        _decision = arguments['decision']?.toString();
        _fraudScore = _parseScore(arguments['fraud_score']);
        _matchedData = arguments['matched_data'] is Map
            ? Map<String, dynamic>.from(arguments['matched_data'] as Map)
            : null;
        _prenomScan = arguments['prenom']?.toString();
        if (_prenomScan == null && _matchedData != null) {
          _prenomScan = _matchedData!['prenom']?.toString();
        }
      } else {
        // Obtenir la zone de l'agent connecté par défaut pour le lieu
        final authProvider = Provider.of<ProviderAuthentification>(context, listen: false);
        _lieuController.text = authProvider.utilisateurCourant?.zone ?? '';
        _nationaliteController.text = 'Sénégalaise';
      }
      _donneesInitialisees = true;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _numeroDocumentController.dispose();
    _dateNaissanceController.dispose();
    _nationaliteController.dispose();
    _lieuController.dispose();
    _noteAgentController.dispose();
    super.dispose();
  }

  int? _parseScore(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> _donneesFormulaire() => {
    'nom': _nomController.text.trim(),
    'typeDocument': _typeDocument,
    'numeroDocument': UtilIdentification.sanitiser(_numeroDocumentController.text),
    'dateNaissance': _dateNaissanceController.text.trim(),
    'nationalite': _nationaliteController.text.trim(),
    'lieu': _lieuController.text.trim(),
    'noteAgent': _noteAgentController.text.trim(),
    'cheminImage': _cheminImage,
    'analyse_id': _analyseId,
    'decision': _decision,
    'fraudScore': _fraudScore,
  };

  // Lancer l'analyse IA et afficher la pop-up de score
  Future<void> _analyser() async {
    if (!_formKey.currentState!.validate()) return;

    // Score déjà obtenu au scan → afficher la pop-up directement
    if (_decision != null && _fraudScore != null) {
      _afficherPopupScore();
      return;
    }

    final provider = Provider.of<ProviderSignalements>(context, listen: false);

    if (_cheminImage == null || _cheminImage!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Impossible d\'analyser : aucun document scanné disponible.',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: ThemeApplication.couleurDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _analyseEnCours = true);

    final resultatAnalyse = await provider.executerOcr(_cheminImage!);

    if (!mounted) return;
    setState(() => _analyseEnCours = false);

    if (resultatAnalyse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'L\'analyse du document a échoué. Veuillez réessayer.',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: ThemeApplication.couleurDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    _decision = resultatAnalyse['decision']?.toString() ?? 'VALID';
    _fraudScore = _parseScore(resultatAnalyse['fraud_score']) ?? 0;
    _analyseId = resultatAnalyse['analyse_id']?.toString() ?? _analyseId;
    _matchedData = resultatAnalyse['matched_data'] is Map
        ? Map<String, dynamic>.from(resultatAnalyse['matched_data'] as Map)
        : _matchedData;
    _prenomScan = resultatAnalyse['prenom']?.toString() ?? _prenomScan;

    _afficherPopupScore();
  }

  void _afficherPopupScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return WidgetPopupScoreIa(
              decision: _decision ?? 'VALID',
              fraudScore: _fraudScore ?? 0,
              matchedData: _matchedData,
              nomScan: _nomController.text.trim(),
              prenomScan: _prenomScan,
              numeroScan: _numeroDocumentController.text.trim(),
              dateNaissanceScan: _dateNaissanceController.text.trim(),
              chargementEnvoi: _envoiEnCours,
              onEnvoyer: () async {
                setDialogState(() => _envoiEnCours = true);
                await _envoyerDepuisPopup(dialogContext);
              },
              onTerminer: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.accueilAgent,
                  (route) => false,
                );
              },
            );
          },
        );
      },
    );
  }

  // Envoyer le signalement à l'admin depuis la pop-up
  Future<void> _envoyerDepuisPopup(BuildContext dialogContext) async {
    final provider = Provider.of<ProviderSignalements>(context, listen: false);
    final estSynchronise = await provider.soumettreSignalement(_donneesFormulaire());

    if (!mounted) return;
    _envoiEnCours = false;

    Navigator.of(dialogContext).pop();

    if (estSynchronise) {
      _afficherMessageSucces(
        'Signalement envoyé !',
        'Le rapport a été transmis à l\'administrateur avec succès.',
        Icons.check_circle_outline,
        ThemeApplication.couleurSecondaire,
      );
    } else {
      _afficherMessageSucces(
        'Enregistré hors-ligne !',
        'Connexion indisponible. Le rapport sera synchronisé plus tard.',
        Icons.wifi_off_rounded,
        ThemeApplication.couleurAvertissement,
      );
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.accueilAgent,
      (route) => false,
    );
  }

  // Boîte de dialogue de confirmation de succès
  void _afficherMessageSucces(String titre, String message, IconData icone, Color couleur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icone, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: couleur,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderSignalements>(context);
    final boutonDesactive = provider.chargement || _analyseEnCours;

    return Scaffold(
      backgroundColor: ThemeApplication.couleurFond,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeApplication.couleurPrimaire,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détails Signalement',
          style: ThemeApplication.titrePrincipal.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Statut Réseau Actuel ────────────────────────────────────
                _construireBanniereReseau(provider.estEnLigne),
                const SizedBox(height: 20),

                Text(
                  'Vérifiez et complétez les informations extraites du document.',
                  style: ThemeApplication.corpsMedium.copyWith(
                    color: ThemeApplication.couleurTexteSecondaire,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Titre Section ───────────────────────────────────────────
                _construireTitreSection('Identité du citoyen'),
                const SizedBox(height: 12),

                WidgetChampTexte(
                  placeholder: 'Nom complet',
                  controller: _nomController,
                  icone: Icons.person_outline,
                  validateur: (v) => (v == null || v.trim().isEmpty) ? 'Le nom est requis' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: WidgetChampTexte(
                        placeholder: 'Nationalité',
                        controller: _nationaliteController,
                        icone: Icons.flag_outlined,
                        validateur: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WidgetChampTexte(
                        placeholder: 'JJ/MM/AAAA',
                        controller: _dateNaissanceController,
                        icone: Icons.calendar_month_outlined,
                        validateur: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ─── Section Document ────────────────────────────────────────
                _construireTitreSection('Caractéristiques du document'),
                const SizedBox(height: 12),

                // Dropdown personnalisé pour le type de document
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: ThemeApplication.blanc,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _typeDocument,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: ThemeApplication.couleurPrimaire),
                      style: ThemeApplication.corpsMedium.copyWith(
                        color: ThemeApplication.couleurTexte,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (String? nouveauType) {
                        if (nouveauType != null) {
                          setState(() => _typeDocument = nouveauType);
                        }
                      },
                      items: _typesDocuments.map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                WidgetChampTexte(
                  placeholder: 'Numéro de document',
                  controller: _numeroDocumentController,
                  icone: Icons.badge_outlined,
                  validateur: UtilIdentification.messageErreurFormat,
                ),
                const SizedBox(height: 28),

                // ─── Section Contrôle ────────────────────────────────────────
                _construireTitreSection('Informations du contrôle'),
                const SizedBox(height: 12),

                WidgetChampTexte(
                  placeholder: 'Lieu du contrôle (Mairie, commissariat)',
                  controller: _lieuController,
                  icone: Icons.location_on_outlined,
                  validateur: (v) => (v == null || v.trim().isEmpty) ? 'Le lieu est requis' : null,
                ),
                const SizedBox(height: 16),

                WidgetChampTexte(
                  placeholder: 'Notes additionnelles de l\'agent...',
                  controller: _noteAgentController,
                  icone: Icons.notes_outlined,
                  clavier: TextInputType.multiline,
                ),
                const SizedBox(height: 40),

                // ─── Bouton Analyser ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: boutonDesactive ? null : _analyser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeApplication.couleurPrimaire,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      elevation: 2,
                    ),
                    child: boutonDesactive
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Analyser',
                                style: ThemeApplication.labelBouton,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Titre de section propre
  Widget _construireTitreSection(String titre) {
    return Text(
      titre,
      style: ThemeApplication.titrePrincipal.copyWith(
        fontSize: 16,
        color: const Color(0xFF1A1C1E),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Bannière d'avertissement de connectivité
  Widget _construireBanniereReseau(bool estEnLigne) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: estEnLigne
            ? ThemeApplication.couleurSecondaire.withOpacity(0.08)
            : ThemeApplication.couleurAvertissement.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: estEnLigne
              ? ThemeApplication.couleurSecondaire.withOpacity(0.2)
              : ThemeApplication.couleurAvertissement.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            estEnLigne ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: estEnLigne ? ThemeApplication.couleurSecondaire : ThemeApplication.couleurAvertissement,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              estEnLigne
                  ? 'Connexion active. Le rapport sera analysé en temps réel.'
                  : 'Mode Hors-ligne. Le rapport sera mis en attente de synchronisation.',
              style: ThemeApplication.legende.copyWith(
                color: estEnLigne ? ThemeApplication.couleurSecondaire : ThemeApplication.couleurAvertissement,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
