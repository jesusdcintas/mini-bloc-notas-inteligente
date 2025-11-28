import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para interactuar con la API de IA (Google Gemini)
/// 
/// Para usar este servicio necesitas una API Key de Google AI Studio:
/// https://aistudio.google.com/app/apikey
class AIService {
  // ⚠️ IMPORTANTE: Reemplaza esto con tu API Key de Gemini
  // Puedes obtenerla gratis en: https://aistudio.google.com/app/apikey
  static const String _apiKey = 'AIzaSyBex2JwgbIqV-xPqn6NjUtBebcgsF4y97M';
  
  static const String _baseUrl = 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Resumir el texto de una nota
  Future<String> summarizeText(String text) async {
    if (_apiKey == 'TU_API_KEY_AQUI') {
      // Modo demo si no hay API key configurada
      return _demoSummarize(text);
    }

    try {
      final response = await _callGeminiAPI(
        'Resume el siguiente texto de manera concisa, manteniendo las ideas principales. '
        'El resumen debe ser breve pero informativo:\n\n$text',
      );
      return response;
    } catch (e) {
      throw Exception('Error al resumir el texto: $e');
    }
  }

  /// Mejorar el texto de una nota
  Future<String> improveText(String text) async {
    if (_apiKey == 'TU_API_KEY_AQUI') {
      // Modo demo si no hay API key configurada
      return _demoImprove(text);
    }

    try {
      final response = await _callGeminiAPI(
        'Mejora el siguiente texto corrigiendo errores gramaticales, '
        'mejorando la redacción y haciéndolo más claro y profesional. '
        'Mantén el mismo significado y tono:\n\n$text',
      );
      return response;
    } catch (e) {
      throw Exception('Error al mejorar el texto: $e');
    }
  }

  /// Llamada a la API de Gemini
  Future<String> _callGeminiAPI(String prompt) async {
    final url = Uri.parse('$_baseUrl?key=$_apiKey');
    
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      return text as String;
    } else {
      throw Exception('Error de API: ${response.statusCode} - ${response.body}');
    }
  }

  /// Resumen en modo demo (sin API key)
  String _demoSummarize(String text) {
    if (text.length <= 100) {
      return text;
    }
    // Simular un resumen simple
    final words = text.split(' ');
    final summaryWords = words.take((words.length * 0.4).ceil()).toList();
    return '📝 RESUMEN (Demo):\n${summaryWords.join(' ')}...';
  }

  /// Mejora en modo demo (sin API key)
  String _demoImprove(String text) {
    // Simular una mejora simple
    var improved = text;
    
    // Capitalizar primera letra de cada oración
    improved = improved.replaceAllMapped(
      RegExp(r'(^|[.!?]\s+)([a-z])'),
      (match) => '${match.group(1)}${match.group(2)!.toUpperCase()}',
    );
    
    return '✨ TEXTO MEJORADO (Demo):\n$improved\n\n'
        '💡 Nota: Configura tu API Key de Gemini para obtener mejoras reales con IA.';
  }
}
