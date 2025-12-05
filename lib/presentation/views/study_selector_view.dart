import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/tense_viewmodel.dart';

class StudySelectorView extends StatelessWidget {
  final bool showManagement;
  final ValueChanged<bool> onToggleManagement;

  const StudySelectorView({
    super.key,
    required this.showManagement,
    required this.onToggleManagement,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Qué quieres estudiar?'),
        actions: [
          Consumer<TenseViewModel>(
            builder: (context, vm, _) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'all') vm.selectAll();
                if (value == 'none') vm.clearAll();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('Seleccionar todos'),
                ),
                const PopupMenuItem(
                  value: 'none',
                  child: Text('Limpiar selección'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<TenseViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 48,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${vm.selectedTenseIds.length} tiempos seleccionados',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Los ejercicios mostrarán solo estos tiempos',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...vm.groups.map(
                (group) => _buildGroupSection(context, vm, group),
              ),

              // Switch para activar/desactivar Gestión
              const SizedBox(height: 24),
              const Divider(),
              SwitchListTile(
                value: showManagement,
                onChanged: onToggleManagement,
                title: const Text('Modo Gestión'),
                subtitle: Text(
                  showManagement
                      ? 'Pestaña de gestión visible'
                      : 'Pestaña de gestión oculta',
                ),
                secondary: Icon(
                  showManagement ? Icons.settings : Icons.settings_outlined,
                  color: showManagement
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupSection(
    BuildContext context,
    TenseViewModel vm,
    String group,
  ) {
    final tenses = vm.getTensesByGroup(group);
    final selectedCount = tenses.where((t) => vm.isTenseSelected(t.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                group,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$selectedCount/${tenses.length}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
        ...tenses.map(
          (tense) => Card(
            child: CheckboxListTile(
              value: vm.isTenseSelected(tense.id),
              onChanged: (_) => vm.toggleTense(tense.id),
              title: Text(tense.spanishName),
              subtitle: Text(tense.name),
              secondary: Icon(
                vm.isTenseSelected(tense.id)
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: vm.isTenseSelected(tense.id)
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
