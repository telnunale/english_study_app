import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/verb_viewmodel.dart';
import '../../data/repositories/vocabulary_repository.dart';
import '../../data/models/word.dart';

class DictionaryView extends StatefulWidget {
  const DictionaryView({super.key});

  @override
  State<DictionaryView> createState() => _DictionaryViewState();
}

class _DictionaryViewState extends State<DictionaryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _vocabularyRepo = VocabularyRepository();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  WordType? _selectedWordType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Word> get _filteredWords {
    var words = _vocabularyRepo.getAllWords();

    if (_selectedWordType != null) {
      words = words.where((w) => w.type == _selectedWordType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      words = words
          .where(
            (w) =>
                w.english.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                w.spanish.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return words;
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
        title: const Text('Diccionario'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Verbos', icon: Icon(Icons.verified)),
            Tab(text: 'Vocabulario', icon: Icon(Icons.abc)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildVerbsTab(), _buildVocabularyTab()],
      ),
    );
  }

  Widget _buildVerbsTab() {
    return Consumer<VerbViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar verbo...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onChanged: vm.setSearchQuery,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Irregulares'),
                    selected: vm.showOnlyIrregular,
                    onSelected: (_) => vm.toggleIrregularFilter(),
                    avatar: vm.showOnlyIrregular
                        ? const Icon(Icons.check, size: 16)
                        : null,
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatChip(
                    label: 'Total',
                    value: '${vm.totalVerbs}',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _StatChip(
                    label: 'Irregulares',
                    value: '${vm.irregularCount}',
                    color: Colors.orange,
                  ),
                  _StatChip(
                    label: 'Mostrando',
                    value: '${vm.filteredVerbs.length}',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Verb Table Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Infinitivo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Pasado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Participio',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Significado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Verb List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: vm.filteredVerbs.length,
                itemBuilder: (context, index) {
                  final verb = vm.filteredVerbs[index];
                  final isEven = index % 2 == 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isEven
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.3),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              if (verb.isIrregular)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Flexible(
                                child: Text(
                                  verb.infinitive,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(flex: 2, child: Text(verb.pastSimple)),
                        Expanded(flex: 2, child: Text(verb.pastParticiple)),
                        Expanded(
                          flex: 3,
                          child: Text(
                            verb.spanishMeaning,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVocabularyTab() {
    final words = _filteredWords;

    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar palabra...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),

        // Type filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: _selectedWordType == null,
                onSelected: (_) => setState(() => _selectedWordType = null),
              ),
              const SizedBox(width: 8),
              ...WordType.values.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type.spanishName),
                    selected: _selectedWordType == type,
                    selectedColor: _getTypeColor(type).withOpacity(0.2),
                    onSelected: (_) => setState(() {
                      _selectedWordType = _selectedWordType == type
                          ? null
                          : type;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${words.length} palabras',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Word list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
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
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
