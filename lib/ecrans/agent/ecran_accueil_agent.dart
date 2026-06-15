import 'package:flutter/material.dart';

class AcceuilAgent extends StatefulWidget {
  const AcceuilAgent({super.key});

  @override
  State<AcceuilAgent> createState() => _AcceuilAgentState();
}

class _AcceuilAgentState extends State<AcceuilAgent> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: (
        Text('Bienvenue a l\'accueil')
    ),
    );
  }
}