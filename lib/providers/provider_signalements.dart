// -----------------------------------------------------------------
// Provider : Gestion des Signalements
// Gère la liste globale, la file d'attente hors-ligne et la sync.
// -----------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/modele_signalement.dart';
import '../services/service_api.dart';
import '../configuration/constantes.dart';

class ProviderSignalements extends ChangeNotifier {
  final ServiceApi _serviceApi = ServiceApi();
  final Connectivity _connectivity = Connectivity();

  List<ModeleSignalement> _signalements = [];
  List<ModeleSignalement> _fileAttenteHorsLigne = [];
  
  bool _chargement = false;
  bool _syncEnCours = false;
  double _progressionSync = 0.0;
  bool _estEnLigne = true;
  String? _erreur;

  List<ModeleSignalement> get signalements => _signalements;
  List<ModeleSignalement> get fileAttenteHorsLigne => _fileAttenteHorsLigne;
  bool get chargement => _chargement;
  bool get syncEnCours => _syncEnCours;
  double get progressionSync => _progressionSync;
  bool get estEnLigne => _estEnLigne;
  String? get erreur => _erreur;

  ProviderSignalements() {
    _initialiser();
  }

  Future<void> _initialiser() async {
    await verifierConnexion();
    await chargerFileAttenteLocale();
    await chargerSignalements();

    // Écouter les changements de connectivité réseau
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> resultats) {
      final resultat = resultats.isNotEmpty ? resultats.first : ConnectivityResult.none;
      _estEnLigne = (resultat != ConnectivityResult.none);
      notifyListeners();
      
      if (_estEnLigne && _fileAttenteHorsLigne.isNotEmpty && !_syncEnCours) {
        synchroniserFileAttente();
      }
    });
  }

  // Vérifier la connexion actuelle
  Future<void> verifierConnexion() async {
    final list = await _connectivity.checkConnectivity();
    final resultat = list.isNotEmpty ? list.first : ConnectivityResult.none;
    _estEnLigne = (resultat != ConnectivityResult.none);
    notifyListeners();
  }

  // Charger la liste principale des signalements (API)
  Future<void> chargerSignalements() async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    try {
      final listeJson = await _serviceApi.getSignalements();
      _signalements = listeJson.map((json) => _jsonVersModele(json)).toList();
      _chargement = false;
      notifyListeners();
    } catch (e) {
      _erreur = e.toString();
      _chargement = false;
      notifyListeners();
    }
  }

  // Charger la file d'attente hors-ligne stockée localement
  Future<void> chargerFileAttenteLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chaineJson = prefs.getString(Constantes.boiteSignalements);
      if (chaineJson != null) {
        final List<dynamic> listeDecodee = json.decode(chaineJson);
        _fileAttenteHorsLigne = listeDecodee
            .map((item) => _jsonVersModele(Map<String, dynamic>.from(item)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur de lecture de la file d\'attente locale : $e');
    }
  }

  // Sauvegarder la file d'attente hors-ligne localement
  Future<void> _sauvegarderFileAttenteLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listeJson = _fileAttenteHorsLigne.map((s) => _modeleVersJson(s)).toList();
      await prefs.setString(Constantes.boiteSignalements, json.encode(listeJson));
    } catch (e) {
      debugPrint('Erreur d\'écriture de la file d\'attente locale : $e');
    }
  }

  // Soumettre un signalement (soit direct, soit hors-ligne)
  Future<bool> soumettreSignalement(Map<String, dynamic> donneesFormulaire) async {
    _chargement = true;
    notifyListeners();

    // S'assurer de la connectivité réseau
    await verifierConnexion();

    if (_estEnLigne) {
      try {
        final resultat = await _serviceApi.soumettreSignalement(donneesFormulaire);
        final nouveauSignalement = _jsonVersModele(resultat);
        _signalements.insert(0, nouveauSignalement);
        _chargement = false;
        notifyListeners();
        return true;
      } catch (e) {
        // En cas d'erreur API, on bascule en sauvegarde locale (dégradé)
        debugPrint('Erreur soumission API. Bascule hors-ligne : $e');
      }
    }

    // Mode Hors-ligne / dégradé robuste
    final localId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
    final nouveauSignalementHorsLigne = ModeleSignalement(
      id: localId,
      nom: donneesFormulaire['nom'] ?? 'Inconnu',
      typeDocument: donneesFormulaire['typeDocument'] ?? 'CIN',
      lieu: donneesFormulaire['lieu'] ?? 'Non spécifié',
      date: 'En attente (hors-ligne)',
      statut: StatutSignalement.horsLigne,
      numeroDocument: donneesFormulaire['numeroDocument'],
      dateNaissance: donneesFormulaire['dateNaissance'],
      nationalite: donneesFormulaire['nationalite'],
      noteAgent: donneesFormulaire['noteAgent'],
    );

    _fileAttenteHorsLigne.add(nouveauSignalementHorsLigne);
    await _sauvegarderFileAttenteLocale();
    _chargement = false;
    notifyListeners();
    return false; // Renvoie false pour indiquer que c'est enregistré hors-ligne
  }

  // Lancer la synchronisation de la file d'attente
  Future<void> synchroniserFileAttente() async {
    if (_syncEnCours || _fileAttenteHorsLigne.isEmpty) return;

    _syncEnCours = true;
    _progressionSync = 0.0;
    notifyListeners();

    final total = _fileAttenteHorsLigne.length;
    final aSynchroniser = List<ModeleSignalement>.from(_fileAttenteHorsLigne);

    for (var i = 0; i < total; i++) {
      final item = aSynchroniser[i];
      
      // Simuler la synchronisation
      try {
        final donnees = _modeleVersJson(item);
        final resultat = await _serviceApi.soumettreSignalement(donnees);
        
        // Retirer de la file d'attente
        _fileAttenteHorsLigne.removeWhere((s) => s.id == item.id);
        
        // Ajouter à la liste synchronisée
        _signalements.insert(0, _jsonVersModele(resultat));
      } catch (e) {
        // Mettre en statut erreur si échec persistant
        final index = _fileAttenteHorsLigne.indexWhere((s) => s.id == item.id);
        if (index != -1) {
          _fileAttenteHorsLigne[index] = ModeleSignalement(
            id: item.id,
            nom: item.nom,
            typeDocument: item.typeDocument,
            lieu: item.lieu,
            date: item.date,
            statut: StatutSignalement.erreur,
            numeroDocument: item.numeroDocument,
            dateNaissance: item.dateNaissance,
            nationalite: item.nationalite,
            noteAgent: item.noteAgent,
          );
        }
      }

      _progressionSync = (i + 1) / total;
      notifyListeners();
    }

    await _sauvegarderFileAttenteLocale();
    _syncEnCours = false;
    _progressionSync = 1.0;
    notifyListeners();
  }

  // Simuler l'OCR sur une image
  Future<Map<String, dynamic>?> executerOcr(String imagePath) async {
    _chargement = true;
    notifyListeners();

    try {
      final resultatOcr = await _serviceApi.analyserDocument(imagePath);
      _chargement = false;
      notifyListeners();
      return resultatOcr;
    } catch (e) {
      _chargement = false;
      notifyListeners();
      return null;
    }
  }

  // ─── CONVERTISSEURS INTERNES ────────────────────────────────────
  ModeleSignalement _jsonVersModele(Map<String, dynamic> json) {
    StatutSignalement statut;
    switch (json['statut']) {
      case 'synchronise':
        statut = StatutSignalement.synchronise;
        break;
      case 'enCours':
        statut = StatutSignalement.enCours;
        break;
      case 'horsLigne':
        statut = StatutSignalement.horsLigne;
        break;
      case 'erreur':
      default:
        statut = StatutSignalement.erreur;
        break;
    }

    return ModeleSignalement(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      typeDocument: json['typeDocument'] ?? '',
      lieu: json['lieu'] ?? '',
      date: json['date'] ?? '',
      statut: statut,
      numeroDocument: json['numeroDocument'],
      dateNaissance: json['dateNaissance'],
      nationalite: json['nationalite'],
      noteAgent: json['noteAgent'],
    );
  }

  Map<String, dynamic> _modeleVersJson(ModeleSignalement s) {
    String statutStr;
    switch (s.statut) {
      case StatutSignalement.synchronise:
        statutStr = 'synchronise';
        break;
      case StatutSignalement.enCours:
        statutStr = 'enCours';
        break;
      case StatutSignalement.horsLigne:
        statutStr = 'horsLigne';
        break;
      case StatutSignalement.erreur:
        statutStr = 'erreur';
        break;
    }

    return {
      'id': s.id,
      'nom': s.nom,
      'typeDocument': s.typeDocument,
      'lieu': s.lieu,
      'date': s.date,
      'statut': statutStr,
      'numeroDocument': s.numeroDocument,
      'dateNaissance': s.dateNaissance,
      'nationalite': s.nationalite,
      'noteAgent': s.noteAgent,
    };
  }
}
