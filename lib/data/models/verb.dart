/// Model for a verb with its forms and meaning
class Verb {
  final String infinitive;
  final String pastSimple;
  final String pastParticiple;
  final String spanishMeaning;
  final bool isIrregular;

  const Verb({
    required this.infinitive,
    required this.pastSimple,
    required this.pastParticiple,
    required this.spanishMeaning,
    required this.isIrregular,
  });
}
