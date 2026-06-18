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


import 'package:teranga_skills/widgets/widget_route_guard.dart';

class Routes {
  Routes._();

  static const String splash        = '/';       
  static const String onboarding    = '/onboarding';
  static const String connexion = '/connexion';
  static const String accueilAgent = '/agent/accueil';
  static const String nouveauSignalement = '/agent/signalement/nouveau';
  static const String cameraDocument = '/agent/signalement/camera';
  static const String mesSignalements = '/agent/signalements';
  static const String profilAgent = '/agent/profil';

static const String synchronisation = '/agent/sync';

  static Map<String, WidgetBuilder> get toutes => {
    splash:       (_) => const EcranSplash(),   
    onboarding: (_) => const EcranOnboarding(),
    connexion: (_) => const PageConnexion(),
    accueilAgent:(_) => const RouteGuard(child: EcranAccueilAgent()),
    profilAgent: (_) => const RouteGuard(child: EcranProfil()),
    mesSignalements: (_) => const RouteGuard(child: EcranMesSignalements()),
    synchronisation: (_) => const RouteGuard(child: EcranSynchronisation()),
    nouveauSignalement: (_) => const RouteGuard(child: EcranNouveauSignalement()),
    cameraDocument: (_) => const RouteGuard(child: EcranCameraDocument()),
  };
}