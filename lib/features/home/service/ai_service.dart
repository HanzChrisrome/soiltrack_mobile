import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiService {
  String generateAIAnalysisPrompt(
      String dataToAnalyze, String cropType, String soilType, String plotName) {
    final dateRegex = RegExp(r'\d{4}-\d{2}-\d{2}');
    final allMatches =
        dateRegex.allMatches(dataToAnalyze).map((m) => m.group(0)!);
    final uniqueDates = allMatches.toSet().toList()..sort();

    final firstDate = uniqueDates.isNotEmpty ? uniqueDates[0] : "2025-04-04";
    final secondDate = uniqueDates.length > 1 ? uniqueDates[1] : "2025-04-05";
    final thirdDate = uniqueDates.length > 2 ? uniqueDates[2] : "2025-04-06";
    final latestDate = uniqueDates.isNotEmpty ? uniqueDates.last : "2025-04-06";

    return '''
    You are a helpful farm assistant working for a tool called **SoilTrack**. Each day, you help farmers understand what their soil and crop data means and what they need to do **today**.

    Your goal is to generate a clear, farmer-friendly daily action plan based on the latest data.

    ⚠️ VERY IMPORTANT:
    - Focus on **daily action** (what should the farmer do today).
    - DO NOT recommend external tests, expert advice, or tools.
    - DO NOT include any text outside the JSON.
    - Use language that is very simple and localized (can be understood by Filipino farmers).
    - Use dates from the data provided (latest date is "$latestDate").
    - All values must be in valid JSON format. Do not leave out any fields.
    - In today's focus, there can be multiple points or text.

    Here is the required format:

    {
      "AI_Analysis": {
        "date": "$latestDate",
        "today_focus": [
          "text",
        ],
        "summary": {
          "findings": "text",
          "predictions": "text",
          "recommendations": "text"
        },
        "summary_of_findings": {
          "moisture_trends": {
            "$firstDate": ..., 
            "$secondDate": ..., 
            "$thirdDate": ..., 
            "trend": "..."
          },
          "nutrient_trends": {
            "N": { "$firstDate": ..., "$secondDate": ..., "$thirdDate": ..., "trend": "..." },
            "P": { "$firstDate": ..., "$secondDate": ..., "$thirdDate": ..., "trend": "..." },
            "K": { "$firstDate": ..., "$secondDate": ..., "$thirdDate": ..., "trend": "..." }
          }
        },
        "predictive_insights": {
          "moisture": "text",
          "nutrients": "text"
        },
        "recommended_fertilizers": {
          "N": { "type": "text", "application_instructions": "text", "where_to_buy": "text" },
          "P": { "type": "text", "application_instructions": "text", "where_to_buy": "text" },
          "K": { "type": "text", "application_instructions": "text", "where_to_buy": "text" }
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

  String generateWeeklyAIAnalysisPrompt(
      String dataToAnalyze, String cropType, String soilType, String plotName) {
    final dateRegex = RegExp(r'\d{4}-\d{2}-\d{2}');
    final allMatches =
        dateRegex.allMatches(dataToAnalyze).map((m) => m.group(0)!);
    final uniqueDates = allMatches.toSet().toList()..sort();

    final recentDates = uniqueDates.length > 7
        ? uniqueDates.sublist(uniqueDates.length - 7)
        : uniqueDates;

    final formattedDateList = recentDates.map((d) => '"$d": ...').join(", ");

    return '''
    You are an agricultural analysis assistant for a system called **SoilTrack**. Your task is to analyze the provided weekly soil and crop data and respond strictly in the **exact JSON format** defined below.

    ⚠️ **IMPORTANT**:
    - DO NOT add any text before or after the JSON.
    - DO NOT change any keys or structure.
    - Ensure all fields are filled appropriately (no missing keys).
    - Use "text" for string values and numbers (e.g., 42.5, 7) for numeric ones.
    - Dates must match the format used in the data (e.g., those listed below).
    - Ensure the response is **valid JSON**. No explanations or comments.
    - The data for the NPK is in mg/l, and the moisture is in percentage.

    🧠 **TREND ANALYSIS INSTRUCTIONS**:
    - For each `"trend"` field under `"moisture_trends"` and `"nutrient_trends"`:
    - Provide a `"label"`: One of the following values: `"increasing"`, `"decreasing"`, `"fluctuating"`, or `"stable"`.
    - Include a `"description"`: A short but meaningful explanation, e.g., "Moisture decreased steadily throughout the week", "Nitrogen levels fluctuated significantly day to day", etc.

    🗓️ **DATE RANGE INSTRUCTION**:
    - Extract the earliest and latest dates from the provided data.
    - Format the date range in the style: "April 6 (This date is sample only use the actual date) - April 13, 2025 (This date is sample only use the actual date)" and include it in "summary.date_range".
    
    {
      "AI_Analysis": {
        "summary": {
          "date_range": "text",
          "findings": "text",
          "predictions": "text",
          "recommendations": "text"
        },
        "summary_of_findings": {
          "moisture_trends": {
            $formattedDateList,
            "trend": "text"
          },
          "nutrient_trends": {
            "N": {
              $formattedDateList,
              "trend": "text"
            },
            "P": {
              $formattedDateList,
              "trend": "text"
            },
            "K": {
              $formattedDateList,
              "trend": "text"
            }
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

  String generateAISummaryPrompt(String rawFormattedData) {
    return '''
  You are a smart assistant for **SoilTrack**, an agriculture analysis platform. Your role is to summarize data collected from multiple crop plots over a specific period. Respond in **valid JSON** using the structure below.

  ⚠️ IMPORTANT:
  - Do NOT include any text before or after the JSON.
  - Strictly follow the keys and structure.
  - Do NOT suggest consulting experts or external tests.
  - Do NOT recommend buying or installing tools or tests.
  - Keep suggestions **practical and immediate**, based only on the data provided.
  - Use 1–2 sentence explanations.
  - Use simple, actionable language and can be understand by old farmers.

  🧠 TASKS:
  - Analyze all moisture and NPK trends across plots.
  - Identify concerning trends (e.g., rapid drops, spikes).
  - Provide a short summary headline.
  - Provide clear warnings and practical recommendations.

  📤 FORMAT:
  {
    "headline": "text",
    "summary": "text",
    "warnings": [ "text", "text" ],
    "recommendations": [ "text", "text" ]
  }

  Here is the data to analyze:
  $rawFormattedData
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
