/// Model for tracking exercise session statistics
class ExerciseSession {
  final String id;
  final DateTime date;
  final int totalExercises;
  final int correctAnswers;
  final List<String> tenseIds; // Which tenses were practiced
  final int durationSeconds;

  const ExerciseSession({
    required this.id,
    required this.date,
    required this.totalExercises,
    required this.correctAnswers,
    required this.tenseIds,
    required this.durationSeconds,
  });

  double get accuracy =>
      totalExercises > 0 ? (correctAnswers / totalExercises) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'totalExercises': totalExercises,
    'correctAnswers': correctAnswers,
    'tenseIds': tenseIds,
    'durationSeconds': durationSeconds,
  };

  factory ExerciseSession.fromJson(Map<String, dynamic> json) =>
      ExerciseSession(
        id: json['id'],
        date: DateTime.parse(json['date']),
        totalExercises: json['totalExercises'],
        correctAnswers: json['correctAnswers'],
        tenseIds: List<String>.from(json['tenseIds']),
        durationSeconds: json['durationSeconds'],
      );
}

/// Aggregated statistics for exercises
class ExerciseStats {
  final int totalSessions;
  final int totalExercisesCompleted;
  final int totalCorrectAnswers;
  final int bestStreak; // Best consecutive correct answers
  final Map<String, TenseStats> statsByTense;

  const ExerciseStats({
    this.totalSessions = 0,
    this.totalExercisesCompleted = 0,
    this.totalCorrectAnswers = 0,
    this.bestStreak = 0,
    this.statsByTense = const {},
  });

  double get overallAccuracy => totalExercisesCompleted > 0
      ? (totalCorrectAnswers / totalExercisesCompleted) * 100
      : 0;

  Map<String, dynamic> toJson() => {
    'totalSessions': totalSessions,
    'totalExercisesCompleted': totalExercisesCompleted,
    'totalCorrectAnswers': totalCorrectAnswers,
    'bestStreak': bestStreak,
    'statsByTense': statsByTense.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory ExerciseStats.fromJson(Map<String, dynamic> json) => ExerciseStats(
    totalSessions: json['totalSessions'] ?? 0,
    totalExercisesCompleted: json['totalExercisesCompleted'] ?? 0,
    totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
    bestStreak: json['bestStreak'] ?? 0,
    statsByTense:
        (json['statsByTense'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, TenseStats.fromJson(v)),
        ) ??
        {},
  );

  ExerciseStats copyWith({
    int? totalSessions,
    int? totalExercisesCompleted,
    int? totalCorrectAnswers,
    int? bestStreak,
    Map<String, TenseStats>? statsByTense,
  }) => ExerciseStats(
    totalSessions: totalSessions ?? this.totalSessions,
    totalExercisesCompleted:
        totalExercisesCompleted ?? this.totalExercisesCompleted,
    totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
    bestStreak: bestStreak ?? this.bestStreak,
    statsByTense: statsByTense ?? this.statsByTense,
  );
}

/// Statistics for a specific tense
class TenseStats {
  final int exercisesCompleted;
  final int correctAnswers;

  const TenseStats({this.exercisesCompleted = 0, this.correctAnswers = 0});

  double get accuracy =>
      exercisesCompleted > 0 ? (correctAnswers / exercisesCompleted) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'exercisesCompleted': exercisesCompleted,
    'correctAnswers': correctAnswers,
  };

  factory TenseStats.fromJson(Map<String, dynamic> json) => TenseStats(
    exercisesCompleted: json['exercisesCompleted'] ?? 0,
    correctAnswers: json['correctAnswers'] ?? 0,
  );

  TenseStats copyWith({int? exercisesCompleted, int? correctAnswers}) =>
      TenseStats(
        exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
        correctAnswers: correctAnswers ?? this.correctAnswers,
      );
}
