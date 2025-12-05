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
  List<String>? _lastSelectedTenseIds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initExercises();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if tense selection changed
    final tenseVM = context.watch<TenseViewModel>();
    if (_lastSelectedTenseIds != null &&
        !_listEquals(_lastSelectedTenseIds!, tenseVM.selectedTenseIds)) {
      // Selection changed, reload exercises
      _initExercises();
    }
  }

  void _initExercises() {
    final tenseVM = context.read<TenseViewModel>();
    _lastSelectedTenseIds = List.from(tenseVM.selectedTenseIds);
    _exerciseVM = ExerciseViewModel();
    _exerciseVM!.init(tenseVM.selectedTenseIds);
    if (mounted) setState(() {});
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!b.contains(a[i])) return false;
    }
    return true;
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
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Estadísticas',
              onPressed: () => _showStatsDialog(context),
            ),
          if (_exerciseVM != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reiniciar',
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

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tus Estadísticas'),
        content: ListenableBuilder(
          listenable: _exerciseVM!,
          builder: (context, _) {
            final stats = _exerciseVM!.stats;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow(
                    icon: Icons.fitness_center,
                    label: 'Sesiones totales',
                    value: '${stats.totalSessions}',
                  ),
                  _StatRow(
                    icon: Icons.check_circle,
                    label: 'Ejercicios completados',
                    value: '${stats.totalExercisesCompleted}',
                  ),
                  _StatRow(
                    icon: Icons.trending_up,
                    label: 'Precisión global',
                    value: '${stats.overallAccuracy.toStringAsFixed(1)}%',
                  ),
                  _StatRow(
                    icon: Icons.local_fire_department,
                    label: 'Mejor racha',
                    value: '${stats.bestStreak}',
                  ),
                  if (stats.totalSessions == 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        '¡Completa tu primera sesión para ver estadísticas!',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
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
          // Progress and streak
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _exerciseVM!.progress,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ),
              if (_exerciseVM!.currentStreak > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 20,
                      ),
                      Text(
                        '${_exerciseVM!.currentStreak}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
    final stats = _exerciseVM!.stats;

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

            // Score
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

            // Session stats
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Esta sesión',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MiniStat(
                          icon: Icons.local_fire_department,
                          value: '${_exerciseVM!.bestStreakThisSession}',
                          label: 'Mejor racha',
                        ),
                        _MiniStat(
                          icon: Icons.percent,
                          value:
                              '${_exerciseVM!.accuracyThisSession.toStringAsFixed(0)}%',
                          label: 'Precisión',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Overall stats
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Tu progreso total',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MiniStat(
                          icon: Icons.fitness_center,
                          value: '${stats.totalSessions}',
                          label: 'Sesiones',
                        ),
                        _MiniStat(
                          icon: Icons.check_circle,
                          value: '${stats.totalExercisesCompleted}',
                          label: 'Ejercicios',
                        ),
                        _MiniStat(
                          icon: Icons.star,
                          value: '${stats.bestStreak}',
                          label: 'Récord racha',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _exerciseVM!.restart();
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Volver a practicar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    final tenseVM = context.read<TenseViewModel>();
                    _exerciseVM!.init(tenseVM.selectedTenseIds);
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Nuevos ejercicios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
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
