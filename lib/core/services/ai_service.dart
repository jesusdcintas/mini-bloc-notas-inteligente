import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
	final String apiKey;
	final http.Client _client;

	AiService({required this.apiKey, http.Client? client}) : _client = client ?? http.Client();

	  Uri _buildUri() => Uri.parse(
		  'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey');

	Map<String, dynamic> _buildPayload(String promptPrefix, String text) {
		final prompt = '$promptPrefix\n\n$text';
		return {
			'contents': [
				{
					'parts': [
						{'text': prompt}
					]
				}
			]
		};
	}

	Future<String> summarize(String text) async {
		final payload = _buildPayload('Summarize the following text:', text);
		return await _postAndExtract(payload);
	}

	Future<String> improve(String text) async {
		final payload = _buildPayload('Improve the following text:', text);
		return await _postAndExtract(payload);
	}

	Future<String> _postAndExtract(Map<String, dynamic> payload) async {
		final uri = _buildUri();
		final resp = await _client.post(uri,
				headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));

		if (resp.statusCode != 200 && resp.statusCode != 201) {
			throw Exception('AI service error: ${resp.statusCode} ${resp.body}');
		}

		final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;

		try {
			final candidates = data['candidates'] as List<dynamic>;
			final first = candidates.first as Map<String, dynamic>;
			final content = first['content'] as Map<String, dynamic>;
			final parts = content['parts'] as List<dynamic>;
			final text = parts.first['text'] as String;
			return text;
		} catch (e) {
			throw Exception('Unexpected AI response format: $e');
		}
	}
}
