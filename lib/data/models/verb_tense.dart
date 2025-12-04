/// Model for a verb tense with all its grammatical information
class VerbTense {
  final String id;
  final String name;
  final String spanishName;
  final String spanishEquivalent;
  final String whenToUse;
  final String affirmativeStructure;
  final String negativeStructure;
  final String questionStructure;
  final List<TenseExample> examples;
  final String group; // Present, Past, Future, Conditional

  const VerbTense({
    required this.id,
    required this.name,
    required this.spanishName,
    required this.spanishEquivalent,
    required this.whenToUse,
    required this.affirmativeStructure,
    required this.negativeStructure,
    required this.questionStructure,
    required this.examples,
    required this.group,
  });
}

/// Example sentence for a verb tense
class TenseExample {
  final String english;
  final String spanish;

  const TenseExample({
    required this.english,
    required this.spanish,
  });
}
