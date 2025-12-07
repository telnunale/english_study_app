import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';
import '../../data/models/verb_tense.dart';
import '../../data/services/storage_service.dart';
import '../../data/repositories/tense_repository.dart';
import 'tense_edit_view.dart';

class ManagementView extends StatefulWidget {
  final VoidCallback? onTranslatorToggled;

  const ManagementView({super.key, this.onTranslatorToggled});

  @override
  State<ManagementView> createState() => _ManagementViewState();
}

class _ManagementViewState extends State<ManagementView> {
  final StorageService _storage = StorageService();
  final TenseRepository _tenseRepo = TenseRepository();

  List<Exercise> _customExercises = [];
  List<VerbTense> _allTenses = [];
  bool _isLoading = true;
  bool _translatorEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storage.init();
    _customExercises = await _storage.getCustomExercises();
    await _tenseRepo.init();
    _allTenses = _tenseRepo.getAllTenses();
    _translatorEnabled = await _storage.getTranslatorEnabled();
    setState(() => _isLoading = false);
  }

  Future<void> _toggleTranslator(bool value) async {
    await _storage.setTranslatorEnabled(value);
    setState(() => _translatorEnabled = value);
    widget.onTranslatorToggled?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Settings Section
                Text(
                  'Configuración',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Translator Toggle Card
                Card(
                  child: SwitchListTile(
                    secondary: CircleAvatar(
                      backgroundColor: _translatorEnabled
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.translate,
                        color: _translatorEnabled
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                    title: const Text('Traductor'),
                    subtitle: Text(
                      _translatorEnabled
                          ? 'Disponible en la barra de navegación'
                          : 'Oculto de la barra de navegación',
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                    value: _translatorEnabled,
                    onChanged: _toggleTranslator,
                  ),
                ),
                const SizedBox(height: 24),

                // Add Exercise Card
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.add)),
                    title: const Text('Añadir ejercicio'),
                    subtitle: const Text('Crea ejercicios personalizados'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAddExerciseDialog(context),
                  ),
                ),
                const SizedBox(height: 16),

                // Custom Exercises List
                Text(
                  'Mis ejercicios (${_customExercises.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                if (_customExercises.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No hay ejercicios personalizados',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._customExercises.map(
                    (exercise) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          exercise.question,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(_getTenseName(exercise.tenseId)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteExercise(exercise.id),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Theory Management Section
                Text(
                  'Gestionar Teoría',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text('Tiempos Verbales'),
                    subtitle: Text('${_allTenses.length} tiempos disponibles'),
                    children: _allTenses.map((tense) {
                      return ListTile(
                        title: Text(tense.spanishName),
                        subtitle: Text(tense.name),
                        trailing: const Icon(Icons.edit, size: 20),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TenseEditView(tense: tense),
                            ),
                          );
                          if (result == true) {
                            // Reload data to reflect changes
                            _loadData();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  String _getTenseName(String tenseId) {
    final tense = _allTenses.firstWhere(
      (t) => t.id == tenseId,
      orElse: () => VerbTense(
        id: '',
        name: 'Unknown',
        spanishName: 'Desconocido',
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

  Future<void> _deleteExercise(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ejercicio'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este ejercicio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.deleteCustomExercise(id);
      _loadData();
    }
  }

  Future<void> _showAddExerciseDialog(BuildContext context) async {
    final questionController = TextEditingController();
    final correctAnswerController = TextEditingController();
    final explanationController = TextEditingController();
    final optionsControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];

    String? selectedTenseId = _allTenses.first.id;
    ExerciseType selectedType = ExerciseType.multipleChoice;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nuevo ejercicio',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Tense Selector
                DropdownButtonFormField<String>(
                  initialValue: selectedTenseId,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo verbal',
                    border: OutlineInputBorder(),
                  ),
                  items: _allTenses
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.spanishName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setModalState(() => selectedTenseId = value);
                  },
                ),
                const SizedBox(height: 12),

                // Type Selector
                DropdownButtonFormField<ExerciseType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de ejercicio',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ExerciseType.multipleChoice,
                      child: Text('Selección múltiple'),
                    ),
                    DropdownMenuItem(
                      value: ExerciseType.fillInBlank,
                      child: Text('Completar'),
                    ),
                  ],
                  onChanged: (value) {
                    setModalState(() => selectedType = value!);
                  },
                ),
                const SizedBox(height: 12),

                // Question
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Pregunta',
                    hintText: 'She ___ to school every day.',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Options (for multiple choice)
                if (selectedType == ExerciseType.multipleChoice) ...[
                  const Text('Opciones:'),
                  const SizedBox(height: 8),
                  ...List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: optionsControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Opción ${i + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],

                // Correct Answer
                TextField(
                  controller: correctAnswerController,
                  decoration: const InputDecoration(
                    labelText: 'Respuesta correcta',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Explanation (optional)
                TextField(
                  controller: explanationController,
                  decoration: const InputDecoration(
                    labelText: 'Explicación (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Save Button
                ElevatedButton.icon(
                  onPressed: () async {
                    if (questionController.text.isEmpty ||
                        correctAnswerController.text.isEmpty ||
                        selectedTenseId == null) {
                      return;
                    }

                    final options = selectedType == ExerciseType.multipleChoice
                        ? optionsControllers
                              .map((c) => c.text)
                              .where((t) => t.isNotEmpty)
                              .toList()
                        : <String>[];

                    final exercise = Exercise(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      tenseId: selectedTenseId!,
                      type: selectedType,
                      question: questionController.text,
                      options: options,
                      correctAnswer: correctAnswerController.text,
                      explanation: explanationController.text.isEmpty
                          ? null
                          : explanationController.text,
                      isCustom: true,
                    );

                    await _storage.addCustomExercise(exercise);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadData();
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
