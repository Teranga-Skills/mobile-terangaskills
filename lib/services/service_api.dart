// -----------------------------------------------------------------
// Service API : Centralise les appels vers le serveur.
// Simule les appels via data.json pour le prototypage.
// -----------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ServiceApi {
  // Instance unique pour Singleton
  static final ServiceApi _instance = ServiceApi._internal();
  factory ServiceApi() => _instance;
  ServiceApi._internal();

  // Cache en mémoire des données de simulation
  Map<String, dynamic>? _donneesMock;

  // Charger le fichier JSON local
  Future<Map<String, dynamic>> _chargerDonneesMock() async {
    if (_donneesMock != null) return _donneesMock!;
    try {
      final String contenu = await rootBundle.loadString('assets/data.json');
      _donneesMock = json.decode(contenu);
      return _donneesMock!;
    } catch (e) {
      throw Exception('Erreur de chargement des données mock : $e');
    }
  }

  // ─── AUTHENTIFICATION ───────────────────────────────────────────
  Future<Map<String, dynamic>> seConnecter(String email, String motDePasse) async {
    // Simulation du délai réseau
    await Future.delayed(const Duration(seconds: 1));

    final donnees = await _chargerDonneesMock();
    final utilisateurs = donnees['utilisateurs'] as List<dynamic>;

    for (final u in utilisateurs) {
      if (u['email'] == email && u['motDePasse'] == motDePasse) {
        return Map<String, dynamic>.from(u);
      }
    }
    throw Exception('Identifiants incorrects. Veuillez réessayer.');
  }

  // ─── SIGNALEMENTS ──────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getSignalements() async {
    // Simulation du délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    final donnees = await _chargerDonneesMock();
    final signalements = donnees['signalements'] as List<dynamic>;
    
    return signalements.map((s) => Map<String, dynamic>.from(s)).toList();
  }

  // Soumission d'un nouveau signalement
  Future<Map<String, dynamic>> soumettreSignalement(Map<String, dynamic> signalementJson) async {
    // Simulation du délai réseau
    await Future.delayed(const Duration(seconds: 2));
    
    // Simuler le succès en renvoyant le signalement avec un ID généré et le statut synchronisé
    final nouveauSignalement = Map<String, dynamic>.from(signalementJson);
    nouveauSignalement['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    nouveauSignalement['date'] = "À l'instant";
    nouveauSignalement['statut'] = "synchronise";
    
    return nouveauSignalement;
  }

  // ─── OCR & ANALYSE IA ───────────────────────────────────────────
  Future<Map<String, dynamic>> analyserDocument(String cheminImage) async {
    // Simulation du temps de traitement par un modèle LLM (GPT-4o/Claude)
    await Future.delayed(const Duration(seconds: 3));

    final donnees = await _chargerDonneesMock();
    return Map<String, dynamic>.from(donnees['ocr_simulation']);
  }
}
