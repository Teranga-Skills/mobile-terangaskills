// -----------------------------------------------------------------
// Constantes globales : URL API, clés de stockage local, config
// -----------------------------------------------------------------

class Constantes {

  Constantes._();

  // ─── API ────────────────────────────────────────────────────────

  static const String urlBaseApi         = 'https://api.terangaskills.sn/api/v1';
  static const String endpointConnexion  = '/auth/login/';
  static const String endpointSignalements = '/signalements/';
  static const String endpointOcr        = '/ia/ocr/';
  static const String endpointScore      = '/ia/score/';
  static const int    timeoutSecondes    = 30;

  // ─── STOCKAGE LOCAL (Hive) ──────────────────────────────────────

  static const String boiteSignalements  = 'signalements_locaux';
  static const String boiteUtilisateur   = 'utilisateur';
  static const String cleToken           = 'jwt_token';
  static const String cleUtilisateur     = 'utilisateur_courant';

  // ─── ONBOARDING ─────────────────────────────────────────────────

  static const String cleOnboardingVu    = 'onboarding_vu';

  // ─── SYNCHRONISATION ────────────────────────────────────────────

  static const int intervalSyncSecondes  = 30;

  // ─── SCORE DE RISQUE ────────────────────────────────────────────

  static const int seuilScoreEleve       = 70;
  static const int seuilScoreMoyen       = 40;
}