import 'package:flutter/material.dart';
import '../../data/repositories/vocabulary_repository.dart';
import '../../data/models/word.dart';

class VocabularyView extends StatefulWidget {
  const VocabularyView({super.key});

  @override
  State<VocabularyView> createState() => _VocabularyViewState();
}

class _VocabularyViewState extends State<VocabularyView> {
  final _vocabularyRepo = VocabularyRepository();
  final _searchController = TextEditingController();
  WordType? _selectedType;
  List<Word> _filteredWords = [];

  @override
  void initState() {
    super.initState();
    _filteredWords = _vocabularyRepo.getAllWords();
  }

  void _filterWords() {
    setState(() {
      var words = _vocabularyRepo.getAllWords();

      // Filter by type
      if (_selectedType != null) {
        words = words.where((w) => w.type == _selectedType).toList();
      }

      // Filter by search
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        words = words
            .where(
              (w) =>
                  w.english.toLowerCase().contains(query) ||
                  w.spanish.toLowerCase().contains(query),
            )
            .toList();
      }

      _filteredWords = words;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getTypeColor(WordType type) {
    switch (type) {
      case WordType.noun:
        return Colors.blue;
      case WordType.adjective:
        return Colors.green;
      case WordType.adverb:
        return Colors.orange;
      case WordType.pronoun:
        return Colors.purple;
      case WordType.preposition:
        return Colors.teal;
      case WordType.conjunction:
        return Colors.pink;
      case WordType.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulario'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterWords(),
              decoration: InputDecoration(
                hintText: 'Buscar palabra...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Type filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _selectedType == null,
                  onSelected: (_) {
                    _selectedType = null;
                    _filterWords();
                  },
                ),
                const SizedBox(width: 8),
                ...WordType.values.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.spanishName),
                      selected: _selectedType == type,
                      selectedColor: _getTypeColor(type).withOpacity(0.2),
                      onSelected: (_) {
                        _selectedType = _selectedType == type ? null : type;
                        _filterWords();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Word count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filteredWords.length} palabras',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Word list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredWords.length,
              itemBuilder: (context, index) {
                final word = _filteredWords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      word.english,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(word.spanish),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(word.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        word.type.spanishName,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTypeColor(word.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
