import 'package:flutter/foundation.dart';
import 'package:english_study_app/data/repositories/exercise_repository.dart';
import 'package:english_study_app/data/models/exercise.dart';
import 'package:english_study_app/data/models/exercise_stats.dart';
import 'package:english_study_app/data/models/exercise_block.dart';
import 'package:english_study_app/data/services/storage_service.dart';

/// ViewModel for Exercises screen
class ExerciseViewModel extends ChangeNotifier {
  final ExerciseRepository _exerciseRepo = ExerciseRepository();
  final StorageService _storage = StorageService();

  // All available exercises
  List<Exercise> _allExercises = [];
  List<Exercise> _customExercises = [];

  // Current block exercises
  List<Exercise> _blockExercises = [];
  List<String> _selectedTenseIds = [];

  // Block management
  static const int exercisesPerBlock = 10;
  int _currentBlockNumber = 0;
  List<ExerciseBlock> _completedBlocks = [];
  bool _showBlockSelector = true;

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

  // Getters
  List<Exercise> get exercises => _blockExercises;
  List<Exercise> get allExercises => [..._allExercises, ..._customExercises];
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
  bool get isFinished =>
      _currentIndex >= exercises.length && exercises.isNotEmpty;
  bool get showBlockSelector => _showBlockSelector;
  int get currentBlockNumber => _currentBlockNumber;
  List<ExerciseBlock> get completedBlocks => _completedBlocks;

  double get progress =>
      totalExercises > 0 ? (_currentIndex / totalExercises) : 0;

  double get accuracyThisSession =>
      _currentIndex > 0 ? (_correctAnswers / _currentIndex) * 100 : 0;

  int get totalBlocks => (allExercises.length / exercisesPerBlock).ceil();

  String get _tenseKey =>
      _selectedTenseIds.isEmpty ? 'all' : _selectedTenseIds.join('_');

  /// Get available blocks with their completion status
  List<ExerciseBlock> getAvailableBlocks() {
    final blocks = <ExerciseBlock>[];
    final total = allExercises.length;

    for (int i = 0; i < totalBlocks; i++) {
      final startIndex = i * exercisesPerBlock;
      final endIndex = (startIndex + exercisesPerBlock - 1).clamp(0, total - 1);

      // Check if this block was completed
      final completedBlock = _completedBlocks.firstWhere(
        (b) => b.blockNumber == i + 1,
        orElse: () => ExerciseBlock(
          blockNumber: i + 1,
          startIndex: startIndex,
          endIndex: endIndex,
          totalExercises: endIndex - startIndex + 1,
        ),
      );

      blocks.add(completedBlock);
    }

    return blocks;
  }

  Future<void> init(List<String> selectedTenseIds) async {
    _isLoading = true;
    notifyListeners();

    await _storage.init();
    _selectedTenseIds = selectedTenseIds;

    // Load stats
    _stats = await _storage.getExerciseStats();

    if (selectedTenseIds.isEmpty) {
      _allExercises = _exerciseRepo.getAllExercises();
    } else {
      _allExercises = _exerciseRepo.getExercisesForTenses(selectedTenseIds);
    }

    _customExercises = await _storage.getCustomExercises();
    _customExercises = _customExercises
        .where(
          (e) =>
              selectedTenseIds.isEmpty || selectedTenseIds.contains(e.tenseId),
        )
        .toList();

    // Load completed blocks for this tense selection
    _completedBlocks = await _storage.getBlocksForTenses(_tenseKey);

    // Show block selector
    _showBlockSelector = true;
    _blockExercises = [];
    _isLoading = false;
    notifyListeners();
  }

  /// Load a specific block of exercises
  void loadBlock(int blockNumber) {
    final startIndex = (blockNumber - 1) * exercisesPerBlock;
    final endIndex = (startIndex + exercisesPerBlock).clamp(
      0,
      allExercises.length,
    );

    _blockExercises = allExercises.sublist(startIndex, endIndex);
    _blockExercises.shuffle();

    _currentBlockNumber = blockNumber;
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
    _showBlockSelector = false;

    notifyListeners();
  }

  /// Go back to block selector
  void showBlocks() {
    _showBlockSelector = true;
    _blockExercises = [];
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
      _saveBlockCompletion();
    }

    notifyListeners();
  }

  Future<void> _saveBlockCompletion() async {
    final startIndex = (_currentBlockNumber - 1) * exercisesPerBlock;
    final endIndex = (startIndex + exercisesPerBlock - 1).clamp(
      0,
      allExercises.length - 1,
    );

    final block = ExerciseBlock(
      blockNumber: _currentBlockNumber,
      startIndex: startIndex,
      endIndex: endIndex,
      isCompleted: true,
      correctAnswers: _correctAnswers,
      totalExercises: exercises.length,
      completedAt: DateTime.now(),
    );

    await _storage.saveBlockCompletion(_tenseKey, block);

    // Update local list
    final existingIndex = _completedBlocks.indexWhere(
      (b) => b.blockNumber == _currentBlockNumber,
    );
    if (existingIndex >= 0) {
      _completedBlocks[existingIndex] = block;
    } else {
      _completedBlocks.add(block);
    }
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
    _blockExercises.shuffle();
    notifyListeners();
  }

  Future<void> loadStats() async {
    _stats = await _storage.getExerciseStats();
    notifyListeners();
  }
}
