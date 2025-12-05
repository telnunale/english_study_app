import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for online translation using MyMemory API (free, no key required)
class TranslationService {
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';

  /// Translate text from source language to target language
  /// [langPair] format: "en|es" (from|to)
  Future<TranslationResult> translate({
    required String text,
    required String fromLang,
    required String toLang,
  }) async {
    if (text.trim().isEmpty) {
      return TranslationResult(success: false, error: 'El texto está vacío');
    }

    try {
      final uri = Uri.parse(
        _baseUrl,
      ).replace(queryParameters: {'q': text, 'langpair': '$fromLang|$toLang'});

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Tiempo de espera agotado'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['responseStatus'] == 200) {
          return TranslationResult(
            success: true,
            translatedText: data['responseData']['translatedText'],
            match: data['responseData']['match']?.toDouble() ?? 0.0,
          );
        } else {
          return TranslationResult(
            success: false,
            error: 'Error en la traducción: ${data['responseStatus']}',
          );
        }
      } else {
        return TranslationResult(
          success: false,
          error: 'Error de conexión: ${response.statusCode}',
        );
      }
    } catch (e) {
      return TranslationResult(
        success: false,
        error: 'Sin conexión a internet',
      );
    }
  }
}

class TranslationResult {
  final bool success;
  final String? translatedText;
  final String? error;
  final double match;

  TranslationResult({
    required this.success,
    this.translatedText,
    this.error,
    this.match = 0.0,
  });
}
