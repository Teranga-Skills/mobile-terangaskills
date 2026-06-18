// -----------------------------------------------------------------
// Modèle : Utilisateur / Agent connecté
// -----------------------------------------------------------------

class ModeleUtilisateur {
  final String nom;
  final String email;
  final String role;
  final String zone;
  final String telephone;
  final String token;

  const ModeleUtilisateur({
    required this.nom,
    required this.email,
    required this.role,
    required this.zone,
    required this.telephone,
    required this.token,
  });

  factory ModeleUtilisateur.fromJson(Map<String, dynamic> json) {
    return ModeleUtilisateur(
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      zone: json['zone'] ?? '',
      telephone: json['telephone'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'email': email,
      'role': role,
      'zone': zone,
      'telephone': telephone,
      'token': token,
    };
  }
}
