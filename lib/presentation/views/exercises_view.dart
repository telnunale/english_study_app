import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/tense_viewmodel.dart';
import '../../presentation/viewmodels/exercise_viewmodel.dart';
import '../../data/models/exercise.dart';

class ExercisesView extends StatefulWidget {
  const ExercisesView({super.key});

  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  ExerciseViewModel? _exerciseVM;
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tenseVM = context.read<TenseViewModel>();
      _exerciseVM = ExerciseViewModel();
      _exerciseVM!.init(tenseVM.selectedTenseIds);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        actions: [
          if (_exerciseVM != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final tenseVM = context.read<TenseViewModel>();
                _exerciseVM!.init(tenseVM.selectedTenseIds);
              },
            ),
        ],
      ),
      body: _exerciseVM == null
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: _exerciseVM!,
              builder: (context, _) {
                if (_exerciseVM!.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_exerciseVM!.exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay ejercicios disponibles',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecciona tiempos en "Estudiar"\no añade ejercicios en "Gestión"',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                if (_exerciseVM!.isFinished) {
                  return _buildResultsScreen(context);
                }

                return _buildExerciseScreen(context);
              },
            ),
    );
  }

  Widget _buildExerciseScreen(BuildContext context) {
    final exercise = _exerciseVM!.currentExercise!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          LinearProgressIndicator(
            value: _exerciseVM!.progress,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 8),
          Text(
            'Ejercicio ${_exerciseVM!.currentIndex + 1} de ${_exerciseVM!.totalExercises}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Question
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exercise.type == ExerciseType.multipleChoice
                          ? 'Selección múltiple'
                          : 'Completar',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    exercise.question,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Answer Options or Input
          if (exercise.type == ExerciseType.multipleChoice)
            ...exercise.options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OptionButton(
                  text: option,
                  isSelected: _exerciseVM!.userAnswer == option,
                  isCorrect: _exerciseVM!.showResult
                      ? option == exercise.correctAnswer
                      : null,
                  isWrong:
                      _exerciseVM!.showResult &&
                      _exerciseVM!.userAnswer == option &&
                      !_exerciseVM!.isCorrect!,
                  onTap: _exerciseVM!.showResult
                      ? null
                      : () => _exerciseVM!.submitAnswer(option),
                ),
              ),
            )
          else
            Column(
              children: [
                TextField(
                  controller: _answerController,
                  enabled: !_exerciseVM!.showResult,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu respuesta...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: _exerciseVM!.showResult
                      ? null
                      : (value) => _exerciseVM!.submitAnswer(value),
                ),
                const SizedBox(height: 12),
                if (!_exerciseVM!.showResult)
                  ElevatedButton(
                    onPressed: () {
                      _exerciseVM!.submitAnswer(_answerController.text);
                    },
                    child: const Text('Comprobar'),
                  ),
              ],
            ),

          // Result Feedback
          if (_exerciseVM!.showResult) ...[
            const SizedBox(height: 16),
            Card(
              color: _exerciseVM!.isCorrect!
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _exerciseVM!.isCorrect!
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _exerciseVM!.isCorrect!
                          ? Colors.green
                          : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _exerciseVM!.isCorrect! ? '¡Correcto!' : 'Incorrecto',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _exerciseVM!.isCorrect!
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_exerciseVM!.isCorrect!) ...[
                      const SizedBox(height: 8),
                      Text('Respuesta correcta: ${exercise.correctAnswer}'),
                    ],
                    if (exercise.explanation != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        exercise.explanation!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _answerController.clear();
                _exerciseVM!.nextExercise();
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Siguiente'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context) {
    final percentage =
        (_exerciseVM!.correctAnswers / _exerciseVM!.totalExercises * 100)
            .round();
    final isGood = percentage >= 70;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isGood ? Icons.emoji_events : Icons.school,
              size: 80,
              color: isGood
                  ? Colors.amber
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Ejercicios completados!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '${_exerciseVM!.correctAnswers} / ${_exerciseVM!.totalExercises}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: isGood ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isGood ? '¡Excelente trabajo!' : '¡Sigue practicando!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                final tenseVM = context.read<TenseViewModel>();
                _exerciseVM!.init(tenseVM.selectedTenseIds);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Volver a intentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool? isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.text,
    required this.isSelected,
    this.isCorrect,
    this.isWrong = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? borderColor;

    if (isCorrect == true) {
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
    } else if (isWrong) {
      backgroundColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.red;
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
    }

    return Material(
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  borderColor ??
                  Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: isSelected || isCorrect == true || isWrong ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: Text(text)),
              if (isCorrect == true)
                const Icon(Icons.check_circle, color: Colors.green)
              else if (isWrong)
                const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
