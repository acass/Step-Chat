import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/ai_query_response.dart';

class PineconeRAGService {
  final String _pineconeApiKey = AppConfig.pineconeApiKey;
  final String _openAiApiKey = AppConfig.openAiApiKey;
  final String _pineconeEnvironment = AppConfig.pineconeEnvironment;
  final String _pineconeIndexName = AppConfig.pineconeIndexName;

  /// Interprets user's natural language query and returns search terms
  Future<AIQueryResponse> interpretQuery(String userQuery) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.openAiApiUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a maintenance procedure router.
Given a natural language question, return the best Firestore search terms or document ID.
Return JSON only:
{
  "search_terms": "",
  "document_id": null
}'''
            },
            {
              'role': 'user',
              'content': userQuery,
            }
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final jsonResponse = jsonDecode(content);
        return AIQueryResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to interpret query: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error interpreting query: $e');
    }
  }

  /// Creates embeddings for a given text using OpenAI
  Future<List<double>> createEmbedding(String text) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.openAiApiUrl}/embeddings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'text-embedding-3-small',
          'input': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<double>.from(data['data'][0]['embedding']);
      } else {
        throw Exception('Failed to create embedding: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating embedding: $e');
    }
  }

  /// Queries Pinecone for similar procedures
  Future<List<String>> querySimilarProcedures(
      String query, {int topK = 5}) async {
    try {
      // Create embedding for the query
      final embedding = await createEmbedding(query);

      // Query Pinecone
      final response = await http.post(
        Uri.parse(
            'https://$_pineconeIndexName-$_pineconeEnvironment.svc.$_pineconeEnvironment.pinecone.io/query'),
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': _pineconeApiKey,
        },
        body: jsonEncode({
          'vector': embedding,
          'topK': topK,
          'includeMetadata': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final matches = data['matches'] as List;

        // Extract document IDs from matches
        return matches
            .map((match) => match['id'] as String)
            .toList();
      } else {
        throw Exception('Failed to query Pinecone: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error querying Pinecone: $e');
    }
  }

  /// Formats procedure data using AI
  Future<Map<String, dynamic>> formatProcedureData(
      Map<String, dynamic> rawData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.openAiApiUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a formatter.
Given procedure data from Firebase, return a clean JSON object.
Do not invent steps. Keep the original information intact.
Return in this format:
{
  "procedure_title": "",
  "steps": [
    { "number": 1, "text": "", "image": "" }
  ]
}'''
            },
            {
              'role': 'user',
              'content': jsonEncode(rawData),
            }
          ],
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        throw Exception(
            'Failed to format procedure data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error formatting procedure data: $e');
    }
  }
}
