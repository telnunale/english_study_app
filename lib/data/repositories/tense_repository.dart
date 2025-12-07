import '../models/verb_tense.dart';

import '../services/storage_service.dart';

/// Repository containing all 14 verb tenses with verified grammatical content
class TenseRepository {
  static final TenseRepository _instance = TenseRepository._internal();
  factory TenseRepository() => _instance;
  TenseRepository._internal();

  final StorageService _storage = StorageService();
  List<VerbTense> _customTenses = [];

  Future<void> init() async {
    await _storage.init();
    _customTenses = await _storage.getModifiedTenses();
  }

  // Helper helper to merge defaults with overrides
  VerbTense _getEffectiveTense(VerbTense defaultTense) {
    try {
      return _customTenses.firstWhere((t) => t.id == defaultTense.id);
    } catch (_) {
      return defaultTense;
    }
  }

  Future<void> updateTense(VerbTense tense) async {
    await _storage.init();
    await _storage.saveVerbTense(tense);
    _customTenses = await _storage.getModifiedTenses();
  }

  static const List<VerbTense> _defaultTenses = [
    // PRESENT GROUP
    VerbTense(
      id: 'present_simple',
      name: 'Present Simple',
      spanishName: 'Presente Simple',
      spanishEquivalent: 'Presente de indicativo (yo trabajo)',
      group: 'Present',
      whenToUse: '''
• Hábitos y rutinas: I work every day
• Verdades generales: Water boils at 100°C
• Estados permanentes: She lives in Madrid
• Horarios y programas: The train leaves at 8''',
      affirmativeStructure: 'Subject + verb (+ s/es for he/she/it)',
      negativeStructure: 'Subject + do/does + not + verb',
      questionStructure: 'Do/Does + subject + verb?',
      examples: [
        TenseExample(
          english: 'I work in a bank.',
          spanish: 'Trabajo en un banco.',
        ),
        TenseExample(
          english: 'She plays tennis on Sundays.',
          spanish: 'Ella juega tenis los domingos.',
        ),
        TenseExample(
          english: 'Do you speak English?',
          spanish: '¿Hablas inglés?',
        ),
      ],
    ),
    VerbTense(
      id: 'present_continuous',
      name: 'Present Continuous',
      spanishName: 'Presente Continuo',
      spanishEquivalent: 'Estar + gerundio (estoy trabajando)',
      group: 'Present',
      whenToUse: '''
• Acciones en progreso ahora: I am reading a book
• Situaciones temporales: He is living with his parents
• Planes futuros confirmados: We are meeting tomorrow
• Cambios y tendencias: Prices are rising''',
      affirmativeStructure: 'Subject + am/is/are + verb-ing',
      negativeStructure: 'Subject + am/is/are + not + verb-ing',
      questionStructure: 'Am/Is/Are + subject + verb-ing?',
      examples: [
        TenseExample(
          english: 'I am studying English.',
          spanish: 'Estoy estudiando inglés.',
        ),
        TenseExample(
          english: 'They are watching TV.',
          spanish: 'Ellos están viendo la tele.',
        ),
        TenseExample(
          english: 'Is she working?',
          spanish: '¿Está ella trabajando?',
        ),
      ],
    ),
    VerbTense(
      id: 'present_perfect',
      name: 'Present Perfect',
      spanishName: 'Presente Perfecto',
      spanishEquivalent: 'Pretérito perfecto (he trabajado)',
      group: 'Present',
      whenToUse: '''
• Experiencias de vida: I have been to Paris
• Acciones con resultado presente: I have lost my keys
• Acciones que empezaron en el pasado y continúan: I have lived here for 5 years
• Con just, already, yet, ever, never''',
      affirmativeStructure: 'Subject + have/has + past participle',
      negativeStructure: 'Subject + have/has + not + past participle',
      questionStructure: 'Have/Has + subject + past participle?',
      examples: [
        TenseExample(
          english: 'I have visited London twice.',
          spanish: 'He visitado Londres dos veces.',
        ),
        TenseExample(
          english: 'She has just arrived.',
          spanish: 'Ella acaba de llegar.',
        ),
        TenseExample(
          english: 'Have you ever eaten sushi?',
          spanish: '¿Has comido alguna vez sushi?',
        ),
      ],
    ),
    VerbTense(
      id: 'present_perfect_continuous',
      name: 'Present Perfect Continuous',
      spanishName: 'Presente Perfecto Continuo',
      spanishEquivalent: 'He estado + gerundio (he estado trabajando)',
      group: 'Present',
      whenToUse: '''
• Acciones que empezaron en el pasado y continúan (énfasis en duración): I have been waiting for an hour
• Acciones recientes con resultados visibles: You have been crying
• Con for y since para duración''',
      affirmativeStructure: 'Subject + have/has + been + verb-ing',
      negativeStructure: 'Subject + have/has + not + been + verb-ing',
      questionStructure: 'Have/Has + subject + been + verb-ing?',
      examples: [
        TenseExample(
          english: 'I have been learning Spanish for 2 years.',
          spanish: 'He estado aprendiendo español durante 2 años.',
        ),
        TenseExample(
          english: 'It has been raining all day.',
          spanish: 'Ha estado lloviendo todo el día.',
        ),
        TenseExample(
          english: 'How long have you been working here?',
          spanish: '¿Cuánto tiempo llevas trabajando aquí?',
        ),
      ],
    ),

    // PAST GROUP
    VerbTense(
      id: 'past_simple',
      name: 'Past Simple',
      spanishName: 'Pasado Simple',
      spanishEquivalent: 'Pretérito indefinido (trabajé)',
      group: 'Past',
      whenToUse: '''
• Acciones terminadas en el pasado: I visited Paris last year
• Serie de acciones pasadas: I woke up, had breakfast and left
• Estados pasados: She was happy
• Con ago, yesterday, last week, in 2020''',
      affirmativeStructure:
          'Subject + verb in past (regular: -ed / irregular: 2nd column)',
      negativeStructure: 'Subject + did + not + verb',
      questionStructure: 'Did + subject + verb?',
      examples: [
        TenseExample(english: 'I worked yesterday.', spanish: 'Trabajé ayer.'),
        TenseExample(
          english: 'She went to the cinema.',
          spanish: 'Ella fue al cine.',
        ),
        TenseExample(
          english: 'Did you see the match?',
          spanish: '¿Viste el partido?',
        ),
      ],
    ),
    VerbTense(
      id: 'past_continuous',
      name: 'Past Continuous',
      spanishName: 'Pasado Continuo',
      spanishEquivalent: 'Pretérito imperfecto (estaba trabajando)',
      group: 'Past',
      whenToUse: '''
• Acción en progreso en un momento del pasado: At 8pm I was watching TV
• Acción interrumpida: I was sleeping when you called
• Dos acciones simultáneas en el pasado: While I was reading, he was cooking
• Describir el contexto de una historia''',
      affirmativeStructure: 'Subject + was/were + verb-ing',
      negativeStructure: 'Subject + was/were + not + verb-ing',
      questionStructure: 'Was/Were + subject + verb-ing?',
      examples: [
        TenseExample(
          english: 'I was studying at 10pm.',
          spanish: 'Estaba estudiando a las 10pm.',
        ),
        TenseExample(
          english: 'They were playing when it started raining.',
          spanish: 'Ellos estaban jugando cuando empezó a llover.',
        ),
        TenseExample(
          english: 'What were you doing?',
          spanish: '¿Qué estabas haciendo?',
        ),
      ],
    ),
    VerbTense(
      id: 'past_perfect',
      name: 'Past Perfect',
      spanishName: 'Pasado Perfecto',
      spanishEquivalent: 'Pretérito pluscuamperfecto (había trabajado)',
      group: 'Past',
      whenToUse: '''
• Acción anterior a otra acción pasada: I had finished before he arrived
• Experiencias hasta un momento del pasado: By 2020, I had visited 10 countries
• Reported speech: She said she had seen him''',
      affirmativeStructure: 'Subject + had + past participle',
      negativeStructure: 'Subject + had + not + past participle',
      questionStructure: 'Had + subject + past participle?',
      examples: [
        TenseExample(
          english: 'I had already eaten when she arrived.',
          spanish: 'Ya había comido cuando ella llegó.',
        ),
        TenseExample(
          english: 'He had never seen the sea before.',
          spanish: 'Él nunca había visto el mar antes.',
        ),
        TenseExample(
          english: 'Had you finished the report?',
          spanish: '¿Habías terminado el informe?',
        ),
      ],
    ),
    VerbTense(
      id: 'past_perfect_continuous',
      name: 'Past Perfect Continuous',
      spanishName: 'Pasado Perfecto Continuo',
      spanishEquivalent: 'Había estado + gerundio (había estado trabajando)',
      group: 'Past',
      whenToUse: '''
• Acción en progreso antes de otra acción pasada (énfasis en duración): I had been waiting for 2 hours when he arrived
• Causa de un resultado pasado: She was tired because she had been running''',
      affirmativeStructure: 'Subject + had + been + verb-ing',
      negativeStructure: 'Subject + had + not + been + verb-ing',
      questionStructure: 'Had + subject + been + verb-ing?',
      examples: [
        TenseExample(
          english: 'I had been studying for 3 hours.',
          spanish: 'Había estado estudiando durante 3 horas.',
        ),
        TenseExample(
          english: 'They had been living there since 2010.',
          spanish: 'Habían estado viviendo allí desde 2010.',
        ),
        TenseExample(
          english: 'How long had you been waiting?',
          spanish: '¿Cuánto tiempo habías estado esperando?',
        ),
      ],
    ),

    // FUTURE GROUP
    VerbTense(
      id: 'future_will',
      name: 'Future Simple (will)',
      spanishName: 'Futuro Simple (will)',
      spanishEquivalent: 'Futuro simple (trabajaré)',
      group: 'Future',
      whenToUse: '''
• Predicciones: It will rain tomorrow
• Decisiones espontáneas: I'll help you
• Promesas: I will call you
• Ofertas y peticiones: Will you open the door?''',
      affirmativeStructure: 'Subject + will + verb',
      negativeStructure: 'Subject + will + not + verb',
      questionStructure: 'Will + subject + verb?',
      examples: [
        TenseExample(
          english: 'I will study tomorrow.',
          spanish: 'Estudiaré mañana.',
        ),
        TenseExample(
          english: 'She won\'t come to the party.',
          spanish: 'Ella no vendrá a la fiesta.',
        ),
        TenseExample(english: 'Will you help me?', spanish: '¿Me ayudarás?'),
      ],
    ),
    VerbTense(
      id: 'future_going_to',
      name: 'Future (going to)',
      spanishName: 'Futuro (going to)',
      spanishEquivalent: 'Ir a + infinitivo (voy a trabajar)',
      group: 'Future',
      whenToUse: '''
• Planes e intenciones: I'm going to study medicine
• Predicciones basadas en evidencia: Look at those clouds! It's going to rain
• Acciones inminentes: Watch out! You're going to fall!''',
      affirmativeStructure: 'Subject + am/is/are + going to + verb',
      negativeStructure: 'Subject + am/is/are + not + going to + verb',
      questionStructure: 'Am/Is/Are + subject + going to + verb?',
      examples: [
        TenseExample(
          english: 'I am going to travel next month.',
          spanish: 'Voy a viajar el próximo mes.',
        ),
        TenseExample(
          english: 'He is going to buy a car.',
          spanish: 'Él va a comprar un coche.',
        ),
        TenseExample(
          english: 'Are you going to come?',
          spanish: '¿Vas a venir?',
        ),
      ],
    ),
    VerbTense(
      id: 'future_continuous',
      name: 'Future Continuous',
      spanishName: 'Futuro Continuo',
      spanishEquivalent: 'Estaré + gerundio (estaré trabajando)',
      group: 'Future',
      whenToUse: '''
• Acción en progreso en un momento futuro: At 8pm I will be watching TV
• Acciones planificadas como rutina futura: This time next week I will be lying on a beach
• Preguntas corteses sobre planes: Will you be using the car tonight?''',
      affirmativeStructure: 'Subject + will + be + verb-ing',
      negativeStructure: 'Subject + will + not + be + verb-ing',
      questionStructure: 'Will + subject + be + verb-ing?',
      examples: [
        TenseExample(
          english: 'I will be working at 9am.',
          spanish: 'Estaré trabajando a las 9am.',
        ),
        TenseExample(
          english: 'This time tomorrow we will be flying to Paris.',
          spanish: 'Mañana a esta hora estaremos volando a París.',
        ),
        TenseExample(
          english: 'Will you be needing the car?',
          spanish: '¿Necesitarás el coche?',
        ),
      ],
    ),
    VerbTense(
      id: 'future_perfect',
      name: 'Future Perfect',
      spanishName: 'Futuro Perfecto',
      spanishEquivalent: 'Habré + participio (habré trabajado)',
      group: 'Future',
      whenToUse: '''
• Acción completada antes de un momento futuro: By 2025, I will have finished my degree
• Con by, by the time, before: I will have left by the time you arrive''',
      affirmativeStructure: 'Subject + will + have + past participle',
      negativeStructure: 'Subject + will + not + have + past participle',
      questionStructure: 'Will + subject + have + past participle?',
      examples: [
        TenseExample(
          english: 'By next year, I will have graduated.',
          spanish: 'Para el próximo año, me habré graduado.',
        ),
        TenseExample(
          english: 'She will have finished by 5pm.',
          spanish: 'Ella habrá terminado para las 5pm.',
        ),
        TenseExample(
          english: 'Will you have completed it by Monday?',
          spanish: '¿Lo habrás completado para el lunes?',
        ),
      ],
    ),

    // CONDITIONAL GROUP
    VerbTense(
      id: 'conditional_simple',
      name: 'Conditional Simple',
      spanishName: 'Condicional Simple',
      spanishEquivalent: 'Condicional simple (trabajaría)',
      group: 'Conditional',
      whenToUse: '''
• Situaciones hipotéticas: If I had money, I would travel
• Peticiones corteses: Would you help me?
• Deseos: I would like a coffee
• Consejos: I would study more if I were you''',
      affirmativeStructure: 'Subject + would + verb',
      negativeStructure: 'Subject + would + not + verb',
      questionStructure: 'Would + subject + verb?',
      examples: [
        TenseExample(
          english: 'I would travel if I had money.',
          spanish: 'Viajaría si tuviera dinero.',
        ),
        TenseExample(
          english: 'She would help you.',
          spanish: 'Ella te ayudaría.',
        ),
        TenseExample(
          english: 'Would you like some coffee?',
          spanish: '¿Te gustaría un café?',
        ),
      ],
    ),
    VerbTense(
      id: 'conditional_perfect',
      name: 'Conditional Perfect',
      spanishName: 'Condicional Perfecto',
      spanishEquivalent: 'Condicional compuesto (habría trabajado)',
      group: 'Conditional',
      whenToUse: '''
• Situaciones hipotéticas en el pasado: If I had studied, I would have passed
• Lamentarse de algo: I would have helped you (but I didn't know)
• Críticas: You should have told me''',
      affirmativeStructure: 'Subject + would + have + past participle',
      negativeStructure: 'Subject + would + not + have + past participle',
      questionStructure: 'Would + subject + have + past participle?',
      examples: [
        TenseExample(
          english: 'I would have called you.',
          spanish: 'Te habría llamado.',
        ),
        TenseExample(
          english: 'She would have come if you had invited her.',
          spanish: 'Ella habría venido si la hubieras invitado.',
        ),
        TenseExample(
          english: 'Would you have accepted?',
          spanish: '¿Habrías aceptado?',
        ),
      ],
    ),
  ];

  List<VerbTense> getAllTenses() {
    return _defaultTenses.map((t) => _getEffectiveTense(t)).toList();
  }

  List<VerbTense> getTensesByGroup(String group) =>
      getAllTenses().where((t) => t.group == group).toList();

  VerbTense? getTenseById(String id) {
    try {
      return getAllTenses().firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> getGroups() => ['Present', 'Past', 'Future', 'Conditional'];
}
