/// Model for general vocabulary (nouns, adjectives, adverbs, etc.)
class Word {
  final String english;
  final String spanish;
  final WordType type;
  final String? example;

  const Word({
    required this.english,
    required this.spanish,
    required this.type,
    this.example,
  });
}

enum WordType {
  noun, // sustantivo
  adjective, // adjetivo
  adverb, // adverbio
  pronoun, // pronombre
  preposition, // preposición
  conjunction, // conjunción
  other, // otro
}

extension WordTypeExtension on WordType {
  String get spanishName {
    switch (this) {
      case WordType.noun:
        return 'Sustantivo';
      case WordType.adjective:
        return 'Adjetivo';
      case WordType.adverb:
        return 'Adverbio';
      case WordType.pronoun:
        return 'Pronombre';
      case WordType.preposition:
        return 'Preposición';
      case WordType.conjunction:
        return 'Conjunción';
      case WordType.other:
        return 'Otro';
    }
  }
}
