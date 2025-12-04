import 'package:flutter/foundation.dart';
import 'package:english_study_app/data/repositories/tense_repository.dart';
import 'package:english_study_app/data/models/verb_tense.dart';
import 'package:english_study_app/data/services/storage_service.dart';

/// ViewModel for Study Selector and Tenses screens
class TenseViewModel extends ChangeNotifier {
  final TenseRepository _tenseRepo = TenseRepository();
  final StorageService _storage = StorageService();

  List<VerbTense> _allTenses = [];
  List<String> _selectedTenseIds = [];
  bool _isLoading = true;

  List<VerbTense> get allTenses => _allTenses;
  List<String> get selectedTenseIds => _selectedTenseIds;
  bool get isLoading => _isLoading;

  List<VerbTense> get selectedTenses =>
      _allTenses.where((t) => _selectedTenseIds.contains(t.id)).toList();

  List<String> get groups => _tenseRepo.getGroups();

  List<VerbTense> getTensesByGroup(String group) =>
      _allTenses.where((t) => t.group == group).toList();

  Future<void> init() async {
    await _storage.init();
    _allTenses = _tenseRepo.getAllTenses();
    _selectedTenseIds = await _storage.getSelectedTenses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTense(String tenseId) async {
    await _storage.toggleTense(tenseId);
    _selectedTenseIds = await _storage.getSelectedTenses();
    notifyListeners();
  }

  Future<void> selectAll() async {
    _selectedTenseIds = _allTenses.map((t) => t.id).toList();
    await _storage.setSelectedTenses(_selectedTenseIds);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _selectedTenseIds = [];
    await _storage.setSelectedTenses([]);
    notifyListeners();
  }

  bool isTenseSelected(String tenseId) => _selectedTenseIds.contains(tenseId);
}
