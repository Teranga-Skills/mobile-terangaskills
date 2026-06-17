// -----------------------------------------------------------------
// Définition centralisée des routes nommées
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:teranga_skills/ecrans/agent/ecran_profil.dart';
import 'package:teranga_skills/ecrans/agent/ecrant_sync.dart';
import '../ecrans/splash/ecran_splash.dart';
import '../ecrans/authentification/ecran_connexion.dart';
import '../ecrans/agent/ecran_accueil_agent.dart';
import '../ecrans/agent/ecran_nouveau_signalement.dart';
import '../ecrans/agent/ecran_camera_document.dart';
import '../ecrans/agent/ecran_mes_signalements.dart';
import '../ecrans/ecran_onboarding.dart';


class Routes {
  Routes._();

  static const String splash        = '/';       
  static const String onboarding    = '/onboarding';
  static const String connexion = '/connexion';
  static const String accueilAgent = '/agent/accueil';
  static const String nouveauSignalement = '/agent/signalement/nouveau';
  static const String cameraDocument = '/agent/signalement/camera';
  static const String mesSignalements = '/agent/signalements';
  
static const String synchronisation = '/agent/sync';

  static Map<String, WidgetBuilder> get toutes => {
    splash:       (_) => const EcranSplash(),   
    onboarding: (_) => const EcranOnboarding(),
    connexion: (_) => const PageConnexion(),
    accueilAgent:(_) => const EcranAccueilAgent(),
    '/profile': (_) => const EcranProfil(),
    mesSignalements: (_) => const EcranMesSignalements(),
    synchronisation: (_) => const EcranSynchronisation(),
    nouveauSignalement: (_) => const EcranNouveauSignalement(),
    cameraDocument: (_) => const EcranCameraDocument(),
  };
}