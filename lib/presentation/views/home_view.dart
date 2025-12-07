import 'package:flutter/material.dart';
import '../../data/services/storage_service.dart';
import 'study_selector_view.dart';
import 'tenses_view.dart';
import 'verbs_view.dart';
import 'exercises_view.dart';
import 'management_view.dart';
import 'translator_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final StorageService _storage = StorageService();
  int _selectedIndex = 0;
  bool _showManagement = false;
  bool _showTranslator = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _storage.init();
    final translatorEnabled = await _storage.getTranslatorEnabled();
    setState(() {
      _showTranslator = translatorEnabled;
      _isLoading = false;
    });
  }

  void _onTranslatorToggled() {
    _loadSettings();
    // Adjust selected index if needed
    if (!_showTranslator && _selectedIndex == 4) {
      setState(() => _selectedIndex = 0);
    }
  }

  List<Widget> get _pages {
    final pages = <Widget>[
      StudySelectorView(
        showManagement: _showManagement,
        onToggleManagement: (value) {
          setState(() {
            _showManagement = value;
            // Si desactivamos gestión y estábamos en esa pestaña, volver a Estudiar
            final maxIndex = _destinations.length - 1;
            if (_selectedIndex > maxIndex) {
              _selectedIndex = 0;
            }
          });
        },
      ),
      const TensesView(),
      const VerbsView(),
      const ExercisesView(),
    ];

    if (_showTranslator) {
      pages.add(const TranslatorView());
    }

    if (_showManagement) {
      pages.add(ManagementView(onTranslatorToggled: _onTranslatorToggled));
    }

    return pages;
  }

  List<NavigationDestination> get _destinations {
    final dests = <NavigationDestination>[
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
        icon: Icon(Icons.list_alt_outlined),
        selectedIcon: Icon(Icons.list_alt),
        label: 'Verbos',
      ),
      const NavigationDestination(
        icon: Icon(Icons.quiz_outlined),
        selectedIcon: Icon(Icons.quiz),
        label: 'Ejercicios',
      ),
    ];

    if (_showTranslator) {
      dests.add(
        const NavigationDestination(
          icon: Icon(Icons.translate_outlined),
          selectedIcon: Icon(Icons.translate),
          label: 'Traductor',
        ),
      );
    }

    if (_showManagement) {
      dests.add(
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Gestión',
        ),
      );
    }

    return dests;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Ensure selected index is valid
    final maxIndex = _destinations.length - 1;
    if (_selectedIndex > maxIndex) {
      _selectedIndex = maxIndex;
    }

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
