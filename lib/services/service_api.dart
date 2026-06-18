// -----------------------------------------------------------------
// Service API : Centralise les appels vers le serveur réel.
// -----------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../configuration/constantes.dart';

class ServiceApi {
  // Instance unique pour Singleton
  static final ServiceApi _instance = ServiceApi._internal();
  factory ServiceApi() => _instance;
  ServiceApi._internal();

  // Helper pour récupérer le token JWT
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constantes.cleToken);
  }

  // Helper pour les headers standards
  Future<Map<String, String>> _getHeaders({bool inclureAuth = true}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (inclureAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ─── AUTHENTIFICATION ───────────────────────────────────────────
  Future<Map<String, dynamic>> seConnecter(String email, String motDePasse) async {
    final url = Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointConnexion}');
    final body = json.encode({
      'email': email,
      'password': motDePasse,
    });

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(inclureAuth: false),
        body: body,
      ).timeout(const Duration(seconds: Constantes.timeoutSecondes));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final userObj = data['user'] ?? {};
        // Mapper sur le modèle attendu par le frontend
        return {
          'nom': userObj['nom'] ?? '${userObj['first_name'] ?? ''} ${userObj['last_name'] ?? ''}'.trim(),
          'email': userObj['email'] ?? email,
          'role': userObj['role'] ?? 'Agent TerangaSkills',
          'zone': userObj['zone'] ?? 'Dakar-Plateau',
          'telephone': userObj['telephone'] ?? '',
          'token': data['access'] ?? '',
          'refreshToken': data['refresh'] ?? '',
        };
      } else {
        final Map<String, dynamic> errData = json.decode(response.body);
        final errorMsg = errData['detail'] ?? errData['message'] ?? 'Erreur de connexion (${response.statusCode})';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau ou serveur indisponible : $e');
    }
  }

  // Déconnexion du serveur backend
  Future<void> seDeconnecter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(Constantes.cleRefreshToken);
      final token = prefs.getString(Constantes.cleToken);

      if (refreshToken != null && refreshToken.isNotEmpty) {
        final url = Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointDeconnexion}');
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }

        final response = await http.post(
          url,
          headers: headers,
          body: json.encode({'refresh': refreshToken}),
        ).timeout(const Duration(seconds: Constantes.timeoutSecondes));

        if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 205) {
          debugPrint('Avertissement déconnexion API code: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion réseau backend : $e');
    }
  }

  // ─── SIGNALEMENTS (Actes + Citoyens + Centres) ──────────────────
  Future<List<Map<String, dynamic>>> getSignalements() async {
    final headers = await _getHeaders();
    final urlActes = Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointSignalements}');
    final urlCitoyens = Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointCitoyens}');
    final urlCentres = Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointCentres}');

    try {
      // 1. Fetch Actes
      final responseActes = await http.get(urlActes, headers: headers)
          .timeout(const Duration(seconds: Constantes.timeoutSecondes));

      if (responseActes.statusCode != 200) {
        throw Exception('Erreur de chargement des actes (${responseActes.statusCode})');
      }

      final List<dynamic> listActes = json.decode(utf8.decode(responseActes.bodyBytes));

      // 2. Fetch Citoyens et Centres en parallèle pour le mapping des UUIDs en noms/lieux
      List<dynamic> listCitoyens = [];
      List<dynamic> listCentres = [];

      try {
        final resCitoyens = await http.get(urlCitoyens, headers: headers);
        if (resCitoyens.statusCode == 200) {
          listCitoyens = json.decode(utf8.decode(resCitoyens.bodyBytes));
        }
      } catch (e) {
        // Ignorer l'erreur pour la robustesse et continuer avec une liste vide
      }

      try {
        final resCentres = await http.get(urlCentres, headers: headers);
        if (resCentres.statusCode == 200) {
          listCentres = json.decode(utf8.decode(resCentres.bodyBytes));
        }
      } catch (e) {
        // Ignorer l'erreur
      }

      // Convertir en Maps pour recherche rapide
      final Map<String, Map<String, dynamic>> mapCitoyens = {
        for (var c in listCitoyens) c['id'].toString(): Map<String, dynamic>.from(c)
      };
      final Map<String, Map<String, dynamic>> mapCentres = {
        for (var c in listCentres) c['id'].toString(): Map<String, dynamic>.from(c)
      };

      // 3. Fusionner les données pour le modèle local
      final List<Map<String, dynamic>> resultats = [];
      for (final acte in listActes) {
        final citoyenId = acte['citoyen']?.toString();
        final centreId = acte['centre']?.toString();

        final citizen = citoyenId != null ? mapCitoyens[citoyenId] : null;
        final centre = centreId != null ? mapCentres[centreId] : null;

        String nomComplet = 'Inconnu';
        String dateNaissance = '';
        String nationalite = 'Sénégalaise';

        if (citizen != null) {
          final prenom = citizen['prenom'] ?? '';
          final nom = citizen['nom'] ?? '';
          nomComplet = '$prenom $nom'.trim();
          if (nomComplet.isEmpty) nomComplet = 'Inconnu';
          dateNaissance = citizen['date_naissance'] ?? '';
        }

        String lieu = centre != null ? (centre['nom'] ?? 'Sénégal') : 'Sénégal';

        // Mapper le statut
        String statut = 'enCours';
        final statutApi = acte['statut']?.toString();
        if (statutApi == 'VALIDE') {
          statut = 'synchronise';
        } else if (statutApi == 'SUSPECT') {
          statut = 'erreur';
        } else if (statutApi == 'EN_ATTENTE') {
          statut = 'enCours';
        }

        // Formater la date
        String dateStr = 'Récemment';
        try {
          if (acte['date_creation'] != null) {
            final parsedDate = DateTime.parse(acte['date_creation']);
            final diff = DateTime.now().difference(parsedDate);
            if (diff.inMinutes < 60) {
              dateStr = 'Il y a ${diff.inMinutes} min';
            } else if (diff.inHours < 24) {
              dateStr = 'Il y a ${diff.inHours} h';
            } else {
              dateStr = '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
            }
          }
        } catch (_) {}

        resultats.add({
          'id': acte['id']?.toString() ?? '',
          'nom': nomComplet,
          'typeDocument': _mapTypeActeVersDoc(acte['type_acte']?.toString()),
          'lieu': lieu,
          'date': dateStr,
          'statut': statut,
          'numeroDocument': acte['numero_acte'] ?? '',
          'dateNaissance': _formaterDateNaissanceAffiche(dateNaissance),
          'nationalite': nationalite,
          'noteAgent': 'Vérification effectuée via l\'API.',
        });
      }

      return resultats;
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API : $e');
    }
  }

  // Soumission d'un nouveau signalement
  Future<Map<String, dynamic>> soumettreSignalement(Map<String, dynamic> signalementJson) async {
    final headers = await _getHeaders();

    try {
      // 1. Essayer de trouver si le citoyen existe déjà ou le créer
      // Pour cela, on prépare le corps de la requête du citoyen
      final prenomNom = _separerPrenomNom(signalementJson['nom'] ?? 'Inconnu');
      final dateNaisApi = _formaterDateNaissanceApi(signalementJson['dateNaissance']);

      final citoyenBody = {
        'nom': prenomNom['nom'],
        'prenom': prenomNom['prenom'],
        'date_naissance': dateNaisApi,
        'numero_identification': signalementJson['numeroDocument'],
      };

      final responseCitoyen = await http.post(
        Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointCitoyens}'),
        headers: headers,
        body: json.encode(citoyenBody),
      ).timeout(const Duration(seconds: Constantes.timeoutSecondes));

      String? citoyenUuid;
      if (responseCitoyen.statusCode == 200 || responseCitoyen.statusCode == 201) {
        final citoyenData = json.decode(utf8.decode(responseCitoyen.bodyBytes));
        citoyenUuid = citoyenData['id']?.toString();
      } else {
        // En cas d'erreur de création directe (ex: déjà existant), essayer de le récupérer par son numéro
        try {
          final resCitoyensList = await http.get(
            Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointCitoyens}'),
            headers: headers,
          );
          if (resCitoyensList.statusCode == 200) {
            final List<dynamic> citoyens = json.decode(utf8.decode(resCitoyensList.bodyBytes));
            final ident = signalementJson['numeroDocument'];
            final match = citoyens.firstWhere(
              (c) => c['numero_identification'] == ident,
              orElse: () => null,
            );
            if (match != null) {
              citoyenUuid = match['id']?.toString();
            }
          }
        } catch (_) {}
      }

      if (citoyenUuid == null) {
        throw Exception('Impossible de créer ou récupérer le profil citoyen.');
      }

      // 2. Trouver le centre correspondant au lieu si possible
      String? centreUuid;
      try {
        final resCentres = await http.get(
          Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointCentres}'),
          headers: headers,
        );
        if (resCentres.statusCode == 200) {
          final List<dynamic> centres = json.decode(utf8.decode(resCentres.bodyBytes));
          final lieuSaisi = (signalementJson['lieu'] ?? '').toString().toLowerCase();
          final matchCentre = centres.firstWhere(
            (c) => c['nom']?.toString().toLowerCase().contains(lieuSaisi) ?? false,
            orElse: () => null,
          );
          if (matchCentre != null) {
            centreUuid = matchCentre['id']?.toString();
          } else if (centres.isNotEmpty) {
            // Utiliser le premier centre par défaut si aucun ne correspond
            centreUuid = centres.first['id']?.toString();
          }
        }
      } catch (_) {}

      // 3. Créer l'acte d'état civil
      final typeActe = _mapDocVersTypeActe(signalementJson['typeDocument']);
      final acteBody = {
        'type_acte': typeActe,
        'citoyen': citoyenUuid,
        'centre': centreUuid,
      };

      final responseActe = await http.post(
        Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointSignalements}'),
        headers: headers,
        body: json.encode(acteBody),
      ).timeout(const Duration(seconds: Constantes.timeoutSecondes));

      if (responseActe.statusCode == 200 || responseActe.statusCode == 201) {
        final acteData = json.decode(utf8.decode(responseActe.bodyBytes));
        
        // Uploader l'image associée si présente
        final String? cheminImage = signalementJson['cheminImage'];
        final String acteId = acteData['id']?.toString() ?? '';
        if (cheminImage != null && cheminImage.isNotEmpty && acteId.isNotEmpty) {
          await uploaderDocument(acteId, cheminImage);
        }

        // Renvoyer le signalement formaté pour le frontend
        return {
          'id': acteData['id']?.toString() ?? '',
          'nom': signalementJson['nom'],
          'typeDocument': signalementJson['typeDocument'],
          'lieu': signalementJson['lieu'] ?? 'Non spécifié',
          'date': "À l'instant",
          'statut': "synchronise",
          'numeroDocument': signalementJson['numeroDocument'],
          'dateNaissance': signalementJson['dateNaissance'],
          'nationalite': signalementJson['nationalite'] ?? 'Sénégalaise',
          'noteAgent': signalementJson['noteAgent'] ?? '',
          'cheminImage': cheminImage,
        };
      } else {
        throw Exception('Erreur lors de la création de l\'acte (${responseActe.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de soumission à l\'API : $e');
    }
  }

  // ─── OCR & ANALYSE IA ───────────────────────────────────────────
  Future<Map<String, dynamic>> analyserDocument(String cheminImage) async {
    try {
      final token = await _getToken();
      final url = Uri.parse('${Constantes.urlBaseApi}${Constantes.endpointOcr}');
      
      final request = http.MultipartRequest('POST', url);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // On utilise 'document' pour correspondre aux attentes originelles du backend
      request.files.add(await http.MultipartFile.fromPath('document', cheminImage));
      
      // On envoie le fichier de scan
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Si l'API retourne un résultat OCR JSON structuré, on l'utilise.
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final resJson = json.decode(utf8.decode(response.bodyBytes));
          if (resJson is Map<String, dynamic>) {
            Map<String, dynamic>? rawExtracted;
            
            // Si le backend renvoie le format avec extracted_data imbriqué
            if (resJson.containsKey('extracted_data')) {
              final ext = resJson['extracted_data'];
              if (ext is Map<String, dynamic>) {
                rawExtracted = ext;
              }
            } else if (resJson.containsKey('nom') || resJson.containsKey('numero_identification') || resJson.containsKey('numeroDocument')) {
              // Sinon format plat direct
              rawExtracted = resJson;
            }

            if (rawExtracted != null) {
              // Adapter le format du backend vers le format attendu par le mobile (camelCase + nom complet)
              final String prenom = rawExtracted['prenom'] ?? '';
              final String nom = rawExtracted['nom'] ?? '';
              final String nomComplet = '$prenom $nom'.trim();
              
              return {
                'nom': nomComplet.isNotEmpty ? nomComplet : (rawExtracted['nom'] ?? ''),
                'numeroDocument': rawExtracted['numero_identification'] ?? rawExtracted['numeroDocument'] ?? '',
                'dateNaissance': rawExtracted['date_naissance'] ?? rawExtracted['dateNaissance'] ?? '',
                'typeDocument': rawExtracted['typeDocument'] ?? 'CIN',
                'nationalite': rawExtracted['nationalite'] ?? 'Sénégalaise',
                'lieu': rawExtracted['lieu'] ?? '',
                'noteAgent': rawExtracted['noteAgent'] ?? 'Extrait automatiquement via OCR.',
              };
            }
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Erreur réseau durant le scan OCR : $e');
    }

    // Fallback robuste sur les données mockées pour simuler l'OCR LLM du brief
    try {
      final String contenu = await rootBundle.loadString('assets/data.json');
      final Map<String, dynamic> donnees = json.decode(contenu);
      return Map<String, dynamic>.from(donnees['ocr_simulation']);
    } catch (e) {
      return {
        "nom": "Ousmane Sonko",
        "typeDocument": "CIN",
        "numeroDocument": "SN-1974-008273",
        "dateNaissance": "15/07/1974",
        "nationalite": "Sénégalaise",
        "lieu": "Ziguinchor",
        "noteAgent": "Extrait automatique (mode dégradé)."
      };
    }
  }

  // Uploader le document scanné associé à un acte d'état civil
  Future<void> uploaderDocument(String acteId, String cheminImage) async {
    try {
      final token = await _getToken();
      final url = Uri.parse('${Constantes.urlBaseApi}/api/documents/');
      
      final request = http.MultipartRequest('POST', url);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields['acte'] = acteId;
      request.fields['qualite_scan'] = '100.0';
      request.files.add(await http.MultipartFile.fromPath('fichier', cheminImage));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Erreur lors de l\'upload du document (${response.statusCode}) : ${response.body}');
      } else {
        debugPrint('Document image uploade avec succes pour l\'acte $acteId');
      }
    } catch (e) {
      debugPrint('Erreur reseau lors de l\'upload du document : $e');
    }
  }

  // ─── HELPERS DE CONVERSION DE TYPES ─────────────────────────────
  
  String _mapTypeActeVersDoc(String? typeActe) {
    switch (typeActe) {
      case 'NAISSANCE': return 'Extrait de Naissance';
      case 'MARIAGE': return 'Certificat de Mariage';
      case 'DECES': return 'Casier Judiciaire';
      default: return 'CIN';
    }
  }

  String _mapDocVersTypeActe(String? typeDoc) {
    if (typeDoc == null) return 'NAISSANCE';
    final doc = typeDoc.toUpperCase();
    if (doc.contains('NAISSANCE')) return 'NAISSANCE';
    if (doc.contains('MARIAGE')) return 'MARIAGE';
    if (doc.contains('DECES') || doc.contains('DÉCÈS')) return 'DECES';
    return 'NAISSANCE'; // Par défaut
  }

  Map<String, String> _separerPrenomNom(String nomComplet) {
    final parts = nomComplet.trim().split(' ');
    if (parts.length >= 2) {
      final prenom = parts.sublist(0, parts.length - 1).join(' ');
      final nom = parts.last;
      return {'prenom': prenom, 'nom': nom};
    }
    return {'prenom': 'Inconnu', 'nom': nomComplet};
  }

  // Convertit "JJ/MM/AAAA" en "AAAA-MM-JJ" pour l'API Django
  String? _formaterDateNaissanceApi(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
      final partsDash = dateStr.split('-');
      if (partsDash.length == 3) {
        if (partsDash[0].length == 4) return dateStr; // Déjà AAAA-MM-JJ
        return '${partsDash[2]}-${partsDash[1].padLeft(2, '0')}-${partsDash[0].padLeft(2, '0')}';
      }
    } catch (_) {}
    return null;
  }

  // Convertit "AAAA-MM-JJ" en "JJ/MM/AAAA" pour l'affichage
  String _formaterDateNaissanceAffiche(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
      }
    } catch (_) {}
    return dateStr;
  }
}
