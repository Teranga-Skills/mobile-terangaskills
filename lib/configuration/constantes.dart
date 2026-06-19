// -----------------------------------------------------------------
// Constantes globales : URL API, clés de stockage local, config
// -----------------------------------------------------------------

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class Constantes {

  Constantes._();

  // ─── API (local par défaut) ─────────────────────────────────────

  /// Surcharge manuelle pour téléphone physique (ex. `http://192.168.1.10:8000`).
  /// Laisser `null` pour la détection automatique émulateur / bureau.
  static const String? urlApiOverride = null;

  /// Émulateur Android → 10.0.2.2 ; iOS / Windows / Linux → 127.0.0.1
  static String get urlBaseApi {
    if (urlApiOverride != null && urlApiOverride!.isNotEmpty) {
      return urlApiOverride!;
    }
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://192.168.222.81:8000';
    return 'http://127.0.0.1:8000';
  }

  static const String endpointConnexion  = '/api/v1/auth/login/';
  static const String endpointDeconnexion = '/api/v1/auth/logout/';
  static const String endpointSignalements = '/api/actes/';
  static const String endpointCitoyens   = '/api/citoyens/';
  static const String endpointCentres    = '/api/centres/';
  static const String endpointOcr        = '/api/scan/';
  static const String endpointAnalyse    = '/api/analyse/';
  static const int    timeoutSecondes    = 30;

  // ─── STOCKAGE LOCAL (Hive) ──────────────────────────────────────

  static const String boiteSignalements  = 'signalements_locaux';
  static const String boiteUtilisateur   = 'utilisateur';
  static const String cleToken           = 'jwt_token';
  static const String cleRefreshToken    = 'jwt_refresh_token';
  static const String cleUtilisateur     = 'utilisateur_courant';

  // ─── ONBOARDING ─────────────────────────────────────────────────

  static const String cleOnboardingVu    = 'onboarding_vu';

  // ─── SYNCHRONISATION ────────────────────────────────────────────

  static const int intervalSyncSecondes  = 30;

  // ─── SCORE DE RISQUE ────────────────────────────────────────────

  static const int seuilScoreEleve       = 70;
  static const int seuilScoreMoyen       = 40;
}
