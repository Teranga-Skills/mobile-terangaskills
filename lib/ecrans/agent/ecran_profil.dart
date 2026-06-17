import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../configuration/theme.dart';
import '../../configuration/routes.dart';
import '../../providers/provider_authentification.dart';

class EcranProfil extends StatelessWidget {
  const EcranProfil({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<ProviderAuthentification>(context);
    final user = authProvider.utilisateurCourant;

    final nom = user?.nom ?? 'Agent de terrain';
    final role = user?.role ?? 'Agent TerangaSkills';
    final email = user?.email ?? 'non-specifie@email.com';
    final telephone = user?.telephone ?? 'Non spécifié';
    final zone = user?.zone ?? 'Zone inconnue';

    // Générer les initiales
    String initiales = 'AG';
    if (user != null && user.nom.isNotEmpty) {
      final parts = user.nom.trim().split(' ');
      if (parts.length >= 2) {
        initiales = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initiales = user.nom.substring(0, 2).toUpperCase();
      }
    }

    return Scaffold(
      backgroundColor: ThemeApplication.couleurFond,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ThemeApplication.couleurTexte,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pushReplacementNamed(context, Routes.accueilAgent),
        ),
        title: Text(
          'Mon Profil',
          style: ThemeApplication.titrePrincipal.copyWith(
            fontSize: 22,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ───────────────── Avatar ─────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeApplication.couleurPrimaire,
                  width: 3,
                ),
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF4060D0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initiales,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              nom,
              textAlign: TextAlign.center,
              style: ThemeApplication.titrePrincipal.copyWith(
                fontSize: 24,
                color: ThemeApplication.couleurTexte,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              role,
              style: ThemeApplication.corpsMedium,
            ),

            const SizedBox(height: 30),

            // ───────────────── Carte infos ─────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeApplication.blanc,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: ThemeApplication.couleurBordure,
                ),
              ),
              child: Column(
                children: [
                  _infoTile(
                    Icons.email_outlined,
                    'Email',
                    email,
                  ),
                  const SizedBox(height: 15),

                  _infoTile(
                    Icons.phone_outlined,
                    'Téléphone',
                    telephone,
                  ),
                  const SizedBox(height: 15),

                  _infoTile(
                    Icons.location_on_outlined,
                    'Zone',
                    zone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ───────────────── Déconnexion ─────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.logout,
                  color: ThemeApplication.couleurDanger,
                ),
                label: Text(
                  'Déconnexion',
                  style: ThemeApplication.labelSecondaire.copyWith(
                    color: ThemeApplication.couleurDanger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  side: const BorderSide(
                    color: ThemeApplication.couleurDanger,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: () async {
                  await authProvider.seDeconnecter();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.connexion,
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String titre,
    String valeur,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: ThemeApplication.couleurPrimaire.withOpacity(.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: ThemeApplication.couleurPrimaire,
        ),
      ),
      title: Text(
        titre,
        style: ThemeApplication.labelSecondaire.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        valeur,
        style: ThemeApplication.corpsMedium.copyWith(
          color: ThemeApplication.couleurTexte,
        ),
      ),
    );
  }
}