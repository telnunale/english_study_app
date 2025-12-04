import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';
import '../../data/models/verb_tense.dart';
import '../../data/services/storage_service.dart';
import '../../data/repositories/tense_repository.dart';

class ManagementView extends StatefulWidget {
  const ManagementView({super.key});

  @override
  State<ManagementView> createState() => _ManagementViewState();
}

class _ManagementViewState extends State<ManagementView> {
  final StorageService _storage = StorageService();
  final TenseRepository _tenseRepo = TenseRepository();

  List<Exercise> _customExercises = [];
  List<VerbTense> _allTenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storage.init();
    _customExercises = await _storage.getCustomExercises();
    _allTenses = _tenseRepo.getAllTenses();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
