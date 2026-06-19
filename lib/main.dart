import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teranga_skills/configuration/theme.dart';
import 'package:teranga_skills/providers/provider_authentification.dart';
import 'package:teranga_skills/providers/provider_signalements.dart';
import 'configuration/routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProviderAuthentification()),
        ChangeNotifierProvider(create: (_) => ProviderSignalements()),
      ],
      child: const TerangaSkillsApp(),
    ),
  );
}

// ─── App Root ────────────────────────────────────────────────────────────────

class TerangaSkillsApp extends StatelessWidget {
  const TerangaSkillsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerangaSkills',
      debugShowCheckedModeBanner: false,
      theme: ThemeApplication.themeClair,
      darkTheme: ThemeApplication.themeSombre,
      initialRoute: Routes.splash, 
      routes: Routes.toutes,
    );
  }
}

