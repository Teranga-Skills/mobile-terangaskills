// ─────────────────────────────────────────────────────────────────
// ENTÊTE EXPANDED DYNAMIQUE (Collapsible)
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teranga_skills/configuration/theme.dart';
import 'package:teranga_skills/ecrans/agent/ecran_profil.dart';
import 'package:teranga_skills/providers/provider_authentification.dart';

class EnteteAgent extends StatelessWidget {
  final double t; // De 0.0 (complètement étendu) à 1.0 (complètement réduit)
  const EnteteAgent({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final authProvider = Provider.of<ProviderAuthentification>(context);
    final user = authProvider.utilisateurCourant;
    final prenom = user != null ? user.nom.split(' ').first : 'Agent';
    final zone = user != null ? user.zone : 'Zone inconnue';

    // Interpolation des styles
    final pt = (topPadding + 16) - (6 * t);
    final pb = 20.0 - (10.0 * t);
    final avatarSize = 52.0 - (16.0 * t);
    final borderWidth = 2.0 - (0.5 * t);
    final fontSize = 20.0 - (4.0 * t);
    final iconSize = 22.0 - (4.0 * t);

    return Container(
      color: ThemeApplication.couleurPrimaire,
      padding: EdgeInsets.only(
        top: pt,
        left: 20,
        right: 20,
        bottom: pb,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar + nom + zone
          Expanded(
            child: Row(
              children: [
                // Avatar
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: borderWidth,
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
                      child: Container(
                        color: ThemeApplication.couleurPrimaire,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: avatarSize * 0.6,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bonjour, $prenom',
                        style: ThemeApplication.titrePrincipal.copyWith(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (t < 0.8) ...[
                        const SizedBox(height: 4),
                        Opacity(
                          opacity: (1.0 - t / 0.8).clamp(0.0, 1.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Color(0xCCD0D0FF),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  zone,
                                  style: ThemeApplication.legende.copyWith(
                                    color: const Color(0xCCD0D0FF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
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
                          subtitle: Text("Un scan a été synchronisé"),
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
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: iconSize,
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
            ),
          ),
        ],
      ),
    );
  }
}
