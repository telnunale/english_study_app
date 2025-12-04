import 'package:flutter/foundation.dart';
import 'package:english_study_app/data/repositories/verb_repository.dart';
import 'package:english_study_app/data/models/verb.dart';

/// ViewModel for Verbs Dictionary screen
class VerbViewModel extends ChangeNotifier {
  final VerbRepository _verbRepo = VerbRepository();

  List<Verb> _allVerbs = [];
  List<Verb> _filteredVerbs = [];
  String _searchQuery = '';
  bool _showOnlyIrregular = false;

  List<Verb> get filteredVerbs => _filteredVerbs;
  String get searchQuery => _searchQuery;
  bool get showOnlyIrregular => _showOnlyIrregular;
  int get totalVerbs => _allVerbs.length;
  int get irregularCount => _allVerbs.where((v) => v.isIrregular).length;

  void init() {
    _allVerbs = _verbRepo.getAllVerbs();
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleIrregularFilter() {
    _showOnlyIrregular = !_showOnlyIrregular;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var verbs = _allVerbs;

    if (_showOnlyIrregular) {
      verbs = verbs.where((v) => v.isIrregular).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      verbs = verbs
          .where(
            (v) =>
                v.infinitive.toLowerCase().contains(q) ||
                v.spanishMeaning.toLowerCase().contains(q),
          )
          .toList();
    }

    _filteredVerbs = verbs;
  }
}
