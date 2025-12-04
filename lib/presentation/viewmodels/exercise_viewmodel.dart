import 'package:flutter/foundation.dart';
import 'package:english_study_app/data/repositories/exercise_repository.dart';
import 'package:english_study_app/data/models/exercise.dart';
import 'package:english_study_app/data/services/storage_service.dart';

/// ViewModel for Exercises screen
class ExerciseViewModel extends ChangeNotifier {
  final ExerciseRepository _exerciseRepo = ExerciseRepository();
  final StorageService _storage = StorageService();

  List<Exercise> _exercises = [];
  List<Exercise> _customExercises = [];
  int _currentIndex = 0;
  int _correctAnswers = 0;
  bool _isLoading = true;
  bool _showResult = false;
  String? _userAnswer;
  bool? _isCorrect;

  List<Exercise> get exercises => [..._exercises, ..._customExercises];
  Exercise? get currentExercise =>
      _currentIndex < exercises.length ? exercises[_currentIndex] : null;
  int get currentIndex => _currentIndex;
  int get totalExercises => exercises.length;
  int get correctAnswers => _correctAnswers;
  bool get isLoading => _isLoading;
  bool get showResult => _showResult;
  String? get userAnswer => _userAnswer;
  bool? get isCorrect => _isCorrect;
  bool get isFinished => _currentIndex >= exercises.length;

  double get progress =>
      totalExercises > 0 ? (_currentIndex / totalExercises) : 0;

  Future<void> init(List<String> selectedTenseIds) async {
    await _storage.init();

    if (selectedTenseIds.isEmpty) {
      _exercises = _exerciseRepo.getAllExercises();
    } else {
      _exercises = _exerciseRepo.getExercisesForTenses(selectedTenseIds);
    }

    _customExercises = await _storage.getCustomExercises();
    _customExercises = _customExercises
        .where(
          (e) =>
              selectedTenseIds.isEmpty || selectedTenseIds.contains(e.tenseId),
        )
        .toList();

    // Shuffle exercises
    exercises.shuffle();

    _isLoading = false;
    notifyListeners();
  }

  void submitAnswer(String answer) {
    _userAnswer = answer;
    _isCorrect =
        answer.toLowerCase().trim() ==
        currentExercise!.correctAnswer.toLowerCase().trim();
    if (_isCorrect!) _correctAnswers++;
    _showResult = true;
    notifyListeners();
  }

  void nextExercise() {
    _currentIndex++;
    _showResult = false;
    _userAnswer = null;
    _isCorrect = null;
    notifyListeners();
  }

  void restart() {
    _currentIndex = 0;
    _correctAnswers = 0;
    _showResult = false;
    _userAnswer = null;
    _isCorrect = null;
    exercises.shuffle();
    notifyListeners();
  }
}
