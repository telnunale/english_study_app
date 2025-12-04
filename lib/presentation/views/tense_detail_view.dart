import 'package:flutter/material.dart';
import '../../data/models/verb_tense.dart';

class TenseDetailView extends StatelessWidget {
  final VerbTense tense;

  const TenseDetailView({super.key, required this.tense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tense.spanishName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tense.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.translate, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tense.spanishEquivalent,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // When to Use
            _SectionCard(
              title: '¿Cuándo se usa?',
              icon: Icons.lightbulb_outline,
              child: Text(
                tense.whenToUse,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),

            // Structures
            _SectionCard(
              title: 'Estructuras',
              icon: Icons.format_list_bulleted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StructureRow(
                    label: 'Afirmativa',
                    structure: tense.affirmativeStructure,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _StructureRow(
                    label: 'Negativa',
                    structure: tense.negativeStructure,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _StructureRow(
                    label: 'Pregunta',
                    structure: tense.questionStructure,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Examples
            _SectionCard(
              title: 'Ejemplos',
              icon: Icons.format_quote,
              child: Column(
                children: tense.examples.map((example) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        example.english,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        example.spanish,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StructureRow extends StatelessWidget {
  final String label;
  final String structure;
  final Color color;

  const _StructureRow({
    required this.label,
    required this.structure,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            structure,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
