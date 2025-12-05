import 'package:flutter/material.dart';
import '../../data/models/verb_tense.dart';

class TenseDetailView extends StatelessWidget {
  final VerbTense tense;

  const TenseDetailView({super.key, required this.tense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tense.spanishName)),
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mantén pulsado una sección para ampliarla',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // When to Use
            _ExpandableSectionCard(
              title: '¿Cuándo se usa?',
              icon: Icons.lightbulb_outline,
              child: Text(
                tense.whenToUse,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),

            // Structures
            _ExpandableSectionCard(
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
            _ExpandableSectionCard(
              title: 'Ejemplos',
              icon: Icons.format_quote,
              child: Column(
                children: tense.examples
                    .map(
                      (example) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              example.english,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              example.spanish,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableSectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ExpandableSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  State<_ExpandableSectionCard> createState() => _ExpandableSectionCardState();
}

class _ExpandableSectionCardState extends State<_ExpandableSectionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() => _isExpanded = true);
    _controller.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() => _isExpanded = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _elevationAnimation.value,
              color: _isExpanded
                  ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3)
                  : null,
              child: Padding(
                padding: EdgeInsets.all(_isExpanded ? 20 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.icon,
                          size: _isExpanded ? 24 : 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: _isExpanded ? 18 : null,
                              ),
                        ),
                        const Spacer(),
                        if (_isExpanded)
                          Icon(
                            Icons.zoom_in,
                            size: 16,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                      ],
                    ),
                    SizedBox(height: _isExpanded ? 16 : 12),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: _isExpanded ? 16 : 14,
                        height: _isExpanded ? 1.6 : 1.4,
                      ),
                      child: widget.child,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
          child: Text(structure, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
