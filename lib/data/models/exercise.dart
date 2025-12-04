/// Model for an exercise
class Exercise {
  final String id;
  final String tenseId; // Which tense this exercise belongs to
  final ExerciseType type;
  final String question;
  final List<String> options; // For multiple choice
  final String correctAnswer;
  final String? explanation;
  final bool isCustom; // User-created exercise

  const Exercise({
    required this.id,
    required this.tenseId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenseId': tenseId,
        'type': type.name,
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'isCustom': isCustom,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'],
        tenseId: json['tenseId'],
        type: ExerciseType.values.byName(json['type']),
        question: json['question'],
        options: List<String>.from(json['options']),
        correctAnswer: json['correctAnswer'],
        explanation: json['explanation'],
        isCustom: json['isCustom'] ?? false,
      );
}

enum ExerciseType {
  multipleChoice,
  fillInBlank,
  translation,
}
