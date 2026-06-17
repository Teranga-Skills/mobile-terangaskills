import 'package:flutter/material.dart';
import '../../configuration/theme.dart';

class WidgetChampTexte extends StatefulWidget {
  final String placeholder;
  final TextEditingController controller;
  final bool estMotDePasse;
  final IconData icone;
  final TextInputType clavier;
  final String? Function(String?)? validateur;

  const WidgetChampTexte({
    super.key,
    required this.placeholder,
    required this.controller,
    required this.icone,
    this.estMotDePasse = false,
    this.clavier = TextInputType.text,
    this.validateur,
  });

  @override
  State<WidgetChampTexte> createState() => _WidgetChampTexteState();
}

class _WidgetChampTexteState extends State<WidgetChampTexte> {
  String? _erreur;

  // Appelée par PageConnexion via la clé du Form
  void valider() {
    final msg = widget.validateur?.call(widget.controller.text);
    setState(() => _erreur = msg);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Champ : hauteur FIXE 50px toujours ─────────────────
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.clavier,
            obscureText: widget.estMotDePasse,
            validator: widget.validateur,
            // Pas d'autovalidation — on contrôle nous-mêmes
            autovalidateMode: AutovalidateMode.disabled,
            style: ThemeApplication.corpsMedium.copyWith(
              color: ThemeApplication.couleurTexte,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: ThemeApplication.corpsMedium.copyWith(
                color: ThemeApplication.couleurTexteSecondaire,
                fontWeight: FontWeight.w300,
              ),
              filled: true,
              fillColor: const Color(0x33C4C4C4),
              contentPadding: const EdgeInsets.only(left: 22, right: 16),
              // Erreur invisible dans le champ → affichée dessous
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: ThemeApplication.couleurPrimaire,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: ThemeApplication.couleurDanger,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: ThemeApplication.couleurDanger,
                  width: 1.5,
                ),
              ),
              suffixIcon: Icon(
                widget.icone,
                size: 20,
                color: _erreur != null
                    ? ThemeApplication.couleurDanger
                    : ThemeApplication.couleurTexteSecondaire,
              ),
            ),
            onChanged: (_) {
              // Efface l'erreur dès que l'utilisateur retape
              if (_erreur != null) setState(() => _erreur = null);
            },
          ),
        ),

        // ── Message d'erreur sous le champ — champ ne bouge pas ─
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _erreur != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 12,
                        color: ThemeApplication.couleurDanger,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _erreur!,
                        style: ThemeApplication.legende.copyWith(
                          color: ThemeApplication.couleurDanger,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
