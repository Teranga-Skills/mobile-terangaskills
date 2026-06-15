import 'package:flutter/material.dart';
import 'package:teranga_skills/configuration/theme.dart';
import 'package:teranga_skills/ecrans/ecran_onboarding.dart';
import 'configuration/routes.dart';

void main() {
  runApp(const TerangaSkillsApp());
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
      
       routes: Routes.toutes,
    );
  }
}

