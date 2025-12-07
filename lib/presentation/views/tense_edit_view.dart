import 'package:flutter/material.dart';
import '../../data/models/verb_tense.dart';
import '../../data/repositories/tense_repository.dart';

class TenseEditView extends StatefulWidget {
  final VerbTense tense;

  const TenseEditView({super.key, required this.tense});

  @override
  State<TenseEditView> createState() => _TenseEditViewState();
}

class _TenseEditViewState extends State<TenseEditView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _spanishNameController;
  late TextEditingController _spanishEquivalentController;
  late TextEditingController _whenToUseController;
  late TextEditingController _affirmativeController;
  late TextEditingController _negativeController;
  late TextEditingController _questionController;
  List<TenseExample> _examples = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _spanishNameController = TextEditingController(
      text: widget.tense.spanishName,
    );
    _spanishEquivalentController = TextEditingController(
      text: widget.tense.spanishEquivalent,
    );
    _whenToUseController = TextEditingController(text: widget.tense.whenToUse);
    _affirmativeController = TextEditingController(
      text: widget.tense.affirmativeStructure,
    );
    _negativeController = TextEditingController(
      text: widget.tense.negativeStructure,
    );
    _questionController = TextEditingController(
      text: widget.tense.questionStructure,
    );
    _examples = List.from(widget.tense.examples);
  }

  @override
  void dispose() {
    _spanishNameController.dispose();
    _spanishEquivalentController.dispose();
    _whenToUseController.dispose();
    _affirmativeController.dispose();
    _negativeController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedTense = widget.tense.copyWith(
      spanishName: _spanishNameController.text,
      spanishEquivalent: _spanishEquivalentController.text,
      whenToUse: _whenToUseController.text,
      affirmativeStructure: _affirmativeController.text,
      negativeStructure: _negativeController.text,
      questionStructure: _questionController.text,
      examples: _examples,
    );

    await TenseRepository().updateTense(updatedTense);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados correctamente')),
      );
      Navigator.pop(context, true);
    }
  }

  void _addExample() {
    showDialog(
      context: context,
      builder: (context) {
        final englishController = TextEditingController();
        final spanishController = TextEditingController();
        return AlertDialog(
          title: const Text('Nuevo Ejemplo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: englishController,
                decoration: const InputDecoration(labelText: 'Inglés'),
              ),
              TextField(
                controller: spanishController,
                decoration: const InputDecoration(labelText: 'Español'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (englishController.text.isNotEmpty &&
                    spanishController.text.isNotEmpty) {
                  setState(() {
                    _examples.add(
                      TenseExample(
                        english: englishController.text,
                        spanish: spanishController.text,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  void _editExample(int index) {
    final example = _examples[index];
    showDialog(
      context: context,
      builder: (context) {
        final englishController = TextEditingController(text: example.english);
        final spanishController = TextEditingController(text: example.spanish);
        return AlertDialog(
          title: const Text('Editar Ejemplo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: englishController,
                decoration: const InputDecoration(labelText: 'Inglés'),
              ),
              TextField(
                controller: spanishController,
                decoration: const InputDecoration(labelText: 'Español'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _examples.removeAt(index);
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (englishController.text.isNotEmpty &&
                    spanishController.text.isNotEmpty) {
                  setState(() {
                    _examples[index] = TenseExample(
                      english: englishController.text,
                      spanish: spanishController.text,
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar: ${widget.tense.name}'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _spanishNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre en Español',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _spanishEquivalentController,
              decoration: const InputDecoration(
                labelText: 'Equivalente en Español',
                border: OutlineInputBorder(),
                helperText: 'Ej: Presente de indicativo (yo trabajo)',
              ),
              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _whenToUseController,
              decoration: const InputDecoration(
                labelText: 'Cuándo usar',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: 24),
            Text('Estructuras', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _affirmativeController,
              decoration: const InputDecoration(
                labelText: 'Afirmativa',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_circle_outline),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _negativeController,
              decoration: const InputDecoration(
                labelText: 'Negativa',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.remove_circle_outline),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Interrogativa',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.help_outline),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ejemplos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(onPressed: _addExample, icon: const Icon(Icons.add)),
              ],
            ),
            if (_examples.isEmpty)
              const Text(
                'No hay ejemplos',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            else
              ..._examples.asMap().entries.map((entry) {
                final index = entry.key;
                final example = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(example.english),
                    subtitle: Text(example.spanish),
                    onTap: () => _editExample(index),
                    trailing: const Icon(Icons.edit_outlined),
                  ),
                );
              }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
