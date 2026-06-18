import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../configuration/theme.dart';
import '../../../configuration/routes.dart';
import '../../../providers/provider_authentification.dart';

class EcranSplash extends StatefulWidget {
  const EcranSplash({super.key});

  @override
  State<EcranSplash> createState() => _EcranSplashState();
}

class _EcranSplashState extends State<EcranSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ── Animation fade + scale du logo ─────────────────────────
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // ── Redirection après 3 secondes avec vérification session ──
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final auth = Provider.of<ProviderAuthentification>(context, listen: false);
      if (auth.estConnecte) {
        Navigator.pushReplacementNamed(context, Routes.accueilAgent);
      } else {
        Navigator.pushReplacementNamed(context, Routes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApplication.couleurPrimaire,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo / icône ──────────────────────────────
                // Container(
                //   width: 80,
                //   height: 80,
                //   // decoration: BoxDecoration(
                //   //   color: Colors.white.withValues(alpha: 0.2),
                //   //   borderRadius: BorderRadius.circular(20),
                //   // ),
                //   // child: const Icon(
                //   //   Icons.search, // TODO : remplace par ton vrai logo
                //   //   color: Colors.white,
                //   //   size: 40,
                //   // ),
                // ),

                const SizedBox(height: 16),

                // ── Nom de l'app ──────────────────────────────
                const Text(
                  'DetectSen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // ── Tagline optionnelle ───────────────────────
                // Text(
                //   'Signaler. Détecter. Agir.',
                //   style: TextStyle(
                //     color: Colors.white.withValues(alpha: 0.75),
                //     fontSize: 13,
                //     fontFamily: 'Montserrat',
                //     fontWeight: FontWeight.w300,
                //     letterSpacing: 0.5,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

