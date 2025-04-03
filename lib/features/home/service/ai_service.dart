import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiService {
  // This class is responsible for handling AI-related services.
  // Currently, it does not contain any methods or properties.
  // You can add methods to interact with AI models or APIs as needed.

  String generateAIAnalysisPrompt() {
    return '''
      Analyze the following soil and crop data and provide a structured JSON response that includes:
      - A summary of findings
      - Descriptive Analysis of soil moisture and nutrient trends
      - Predictive insights on what will happen if no action is taken
      - Recommended fertilizers with detailed application instructions
      - Irrigation plan to optimize soil moisture
      - Any necessary warnings
      - Final actionable steps

      Data:
      - Soil Moisture: 30%
      - Nitrogen: 20 ppm
      - Phosphorus: 15 ppm
      - Potassium: 10 ppm
      - Crop Type: Corn
      - Soil Type: Loamy
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
          {'role': 'system', 'content': 'You are an agricultural AI assistant'},
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch AI analysis');
    }
  }

  Future<void> fetchAndAnalyze() async {
    try {
      String prompt = generateAIAnalysisPrompt();
      Map<String, dynamic> analysis = await getAiAnalysis(prompt);
      print('AI Analysis: $analysis');
    } catch (e) {
      print('Error: $e');
    }
  }
}
