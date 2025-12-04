import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';

/// Service for local storage using SharedPreferences
class StorageService {
  static const String _selectedTensesKey = 'selected_tenses';
  static const String _customExercisesKey = 'custom_exercises';

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
}
