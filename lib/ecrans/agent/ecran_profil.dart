import 'package:flutter/material.dart';
import '../../configuration/theme.dart';

class EcranProfil extends StatelessWidget {
  const EcranProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApplication.couleurFond,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ThemeApplication.couleurTexte,
        centerTitle: true,
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
              child: ClipOval(
                    child: Image.network(
                      'https://i.pravatar.cc/52',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF4060D0),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
            ),

            const SizedBox(height: 20),

            Text(
              'Moussa Ali Mchangama',
              textAlign: TextAlign.center,
              style: ThemeApplication.titrePrincipal.copyWith(
                fontSize: 24,
                color: ThemeApplication.couleurTexte,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Agent TerangaSkills',
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
                    'moussa@email.com',
                  ),
const SizedBox(height: 15),
                  

                  _infoTile(
                    Icons.phone_outlined,
                    'Téléphone',
                    '+221 77 000 00 00',
                  ),
                  const SizedBox(height: 15),

  
                  _infoTile(
                    Icons.location_on_outlined,
                    'Zone',
                    'Dakar-Plateau',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ───────────────── Statistiques ─────────────────
          
            const SizedBox(height: 30),

            // ───────────────── Modifier Profil ─────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  'Modifier le profil',
                  style: ThemeApplication.labelBouton,
                ),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 20),

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
                onPressed: () {
                  Navigator.pop(context);
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

  Widget _statCard(
    String valeur,
    String label,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: ThemeApplication.blanc,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ThemeApplication.couleurBordure,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: ThemeApplication.couleurPrimaire,
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            valeur,
            style: ThemeApplication.titrePrincipal.copyWith(
              fontSize: 24,
            ),
          ),
          Text(
            label,
            style: ThemeApplication.legende,
          ),
        ],
      ),
    );
  }
}