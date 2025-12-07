import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TranslatorView extends StatefulWidget {
  const TranslatorView({super.key});

  @override
  State<TranslatorView> createState() => _TranslatorViewState();
}

class _TranslatorViewState extends State<TranslatorView> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isEnglishToSpanish = true;
  String _translatedText = '';
  String? _error;
  bool _isLoading = false;
  Timer? _debounceTimer;

  // MyMemory Translation API (free, stable, no API key required)
  static const String _myMemoryApiUrl =
      'https://api.mymemory.translated.net/get';

  String get _fromLang => _isEnglishToSpanish ? 'en' : 'es';
  String get _toLang => _isEnglishToSpanish ? 'es' : 'en';
  String get _langPair => '$_fromLang|$_toLang';
  String get _fromLabel => _isEnglishToSpanish ? 'Inglés' : 'Español';
  String get _toLabel => _isEnglishToSpanish ? 'Español' : 'Inglés';

  void _swapLanguages() {
    setState(() {
      _isEnglishToSpanish = !_isEnglishToSpanish;
      // Swap texts
      final temp = _inputController.text;
      _inputController.text = _translatedText;
      _translatedText = temp;
      _error = null;
    });
  }

  void _onTextChanged(String text) {
    _debounceTimer?.cancel();

    if (text.trim().isEmpty) {
      setState(() {
        _translatedText = '';
        _error = null;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    // Wait 600ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _translate(text);
    });
  }

  Future<void> _translate(String text) async {
    if (text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _translatedText = '';
      });
      return;
    }

    try {
      final encodedText = Uri.encodeComponent(text.trim());
      final url = '$_myMemoryApiUrl?q=$encodedText&langpair=$_langPair';

      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data['responseData'];

        if (responseData != null) {
          final translation = responseData['translatedText'] as String?;

          // Check for API quota exceeded
          if (translation != null && translation.contains('MYMEMORY WARNING')) {
            setState(() {
              _error = 'Límite de traducciones alcanzado. Intenta más tarde.';
              _isLoading = false;
            });
            return;
          }

          if (translation != null && translation.isNotEmpty) {
            setState(() {
              _translatedText = translation;
              _error = null;
              _isLoading = false;
            });
            return;
          }
        }

        // API responded but no translation
        setState(() {
          _error = 'No se pudo traducir el texto';
          _isLoading = false;
        });
      } else if (response.statusCode == 429) {
        setState(() {
          _error = 'Demasiadas solicitudes. Espera un momento.';
          _isLoading = false;
        });
      } else if (response.statusCode >= 500) {
        setState(() {
          _error = 'Servicio de traducción no disponible';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error al conectar con el traductor';
          _isLoading = false;
        });
      }
    } on http.ClientException {
      if (mounted) {
        setState(() {
          _error = 'Sin conexión a internet';
          _isLoading = false;
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _error = 'La conexión tardó demasiado. Verifica tu internet.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error inesperado. Intenta de nuevo.';
          _isLoading = false;
        });
      }
    }
  }

  void _clearInput() {
    _inputController.clear();
    setState(() {
      _translatedText = '';
      _error = null;
      _isLoading = false;
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Traductor'), centerTitle: true),
      body: Column(
        children: [
          // Language toggle
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LanguageChip(label: _fromLabel, isActive: true),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _swapLanguages,
                  icon: const Icon(Icons.swap_horiz),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                _LanguageChip(label: _toLabel, isActive: false),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Input card
                  Expanded(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                            child: Row(
                              children: [
                                Text(
                                  _fromLabel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const Spacer(),
                                if (_inputController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: _clearInput,
                                    tooltip: 'Limpiar',
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              focusNode: _focusNode,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              onChanged: _onTextChanged,
                              style: const TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                hintText: _isEnglishToSpanish
                                    ? 'Type in English...'
                                    : 'Escribe en español...',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Loading indicator
                  if (_isLoading) const LinearProgressIndicator(),

                  const SizedBox(height: 8),

                  // Output card
                  Expanded(
                    child: Card(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Text(
                              _toLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: _error != null
                                  ? Row(
                                      children: [
                                        Icon(
                                          Icons.wifi_off,
                                          color: colorScheme.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _error!,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    )
                                  : SelectableText(
                                      _translatedText.isEmpty
                                          ? (_isEnglishToSpanish
                                                ? 'La traducción aparecerá aquí...'
                                                : 'Translation will appear here...')
                                          : _translatedText,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: _translatedText.isEmpty
                                            ? colorScheme.outline
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 16, color: colorScheme.outline),
                const SizedBox(width: 8),
                Text(
                  'Traducción automática (MyMemory)',
                  style: TextStyle(fontSize: 12, color: colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _LanguageChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isActive
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
