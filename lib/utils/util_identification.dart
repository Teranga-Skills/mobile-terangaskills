// -----------------------------------------------------------------
// Utilitaires : comparaison souple des numéros d'identification
// (pas de format SN obligatoire)
// -----------------------------------------------------------------

class UtilIdentification {
  UtilIdentification._();

  /// Retire les préfixes alphabétiques ; le numéro doit commencer par un chiffre.
  static String sanitiser(String? value) {
    if (value == null) return '';
    final text = value.trim();
    if (text.isEmpty || text.toUpperCase() == 'UNKNOWN') return '';

    var i = 0;
    while (i < text.length && !RegExp(r'\d').hasMatch(text[i])) {
      i++;
    }
    return i < text.length ? text.substring(i).trim() : '';
  }

  static bool commenceParChiffre(String? value) {
    final sanitise = sanitiser(value);
    return sanitise.isNotEmpty && RegExp(r'^\d').hasMatch(sanitise);
  }

  static String? messageErreurFormat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le numéro de document est requis';
    }
    if (!commenceParChiffre(value)) {
      return 'Le numéro doit commencer par un chiffre (pas de lettre en tête)';
    }
    return null;
  }

  static String _normaliser(String? value) {
    final sanitise = sanitiser(value);
    if (sanitise.isEmpty) return '';
    final text = sanitise.toUpperCase();
    return text.replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  static Set<String> _cles(String? value) {
    final base = _normaliser(value);
    if (base.isEmpty) return {};

    final cles = <String>{base};
    for (final prefix in ['SNP', 'SN', 'SEN', 'ID', 'NIN']) {
      if (base.startsWith(prefix) && base.length > prefix.length + 3) {
        cles.add(base.substring(prefix.length));
      }
    }
    return cles;
  }

  static bool correspondent(String? a, String? b) {
    final clesA = _cles(a);
    final clesB = _cles(b);
    if (clesA.isEmpty || clesB.isEmpty) return false;

    if (clesA.intersection(clesB).isNotEmpty) return true;

    for (final ka in clesA) {
      for (final kb in clesB) {
        final shorter = ka.length <= kb.length ? ka : kb;
        final longer = ka.length <= kb.length ? kb : ka;
        if (shorter.length >= 6 && longer.endsWith(shorter)) return true;
      }
    }
    return false;
  }
}
