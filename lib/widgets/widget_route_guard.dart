import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider_authentification.dart';
import '../configuration/routes.dart';

class RouteGuard extends StatefulWidget {
  final Widget child;
  const RouteGuard({super.key, required this.child});

  @override
  State<RouteGuard> createState() => _RouteGuardState();
}

class _RouteGuardState extends State<RouteGuard> {
  @override
  void initState() {
    super.initState();
    _verifierAuth();
  }

  @override
  void didUpdateWidget(RouteGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _verifierAuth();
  }

  void _verifierAuth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = Provider.of<ProviderAuthentification>(context, listen: false);
      if (!auth.estConnecte) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.connexion,
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<ProviderAuthentification>(context);
    
    if (!auth.estConnecte) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4749CD),
          ),
        ),
      );
    }
    
    return widget.child;
  }
}
