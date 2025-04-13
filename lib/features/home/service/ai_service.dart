import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';

class AiService {
  String generateAIAnalysisPrompt(
      String dataToAnalyze, String cropType, String soilType, String plotName) {
    // Extract all ISO date strings from the data
    final dateRegex = RegExp(r'\d{4}-\d{2}-\d{2}');
    final allMatches =
        dateRegex.allMatches(dataToAnalyze).map((m) => m.group(0)!);
    final uniqueDates = allMatches.toSet().toList()..sort();

    // Default fallback in case there are not enough dates
    final firstDate = uniqueDates.isNotEmpty ? uniqueDates[0] : "2025-04-04";
    final secondDate = uniqueDates.length > 1 ? uniqueDates[1] : "2025-04-05";

    return '''
    You are an agricultural analysis assistant for a system called **SoilTrack**. Your task is to analyze the provided soil and crop data and respond strictly in the **exact JSON format** defined below.

    ⚠️ **IMPORTANT**:
    - DO NOT add any text before or after the JSON.
    - DO NOT change any keys or structure.
    - Ensure all fields are filled appropriately (no missing keys).
    - Use `"text"` for string values and numbers (e.g., 42.5, 7) for numeric ones.
    - Dates must match the format used in the data (e.g., "$firstDate").
    - Ensure the response is **valid JSON**. No explanations or comments.

    {
      "AI_Analysis": {
        "summary": {
          "findings": "text",
          "predictions": "text",
          "recommendations": "text"
        },
        "summary_of_findings": {
          "moisture_trends": { "$firstDate": ..., "$secondDate": ..., "trend": "..." },
          "nutrient_trends": {
            "N": { "$firstDate": ..., "$secondDate": ..., "trend": "..." },
            "P": { "$firstDate": ..., "$secondDate": ..., "trend": "..." },
            "K": { "$firstDate": ..., "$secondDate": ..., "trend": "..." }
          }
        },
        "predictive_insights": {
          "moisture": "text",
          "nutrients": "text"
        },
        "recommended_fertilizers": {
          "N": { "type": "text", "application_instructions": "text" },
          "P": { "type": "text", "application_instructions": "text" },
          "K": { "type": "text", "application_instructions": "text" }
        },
        "irrigation_plan": {
          "recommended_schedule": "text",
          "evaluation_methods": "text"
        },
        "warnings": {
          "nutrient_imbalances": "text",
          "drought_risks": "text"
        },
        "final_actionable_recommendations": [
          "text", "text", "text"
        ]
      }
    }

    Here is the data to analyze:
    $dataToAnalyze

    Additional context:
    Plot Name: $plotName
    Crop Type: $cropType
    Soil Type: $soilType
    ''';
  }

  Future<Map<String, dynamic>> getAiAnalysis(
    String prompt, {
    double temperature = 0.7,
    int maxTokens = 1200,
  }) async {
    final String? apiKey = dotenv.env['OPEN_AI_API_KEY'];
    if (apiKey == null) {
      throw Exception('API key not found in environment variables.');
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an agricultural AI assistant for the system called SoilTrack.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch AI analysis');
    }
  }

  Future<Map<String, dynamic>> getChatbotResponse(
    String prompt, {
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    final String? apiKey = dotenv.env['OPEN_AI_API_KEY'];
    if (apiKey == null) {
      throw Exception('API key not found in environment variables.');
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an agricultural AI assistant for the system called SoilTrack. Answer in a way that is clear, concise, and uses simple, understandable language. Ensure that your response is in paragraph form, but it is acceptable for it to consist of multiple paragraphs. If the user asks for a topic not related to soil, or farming, or agriculture, respond with "I am not sure about that. I can only help you with soil and farming-related questions."'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch AI analysis');
    }
  }
}
