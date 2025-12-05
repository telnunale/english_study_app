import 'package:flutter/foundation.dart';
import 'package:english_study_app/data/repositories/exercise_repository.dart';
import 'package:english_study_app/data/models/exercise.dart';
import 'package:english_study_app/data/models/exercise_stats.dart';
import 'package:english_study_app/data/services/storage_service.dart';

/// ViewModel for Exercises screen
class ExerciseViewModel extends ChangeNotifier {
  final ExerciseRepository _exerciseRepo = ExerciseRepository();
  final StorageService _storage = StorageService();

  List<Exercise> _exercises = [];
  List<Exercise> _customExercises = [];
  List<String> _selectedTenseIds = [];
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _currentStreak = 0;
  int _bestStreakThisSession = 0;
  bool _isLoading = true;
  bool _showResult = false;
  String? _userAnswer;
  bool? _isCorrect;
  DateTime? _sessionStartTime;

  // Track correct/total by tense for stats
  final Map<String, int> _correctByTense = {};
  final Map<String, int> _totalByTense = {};

  // Stats
  ExerciseStats _stats = const ExerciseStats();
  ExerciseStats get stats => _stats;

  List<Exercise> get exercises => [..._exercises, ..._customExercises];
  Exercise? get currentExercise =>
      _currentIndex < exercises.length ? exercises[_currentIndex] : null;
  int get currentIndex => _currentIndex;
  int get totalExercises => exercises.length;
  int get correctAnswers => _correctAnswers;
  int get currentStreak => _currentStreak;
  int get bestStreakThisSession => _bestStreakThisSession;
  bool get isLoading => _isLoading;
  bool get showResult => _showResult;
  String? get userAnswer => _userAnswer;
  bool? get isCorrect => _isCorrect;
  bool get isFinished => _currentIndex >= exercises.length;

  double get progress =>
      totalExercises > 0 ? (_currentIndex / totalExercises) : 0;

  double get accuracyThisSession =>
      _currentIndex > 0 ? (_correctAnswers / _currentIndex) * 100 : 0;

  Future<void> init(List<String> selectedTenseIds) async {
    await _storage.init();
    _selectedTenseIds = selectedTenseIds;
    _sessionStartTime = DateTime.now();

    // Load stats
    _stats = await _storage.getExerciseStats();

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

    // Track by tense
    final tenseId = currentExercise!.tenseId;
    _totalByTense[tenseId] = (_totalByTense[tenseId] ?? 0) + 1;

    if (_isCorrect!) {
      _correctAnswers++;
      _currentStreak++;
      if (_currentStreak > _bestStreakThisSession) {
        _bestStreakThisSession = _currentStreak;
      }
      _correctByTense[tenseId] = (_correctByTense[tenseId] ?? 0) + 1;
    } else {
      _currentStreak = 0;
    }

    _showResult = true;
    notifyListeners();
  }

  void nextExercise() {
    _currentIndex++;
    _showResult = false;
    _userAnswer = null;
    _isCorrect = null;

    // If finished, save stats
    if (isFinished) {
      _saveSessionStats();
    }

    notifyListeners();
  }

  Future<void> _saveSessionStats() async {
    if (_sessionStartTime == null) return;

    final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;

    // Save session
    final session = ExerciseSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      totalExercises: exercises.length,
      correctAnswers: _correctAnswers,
      tenseIds: _selectedTenseIds.isEmpty
          ? exercises.map((e) => e.tenseId).toSet().toList()
          : _selectedTenseIds,
      durationSeconds: duration,
    );
    await _storage.saveExerciseSession(session);

    // Update aggregate stats
    await _storage.updateStatsAfterSession(
      exercisesCompleted: exercises.length,
      correctAnswers: _correctAnswers,
      currentStreak: _bestStreakThisSession,
      tenseIds: session.tenseIds,
      correctByTense: _correctByTense,
      totalByTense: _totalByTense,
    );

    // Reload stats
    _stats = await _storage.getExerciseStats();
    notifyListeners();
  }

  void restart() {
    _currentIndex = 0;
    _correctAnswers = 0;
    _currentStreak = 0;
    _bestStreakThisSession = 0;
    _showResult = false;
    _userAnswer = null;
    _isCorrect = null;
    _correctByTense.clear();
    _totalByTense.clear();
    _sessionStartTime = DateTime.now();
    exercises.shuffle();
    notifyListeners();
  }

  Future<void> loadStats() async {
    _stats = await _storage.getExerciseStats();
    notifyListeners();
  }
}
