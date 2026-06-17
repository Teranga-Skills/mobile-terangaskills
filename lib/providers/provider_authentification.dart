// -----------------------------------------------------------------
// Provider : Authentification
// Gère l'état de session de l'agent connecté.
// -----------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/modele_utilisateur.dart';
import '../services/service_api.dart';
import '../configuration/constantes.dart';

class ProviderAuthentification extends ChangeNotifier {
  final ServiceApi _serviceApi = ServiceApi();
  
  ModeleUtilisateur? _utilisateurCourant;
  bool _chargement = false;
  String? _erreur;

  ModeleUtilisateur? get utilisateurCourant => _utilisateurCourant;
  bool get estConnecte => _utilisateurCourant != null;
  bool get chargement => _chargement;
  String? get erreur => _erreur;

  ProviderAuthentification() {
    chargerSession();
  }

  // Charger la session persistée localement
  Future<void> chargerSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(Constantes.cleUtilisateur);
      if (userJsonString != null) {
        final Map<String, dynamic> userMap = json.decode(userJsonString);
        _utilisateurCourant = ModeleUtilisateur.fromJson(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de la session utilisateur : $e');
    }
  }

  // Connexion
  Future<bool> seConnecter(String email, String password) async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    try {
      final userMap = await _serviceApi.seConnecter(email, password);
      _utilisateurCourant = ModeleUtilisateur.fromJson(userMap);
      
      // Persister en local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constantes.cleUtilisateur, json.encode(userMap));
      await prefs.setString(Constantes.cleToken, _utilisateurCourant!.token);

      _chargement = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erreur = e.toString().replaceAll('Exception: ', '');
      _chargement = false;
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> seDeconnecter() async {
    _utilisateurCourant = null;
    _erreur = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constantes.cleUtilisateur);
      await prefs.remove(Constantes.cleToken);
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion : $e');
    }
  }
}
