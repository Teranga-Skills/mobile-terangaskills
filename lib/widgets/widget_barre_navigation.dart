// -----------------------------------------------------------------
// Widget : Bottom Navigation Bar fixe avec bouton scan central
// -----------------------------------------------------------------

import 'package:flutter/material.dart';
import '../configuration/theme.dart';
import '../configuration/routes.dart';

class _ItemNavData {
  final IconData icone;
  final IconData iconeActif;
  final String label;

  const _ItemNavData({
    required this.icone,
    required this.iconeActif,
    required this.label,
  });
}

class WidgetBarreNavigation extends StatelessWidget {
  final int indexCourant;
  final ValueChanged<int> onTap;
  final VoidCallback? onScanTap;

  const WidgetBarreNavigation({
    super.key,
    required this.indexCourant,
    required this.onTap,
    this.onScanTap,
  });

  static const _items = [
    _ItemNavData(
      icone: Icons.home_outlined,
      iconeActif: Icons.home_rounded,
      label: 'Accueil',                        
    ),
    _ItemNavData(
      icone: Icons.list_alt_outlined,        
      iconeActif: Icons.list_alt_rounded,
      label: 'Signals',             
    ),
    _ItemNavData(
      icone: Icons.notifications_outlined,
      iconeActif: Icons.notifications_rounded,
      label: 'Notifs',
    ),
    _ItemNavData(
      icone: Icons.settings_outlined,
      iconeActif: Icons.settings_rounded,
      label: 'Réglages',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(context, 0),
              _buildItem(context, 1),

              // ── Bouton SCAN central surélevé ──────────────────
              GestureDetector(
                onTap: onScanTap,
                child: Container(
                  width: 58,
                  height: 58,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: ThemeApplication.couleurPrimaire,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x664749CD),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),

              _buildItem(context, 2),
              _buildItem(context, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final itemIndex = index < 2 ? index : index + 1;
    final estActif = indexCourant == itemIndex;
    final item = _items[index];

    return GestureDetector(
      onTap: () {
        // ── Navigation selon l'index ──────────────────────────
        switch (itemIndex) {
          case 0:
            Navigator.pushReplacementNamed(context, Routes.accueilAgent);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, Routes.mesSignalements);
            break;
          default:
            onTap(itemIndex);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              estActif ? item.iconeActif : item.icone,
              size: 24,
              color: estActif
                  ? ThemeApplication.couleurPrimaire
                  : const Color(0xFF888888),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Montserrat',
                fontWeight: estActif ? FontWeight.w600 : FontWeight.w400,
                color: estActif
                    ? ThemeApplication.couleurPrimaire
                    : const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

