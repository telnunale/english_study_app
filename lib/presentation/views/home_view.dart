import 'package:flutter/material.dart';
import 'study_selector_view.dart';
import 'tenses_view.dart';
import 'dictionary_view.dart';
import 'exercises_view.dart';
import 'management_view.dart';
import 'translator_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  bool _showManagement = false;

  List<Widget> get _pages => [
    StudySelectorView(
      showManagement: _showManagement,
      onToggleManagement: (value) {
        setState(() {
          _showManagement = value;
          // Si desactivamos gestión y estábamos en esa pestaña, volver a Estudiar
          if (!_showManagement && _selectedIndex >= 5) {
            _selectedIndex = 0;
          }
        });
      },
    ),
    const TensesView(),
    const DictionaryView(),
    const ExercisesView(),
    const TranslatorView(),
    if (_showManagement) const ManagementView(),
  ];

  List<NavigationDestination> get _destinations => [
    const NavigationDestination(
      icon: Icon(Icons.check_circle_outline),
      selectedIcon: Icon(Icons.check_circle),
      label: 'Estudiar',
    ),
    const NavigationDestination(
      icon: Icon(Icons.access_time_outlined),
      selectedIcon: Icon(Icons.access_time_filled),
      label: 'Tiempos',
    ),
    const NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book),
      label: 'Diccionario',
    ),
    const NavigationDestination(
      icon: Icon(Icons.quiz_outlined),
      selectedIcon: Icon(Icons.quiz),
      label: 'Ejercicios',
    ),
    const NavigationDestination(
      icon: Icon(Icons.translate_outlined),
      selectedIcon: Icon(Icons.translate),
      label: 'Traductor',
    ),
    if (_showManagement)
      const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Gestión',
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}
