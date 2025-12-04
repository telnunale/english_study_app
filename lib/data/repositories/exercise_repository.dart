import '../models/exercise.dart';

/// Repository containing exercises for each verb tense
class ExerciseRepository {
  static const List<Exercise> defaultExercises = [
    // PRESENT SIMPLE
    Exercise(
      id: 'ps_1',
      tenseId: 'present_simple',
      type: ExerciseType.multipleChoice,
      question: 'She ___ to school every day.',
      options: ['go', 'goes', 'going', 'went'],
      correctAnswer: 'goes',
      explanation: 'Third person singular (she) uses "goes" in Present Simple.',
    ),
    Exercise(
      id: 'ps_2',
      tenseId: 'present_simple',
      type: ExerciseType.fillInBlank,
      question: 'My brother ___ (play) tennis on Saturdays.',
      options: [],
      correctAnswer: 'plays',
      explanation: 'Third person singular adds -s to the verb.',
    ),
    Exercise(
      id: 'ps_3',
      tenseId: 'present_simple',
      type: ExerciseType.multipleChoice,
      question: '___ you speak French?',
      options: ['Does', 'Do', 'Are', 'Is'],
      correctAnswer: 'Do',
      explanation: 'Use "Do" with I, you, we, they for questions.',
    ),

    // PRESENT CONTINUOUS
    Exercise(
      id: 'pc_1',
      tenseId: 'present_continuous',
      type: ExerciseType.multipleChoice,
      question: 'I ___ studying right now.',
      options: ['am', 'is', 'are', 'be'],
      correctAnswer: 'am',
      explanation: 'Use "am" with "I" in Present Continuous.',
    ),
    Exercise(
      id: 'pc_2',
      tenseId: 'present_continuous',
      type: ExerciseType.fillInBlank,
      question: 'They ___ (watch) TV at the moment.',
      options: [],
      correctAnswer: 'are watching',
      explanation: 'Structure: subject + am/is/are + verb-ing',
    ),

    // PRESENT PERFECT
    Exercise(
      id: 'pp_1',
      tenseId: 'present_perfect',
      type: ExerciseType.multipleChoice,
      question: 'I ___ never been to Japan.',
      options: ['have', 'has', 'had', 'am'],
      correctAnswer: 'have',
      explanation: 'Use "have" with I, you, we, they in Present Perfect.',
    ),
    Exercise(
      id: 'pp_2',
      tenseId: 'present_perfect',
      type: ExerciseType.fillInBlank,
      question: 'She ___ just ___ (arrive).',
      options: [],
      correctAnswer: 'has arrived',
      explanation: 'Structure: has/have + past participle',
    ),

    // PRESENT PERFECT CONTINUOUS
    Exercise(
      id: 'ppc_1',
      tenseId: 'present_perfect_continuous',
      type: ExerciseType.multipleChoice,
      question: 'I have ___ waiting for 2 hours.',
      options: ['be', 'been', 'being', 'was'],
      correctAnswer: 'been',
      explanation: 'Structure: have/has + been + verb-ing',
    ),

    // PAST SIMPLE
    Exercise(
      id: 'pts_1',
      tenseId: 'past_simple',
      type: ExerciseType.multipleChoice,
      question: 'I ___ to the cinema yesterday.',
      options: ['go', 'goes', 'went', 'gone'],
      correctAnswer: 'went',
      explanation: '"Go" is irregular: go → went → gone',
    ),
    Exercise(
      id: 'pts_2',
      tenseId: 'past_simple',
      type: ExerciseType.fillInBlank,
      question: 'She ___ (study) English last year.',
      options: [],
      correctAnswer: 'studied',
      explanation: 'Regular verbs add -ed. Study → studied (y changes to i).',
    ),
    Exercise(
      id: 'pts_3',
      tenseId: 'past_simple',
      type: ExerciseType.multipleChoice,
      question: '___ you see the movie?',
      options: ['Do', 'Does', 'Did', 'Was'],
      correctAnswer: 'Did',
      explanation: 'Use "Did" for questions in Past Simple.',
    ),

    // PAST CONTINUOUS
    Exercise(
      id: 'ptc_1',
      tenseId: 'past_continuous',
      type: ExerciseType.multipleChoice,
      question: 'I ___ sleeping when you called.',
      options: ['was', 'were', 'am', 'is'],
      correctAnswer: 'was',
      explanation: 'Use "was" with I, he, she, it in Past Continuous.',
    ),
    Exercise(
      id: 'ptc_2',
      tenseId: 'past_continuous',
      type: ExerciseType.fillInBlank,
      question: 'They ___ (play) football at 5pm.',
      options: [],
      correctAnswer: 'were playing',
      explanation: 'Structure: was/were + verb-ing',
    ),

    // PAST PERFECT
    Exercise(
      id: 'ptp_1',
      tenseId: 'past_perfect',
      type: ExerciseType.multipleChoice,
      question: 'I ___ already eaten when she arrived.',
      options: ['have', 'has', 'had', 'was'],
      correctAnswer: 'had',
      explanation: 'Past Perfect uses "had" + past participle.',
    ),

    // PAST PERFECT CONTINUOUS
    Exercise(
      id: 'ptpc_1',
      tenseId: 'past_perfect_continuous',
      type: ExerciseType.fillInBlank,
      question: 'I had ___ waiting for 3 hours when he arrived.',
      options: [],
      correctAnswer: 'been',
      explanation: 'Structure: had + been + verb-ing',
    ),

    // FUTURE WILL
    Exercise(
      id: 'fw_1',
      tenseId: 'future_will',
      type: ExerciseType.multipleChoice,
      question: 'I ___ help you with that.',
      options: ['will', 'would', 'going to', 'am'],
      correctAnswer: 'will',
      explanation: 'Use "will" for spontaneous decisions or offers.',
    ),
    Exercise(
      id: 'fw_2',
      tenseId: 'future_will',
      type: ExerciseType.fillInBlank,
      question: 'She ___ (not come) tomorrow.',
      options: [],
      correctAnswer: "won't come",
      explanation: "Negative: will + not = won't",
    ),

    // FUTURE GOING TO
    Exercise(
      id: 'fgt_1',
      tenseId: 'future_going_to',
      type: ExerciseType.multipleChoice,
      question: 'I ___ going to study medicine.',
      options: ['am', 'is', 'are', 'will'],
      correctAnswer: 'am',
      explanation: 'Use "am" with "I" in "going to" structure.',
    ),

    // FUTURE CONTINUOUS
    Exercise(
      id: 'fc_1',
      tenseId: 'future_continuous',
      type: ExerciseType.fillInBlank,
      question: 'At 8pm, I will ___ watching TV.',
      options: [],
      correctAnswer: 'be',
      explanation: 'Structure: will + be + verb-ing',
    ),

    // FUTURE PERFECT
    Exercise(
      id: 'fp_1',
      tenseId: 'future_perfect',
      type: ExerciseType.multipleChoice,
      question: 'By 2025, I will ___ graduated.',
      options: ['have', 'has', 'had', 'be'],
      correctAnswer: 'have',
      explanation: 'Structure: will + have + past participle',
    ),

    // CONDITIONAL SIMPLE
    Exercise(
      id: 'cs_1',
      tenseId: 'conditional_simple',
      type: ExerciseType.multipleChoice,
      question: 'I ___ travel if I had money.',
      options: ['will', 'would', 'can', 'could'],
      correctAnswer: 'would',
      explanation: 'Use "would" for hypothetical situations.',
    ),

    // CONDITIONAL PERFECT
    Exercise(
      id: 'cp_1',
      tenseId: 'conditional_perfect',
      type: ExerciseType.fillInBlank,
      question: 'I would ___ helped you if I had known.',
      options: [],
      correctAnswer: 'have',
      explanation: 'Structure: would + have + past participle',
    ),
  ];

  List<Exercise> getAllExercises() => List.from(defaultExercises);

  List<Exercise> getExercisesByTense(String tenseId) =>
      defaultExercises.where((e) => e.tenseId == tenseId).toList();

  List<Exercise> getExercisesForTenses(List<String> tenseIds) =>
      defaultExercises.where((e) => tenseIds.contains(e.tenseId)).toList();
}
