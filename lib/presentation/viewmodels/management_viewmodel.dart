import 'package:english_study_app/data/models/exercise.dart';
import 'package:english_study_app/data/models/verb_tense.dart';
import 'package:english_study_app/data/repositories/tense_repository.dart';
import 'package:english_study_app/data/services/storage_service.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for Management screen (add/edit exercises)
class ManagementViewModel extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final TenseRepository _tenseRepo = TenseRepository();

  List<Exercise> _customExercises = [];
  List<VerbTense> _allTenses = [];
  bool _isLoading = true;

  List<Exercise> get customExercises => _customExercises;
  List<VerbTense> get allTenses => _allTenses;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await _storage.init();
    _customExercises = await _storage.getCustomExercises();
    _allTenses = _tenseRepo.getAllTenses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExercise({
    required String tenseId,
    required ExerciseType type,
    required String question,
    required List<String> options,
    required String correctAnswer,
    String? explanation,
  }) async {
    final exercise = Exercise(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      tenseId: tenseId,
      type: type,
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      explanation: explanation,
      isCustom: true,
    );
    await _storage.addCustomExercise(exercise);
    _customExercises = await _storage.getCustomExercises();
    notifyListeners();
  }

  Future<void> deleteExercise(String exerciseId) async {
    await _storage.deleteCustomExercise(exerciseId);
    _customExercises = await _storage.getCustomExercises();
    notifyListeners();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _storage.updateCustomExercise(exercise);
    _customExercises = await _storage.getCustomExercises();
    notifyListeners();
  }

  String getTenseName(String tenseId) {
    final tense = _allTenses.firstWhere(
      (t) => t.id == tenseId,
      orElse: () => VerbTense(
        id: '',
        name: 'Unknown',
        spanishName: '',
        spanishEquivalent: '',
        whenToUse: '',
        affirmativeStructure: '',
        negativeStructure: '',
        questionStructure: '',
        examples: [],
        group: '',
      ),
    );
    return tense.spanishName;
  }
}
