import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiService {
  // This class is responsible for handling AI-related services.
  // Currently, it does not contain any methods or properties.
  // You can add methods to interact with AI models or APIs as needed.

  String generateAIAnalysisPrompt(
      String dataToAnalyze, String cropType, String soilType, String plotName) {
    return '''
      You are an agricultural AI for the system SoilTrack. Analyze the following soil and crop data and return your response in the following strict JSON format:

      You are an agricultural analysis assistant for a system called **SoilTrack**. Your task is to analyze the provided soil and crop data and respond strictly in the **exact JSON format** defined below.

      ⚠️ **IMPORTANT**:
      - DO NOT add any text before or after the JSON.
      - DO NOT change any keys or structure.
      - Ensure all fields are filled appropriately (no missing keys).
      - Use `"text"` for string values and numbers (e.g., 42.5, 7) for numeric ones.
      - Dates must match the format used in the data (e.g., "2025-04-04").
      - Ensure the response is **valid JSON**. No explanations or comments.

      {
        "AI_Analysis": {
          "summary": {
            "findings": "text",
            "predictions": "text",
            "recommendations": "text"
          },
          "summary_of_findings": {
            "moisture_trends": { "2025-04-04": ..., "2025-04-05": ..., "trend": "..." },
            "nutrient_trends": {
              "N": { "2025-04-04": ..., "2025-04-05": ..., "trend": "..." },
              "P": { "2025-04-04": ..., "2025-04-05": ..., "trend": "..." },
              "K": { "2025-04-04": ..., "2025-04-05": ..., "trend": "..." }
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

  Future<Map<String, dynamic>> getAiAnalysis(String prompt) async {
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
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch AI analysis');
    }
  }

  // Future<void> fetchAndAnalyze() async {
  //   try {
  //     String prompt = generateAIAnalysisPrompt();
  //     Map<String, dynamic> analysis = await getAiAnalysis(prompt);
  //     print('AI Analysis: $analysis');
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
}
