// -----------------------------------------------------------------
// Widget : Bouton primaire réutilisable
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../configuration/theme.dart';

class WidgetBoutonPrimaire extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool estExpanse;
  final bool estSecondaire;

  const WidgetBoutonPrimaire({
    super.key,
    required this.label,
    required this.onTap,
    this.estExpanse = false,
    this.estSecondaire = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 50,
        width: estExpanse ? 180 : 50,
        decoration: BoxDecoration(
          color: estSecondaire
              ? ThemeApplication.couleurSurface
              : ThemeApplication.couleurTexte,
          borderRadius: BorderRadius.circular(25),
          border: estSecondaire
              ? Border.all(color: ThemeApplication.couleurBordure)
              : null,
        ),
        child: estExpanse
            ? Center(child: Text(label, style: ThemeApplication.labelBouton))
            : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: estSecondaire
                    ? ThemeApplication.couleurTexte
                    : ThemeApplication.blanc,
              ),
      ),
    );
  }
}