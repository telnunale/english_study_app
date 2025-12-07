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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'spanishName': spanishName,
      'spanishEquivalent': spanishEquivalent,
      'whenToUse': whenToUse,
      'affirmativeStructure': affirmativeStructure,
      'negativeStructure': negativeStructure,
      'questionStructure': questionStructure,
      'examples': examples.map((e) => e.toJson()).toList(),
      'group': group,
    };
  }

  factory VerbTense.fromJson(Map<String, dynamic> json) {
    return VerbTense(
      id: json['id'] as String,
      name: json['name'] as String,
      spanishName: json['spanishName'] as String,
      spanishEquivalent: json['spanishEquivalent'] as String,
      whenToUse: json['whenToUse'] as String,
      affirmativeStructure: json['affirmativeStructure'] as String,
      negativeStructure: json['negativeStructure'] as String,
      questionStructure: json['questionStructure'] as String,
      examples: (json['examples'] as List<dynamic>)
          .map((e) => TenseExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      group: json['group'] as String,
    );
  }

  VerbTense copyWith({
    String? id,
    String? name,
    String? spanishName,
    String? spanishEquivalent,
    String? whenToUse,
    String? affirmativeStructure,
    String? negativeStructure,
    String? questionStructure,
    List<TenseExample>? examples,
    String? group,
  }) {
    return VerbTense(
      id: id ?? this.id,
      name: name ?? this.name,
      spanishName: spanishName ?? this.spanishName,
      spanishEquivalent: spanishEquivalent ?? this.spanishEquivalent,
      whenToUse: whenToUse ?? this.whenToUse,
      affirmativeStructure: affirmativeStructure ?? this.affirmativeStructure,
      negativeStructure: negativeStructure ?? this.negativeStructure,
      questionStructure: questionStructure ?? this.questionStructure,
      examples: examples ?? this.examples,
      group: group ?? this.group,
    );
  }
}

/// Example sentence for a verb tense
class TenseExample {
  final String english;
  final String spanish;

  const TenseExample({required this.english, required this.spanish});

  Map<String, dynamic> toJson() {
    return {'english': english, 'spanish': spanish};
  }

  factory TenseExample.fromJson(Map<String, dynamic> json) {
    return TenseExample(
      english: json['english'] as String,
      spanish: json['spanish'] as String,
    );
  }
}
