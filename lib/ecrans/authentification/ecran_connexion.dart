import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../configuration/routes.dart';
import '../../configuration/theme.dart';
import '../../providers/provider_authentification.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<ProviderAuthentification>(context, listen: false);
    final succes = await authProvider.seConnecter(
      _emailController.text.trim(),
      _motDePasseController.text,
    );

    if (!mounted) return;

    if (succes) {
      Navigator.pushReplacementNamed(context, Routes.accueilAgent);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.erreur ?? 'Erreur de connexion',
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: ThemeApplication.couleurDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<ProviderAuthentification>(context);

    return Scaffold(
      backgroundColor: ThemeApplication.couleurFondSombre,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            color: ThemeApplication.couleurFond,
            padding: const EdgeInsets.only(
              top: 100,
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
                        'Teranga Scan',
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

                  const SizedBox(height: 80),

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

                  const SizedBox(height: 100),

                  // ── BOUTON + VERSION ──────────────────────────
                  Column(
                    children: [
                      GestureDetector(
                        onTap: authProvider.chargement ? null : _seConnecter,
                        child: Container(
                          width: 300,
                          height: 50,
                          decoration: ShapeDecoration(
                            color: ThemeApplication.couleurPrimaire,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: authProvider.chargement
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
                              .withOpacity(0.5),
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

