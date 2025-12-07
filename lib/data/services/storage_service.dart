import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/exercise_stats.dart';
import '../models/exercise_block.dart';
import '../models/verb_tense.dart';

/// Service for local storage using SharedPreferences
class StorageService {
  static const String _selectedTensesKey = 'selected_tenses';
  static const String _customExercisesKey = 'custom_exercises';
  static const String _exerciseStatsKey = 'exercise_stats';
  static const String _exerciseSessionsKey = 'exercise_sessions';
  static const String _completedBlocksKey = 'completed_blocks';
  static const String _translatorEnabledKey = 'translator_enabled';
  static const String _modifiedTensesKey = 'modified_tenses';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Selected Tenses
  Future<List<String>> getSelectedTenses() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getStringList(_selectedTensesKey) ?? [];
  }

  Future<void> setSelectedTenses(List<String> tenseIds) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedTensesKey, tenseIds);
  }

  Future<void> toggleTense(String tenseId) async {
    final selected = await getSelectedTenses();
    if (selected.contains(tenseId)) {
      selected.remove(tenseId);
    } else {
      selected.add(tenseId);
    }
    await setSelectedTenses(selected);
  }

  // Custom Exercises
  Future<List<Exercise>> getCustomExercises() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_customExercisesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Exercise.fromJson(e)).toList();
  }

  Future<void> saveCustomExercises(List<Exercise> exercises) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonList = exercises.map((e) => e.toJson()).toList();
    await prefs.setString(_customExercisesKey, json.encode(jsonList));
  }

  Future<void> addCustomExercise(Exercise exercise) async {
    final exercises = await getCustomExercises();
    exercises.add(exercise);
    await saveCustomExercises(exercises);
  }

  Future<void> deleteCustomExercise(String exerciseId) async {
    final exercises = await getCustomExercises();
    exercises.removeWhere((e) => e.id == exerciseId);
    await saveCustomExercises(exercises);
  }

  Future<void> updateCustomExercise(Exercise exercise) async {
    final exercises = await getCustomExercises();
    final index = exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      exercises[index] = exercise;
      await saveCustomExercises(exercises);
    }
  }

  // Exercise Statistics
  Future<ExerciseStats> getExerciseStats() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_exerciseStatsKey);
    if (jsonString == null) return const ExerciseStats();

    return ExerciseStats.fromJson(json.decode(jsonString));
  }

  Future<void> saveExerciseStats(ExerciseStats stats) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_exerciseStatsKey, json.encode(stats.toJson()));
  }

  Future<void> updateStatsAfterSession({
    required int exercisesCompleted,
    required int correctAnswers,
    required int currentStreak,
    required List<String> tenseIds,
    required Map<String, int> correctByTense,
    required Map<String, int> totalByTense,
  }) async {
    final stats = await getExerciseStats();

    // Update tense-specific stats
    final newStatsByTense = Map<String, TenseStats>.from(stats.statsByTense);
    for (final tenseId in tenseIds) {
      final existing = newStatsByTense[tenseId] ?? const TenseStats();
      newStatsByTense[tenseId] = existing.copyWith(
        exercisesCompleted:
            existing.exercisesCompleted + (totalByTense[tenseId] ?? 0),
        correctAnswers:
            existing.correctAnswers + (correctByTense[tenseId] ?? 0),
      );
    }

    final updatedStats = stats.copyWith(
      totalSessions: stats.totalSessions + 1,
      totalExercisesCompleted:
          stats.totalExercisesCompleted + exercisesCompleted,
      totalCorrectAnswers: stats.totalCorrectAnswers + correctAnswers,
      bestStreak: currentStreak > stats.bestStreak
          ? currentStreak
          : stats.bestStreak,
      statsByTense: newStatsByTense,
    );

    await saveExerciseStats(updatedStats);
  }

  // Exercise Sessions (history)
  Future<List<ExerciseSession>> getExerciseSessions() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_exerciseSessionsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => ExerciseSession.fromJson(e)).toList();
  }

  Future<void> saveExerciseSession(ExerciseSession session) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final sessions = await getExerciseSessions();
    sessions.insert(0, session); // Add at beginning (most recent first)

    // Keep only last 50 sessions
    final trimmedSessions = sessions.take(50).toList();

    final jsonList = trimmedSessions.map((e) => e.toJson()).toList();
    await prefs.setString(_exerciseSessionsKey, json.encode(jsonList));
  }

  // Clear all stats (for testing or reset)
  Future<void> clearAllStats() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_exerciseStatsKey);
    await prefs.remove(_exerciseSessionsKey);
  }

  // Completed Blocks
  Future<Map<String, List<ExerciseBlock>>> getCompletedBlocks() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_completedBlocksKey);
    if (jsonString == null) return {};

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map(
      (key, value) => MapEntry(
        key,
        (value as List).map((e) => ExerciseBlock.fromJson(e)).toList(),
      ),
    );
  }

  Future<void> saveBlockCompletion(String tenseKey, ExerciseBlock block) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final blocks = await getCompletedBlocks();

    if (!blocks.containsKey(tenseKey)) {
      blocks[tenseKey] = [];
    }

    // Update or add block
    final existingIndex = blocks[tenseKey]!.indexWhere(
      (b) => b.blockNumber == block.blockNumber,
    );
    if (existingIndex >= 0) {
      blocks[tenseKey]![existingIndex] = block;
    } else {
      blocks[tenseKey]!.add(block);
    }

    final jsonMap = blocks.map(
      (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(_completedBlocksKey, json.encode(jsonMap));
  }

  Future<List<ExerciseBlock>> getBlocksForTenses(String tenseKey) async {
    final blocks = await getCompletedBlocks();
    return blocks[tenseKey] ?? [];
  }

  Future<void> clearBlockProgress() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_completedBlocksKey);
  }

  // Translator Settings
  Future<bool> getTranslatorEnabled() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getBool(_translatorEnabledKey) ?? true; // Enabled by default
  }

  Future<void> setTranslatorEnabled(bool enabled) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_translatorEnabledKey, enabled);
  }

  // Modified Tenses (Theory)
  Future<List<VerbTense>> getModifiedTenses() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_modifiedTensesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => VerbTense.fromJson(e)).toList();
  }

  Future<void> saveModifiedTenses(List<VerbTense> tenses) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final jsonList = tenses.map((e) => e.toJson()).toList();
    await prefs.setString(_modifiedTensesKey, json.encode(jsonList));
  }

  Future<void> saveVerbTense(VerbTense tense) async {
    final tenses = await getModifiedTenses();
    final index = tenses.indexWhere((t) => t.id == tense.id);
    if (index >= 0) {
      tenses[index] = tense;
    } else {
      tenses.add(tense);
    }
    await saveModifiedTenses(tenses);
  }
}
