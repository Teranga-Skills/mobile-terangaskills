// ─────────────────────────────────────────────────────────────────
// ENTÊTE EXPANDED
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:teranga_skills/configuration/theme.dart';
import 'package:teranga_skills/ecrans/agent/ecran_profil.dart';

class EnteteAgent extends StatelessWidget {
  const EnteteAgent({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: ThemeApplication.couleurPrimaire,
      padding: EdgeInsets.only(
        top: topPadding + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar + nom + zone
          Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, animation, _) => const EcranProfil(),
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
                  },
                  child: ClipOval(
                    child: Image.network(
                      'https://i.pravatar.cc/52',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF4060D0),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bonjour, Moussa',
                    style: ThemeApplication.titrePrincipal.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xCCD0D0FF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Dakar-Plateau',
                        style: ThemeApplication.legende.copyWith(
                          color: const Color(0xCCD0D0FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
  onTap: () {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [

              const SizedBox(height: 16),

              // petite barre
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: ThemeApplication.couleurPrimaire,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Notifications",
                style: ThemeApplication.titrePrincipal.copyWith(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              const ListTile(
                leading: Icon(Icons.notifications),
                title: Text("Nouvelle activité"),
                subtitle: Text("Un scan  a été synchronisé"),
              ),

              const ListTile(
                leading: Icon(Icons.notifications),
                title: Text("Mise à jour"),
                subtitle: Text("Ton profil a été mis à jour"),
              ),
            ],
          ),
        );
      },
    );
  },
  child: Stack(
  clipBehavior: Clip.none,
  children: [
    const Icon(
      Icons.notifications_outlined,
      color: Colors.white,
      size: 22,
    ),

    Positioned(
      right: -2,
      top: -2,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFFFF4757),
          shape: BoxShape.circle,
        ),
      ),
    ),
  ],
)
),
          // Bouton notification
         ],
      ),
    );
  }
}
