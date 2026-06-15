import 'package:flutter/material.dart';
import '../../configuration/routes.dart';
import '../../configuration/theme.dart';
import '../../widgets/widget_champ_texte.dart';

class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  bool _sesouvenir = false;
  bool _chargement = false;

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _chargement = true);
    await Future.delayed(const Duration(seconds: 2)); // TODO : appel API
    setState(() => _chargement = false);

    if (!mounted) return;

    // ── Utilise la constante de Routes ─────────────────────────
    Navigator.pushReplacementNamed(context, Routes.accueilAgent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Fond sombre du thème ────────────────────────────────
      backgroundColor: ThemeApplication.couleurFondSombre,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // ── Pas d'arrondi — fond blanc plein écran ─────────
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            color: ThemeApplication.couleurFond,
            padding: const EdgeInsets.only(
              top: 180,
              left: 30,
              right: 30,
              bottom: 56,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // ── TITRE ─────────────────────────────────────
                  Column(
                    children: [
                      Text(
                        'DetectSen',
                        textAlign: TextAlign.center,
                        style: ThemeApplication.titrePrincipal.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF252525),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Vigilance Citoyenne Assistée",
                        textAlign: TextAlign.center,
                        style: ThemeApplication.corpsMedium.copyWith(
                          color: const Color(0xFF252525),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 135),

                  // ── CHAMPS ────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetChampTexte(
                        placeholder: 'example@gmail.com',
                        controller: _emailController,
                        icone: Icons.mail_outline,
                        clavier: TextInputType.emailAddress,
                        validateur: (v) {
                          if (v == null || v.isEmpty) return 'Champ requis';
                          if (!v.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      WidgetChampTexte(
                        placeholder: 'Mot de passe',
                        controller: _motDePasseController,
                        icone: Icons.lock_outline,
                        estMotDePasse: true,
                        validateur: (v) {
                          if (v == null || v.isEmpty) return 'Champ requis';
                          if (v.length < 6) return 'Minimum 6 caractères';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Se souvenir / Mot de passe oublié ─────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: Checkbox(
                                  value: _sesouvenir,
                                  onChanged: (v) => setState(
                                    () => _sesouvenir = v ?? false,
                                  ),
                                  activeColor: ThemeApplication.couleurPrimaire,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  side: BorderSide(
                                    color: ThemeApplication.couleurBordure,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Se souvenir de moi',
                                style: ThemeApplication.legende.copyWith(
                                  fontSize: 9,
                                  color: const Color(0xFF252525),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO : navigation mot de passe oublié
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: ThemeApplication.legende.copyWith(
                                fontSize: 9,
                                color: ThemeApplication.couleurPrimaire,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 135),

                  // ── BOUTON + VERSION ──────────────────────────
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _chargement ? null : _seConnecter,
                        child: Container(
                          width: 300,
                          height: 50,
                          decoration: ShapeDecoration(
                            color: ThemeApplication.couleurPrimaire,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _chargement
                              ? const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Me Connecter',
                                      style: ThemeApplication.labelBouton
                                          .copyWith(fontSize: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 54),

                      Text(
                        'version 1.0.1',
                        textAlign: TextAlign.center,
                        style: ThemeApplication.legende.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: ThemeApplication.couleurTexte
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

