/// Model for tracking exercise block completion
class ExerciseBlock {
  final int blockNumber;
  final int startIndex;
  final int endIndex;
  final bool isCompleted;
  final int correctAnswers;
  final int totalExercises;
  final DateTime? completedAt;

  const ExerciseBlock({
    required this.blockNumber,
    required this.startIndex,
    required this.endIndex,
    this.isCompleted = false,
    this.correctAnswers = 0,
    this.totalExercises = 10,
    this.completedAt,
  });

  double get accuracy =>
      totalExercises > 0 ? (correctAnswers / totalExercises) * 100 : 0;

  String get label => 'Bloque $blockNumber';
  String get range => '${startIndex + 1}-${endIndex + 1}';

  ExerciseBlock copyWith({
    int? blockNumber,
    int? startIndex,
    int? endIndex,
    bool? isCompleted,
    int? correctAnswers,
    int? totalExercises,
    DateTime? completedAt,
  }) => ExerciseBlock(
    blockNumber: blockNumber ?? this.blockNumber,
    startIndex: startIndex ?? this.startIndex,
    endIndex: endIndex ?? this.endIndex,
    isCompleted: isCompleted ?? this.isCompleted,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    totalExercises: totalExercises ?? this.totalExercises,
    completedAt: completedAt ?? this.completedAt,
  );

  Map<String, dynamic> toJson() => {
    'blockNumber': blockNumber,
    'startIndex': startIndex,
    'endIndex': endIndex,
    'isCompleted': isCompleted,
    'correctAnswers': correctAnswers,
    'totalExercises': totalExercises,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory ExerciseBlock.fromJson(Map<String, dynamic> json) => ExerciseBlock(
    blockNumber: json['blockNumber'],
    startIndex: json['startIndex'],
    endIndex: json['endIndex'],
    isCompleted: json['isCompleted'] ?? false,
    correctAnswers: json['correctAnswers'] ?? 0,
    totalExercises: json['totalExercises'] ?? 10,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'])
        : null,
  );
}
