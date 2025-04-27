import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';

class AiService {
  String generateAIAnalysisPrompt(String dataToAnalyze, String cropType,
      String soilType, String plotName, String weatherForecast) {
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
    - Focus on **daily actionable tasks** (what should the farmer do **today**).
    - Provide a **detailed analysis** of findings, predictions, and recommendations.
    - DO NOT recommend external tests, expert advice, or tools.
    - DO NOT include any text outside the JSON.
    - Use "text" for string values and numbers (e.g., 42.5, 7) for numeric ones.
    - Use dates from the data provided (latest date is "$latestDate").
    - All values must be in valid JSON format. Do not leave out any fields.
    - Provide at least 2 sentences of context or analysis for each section (findings, predictions, recommendations).
    - In today's focus, there can be multiple points or text.
    - The data for the NPK is in ppm, and the moisture is in percentage.
    - In the headline section, summarize the most important findings in a few words.
    - In the status, provide only if it is **good**, **bad**, **moderate**, or **excellent**.
    - Before saying an acceptable range for the crop planted, please check first the general recommendations or guideline for the NPK nutrient concentrations for the crop planted in the stated soil type.
    - When recommending fertilizers, **only suggest fertilizers for nutrients that are deficient or imbalanced** based on the analysis. For each nutrient (N, P, K), if it is within the acceptable range or not needed, do not recommend fertilizers for it and skip the fertilizer recommendation part.
    - **If nutrient levels are too high, recommend corrective actions, such as irrigation or monitoring for toxicity.** Be sure to reassure the farmer if the levels are still within an acceptable range.

    Here is the required format:

    {
      "AI_Analysis": {
        "date": "$latestDate",
        "headline": "text",
        "short_summary": "text",  // A brief summary of the analysis
        "today_focus": [
          "text",  // Task 1
          "text",  // Task 2
          "... more tasks if needed"
        ],
        "status": "text",  // e.g., good, bad, moderate, excellent
        "summary": {
          "findings": "text",  // In-depth analysis of current soil and crop conditions
          "predictions": "text",  // Predictions based on trends (e.g., moisture, nutrients, weather impact)
          "recommendations": "text"  // Concrete advice based on the analysis
        },
        "summary_of_findings": {
          "moisture_trends": {
            "$firstDate": ..., 
            "$secondDate": ..., 
            "$thirdDate": ..., 
            "trend": "... "
          },
          "nutrient_trends": {
            "N": { "$firstDate": ..., "$secondDate": ..., "$thirdDate": ..., "trend": "..." },
            "P": { "$firstDate": ..., "$secondDate": ..., "$thirdDate": ..., "trend": "..." },
            "K": { "$firstDate": ..., "$secondDate": ..., "$thirdDate": ..., "trend": "..." }
          }
        },
        "predictive_insights": {
          "moisture": "text",  // Predictive analysis of moisture levels
          "nutrients": "text"  // Predictive insights on nutrient levels (N, P, K)
        },
        "recommended_fertilizers": {
          "type_of_nutrient": "text": { 
            "type": "text", 
            "application_instructions": "text", 
            "where_to_buy": "text" 
          },
          "... more if needed"
        },
        "warnings": {
          "nutrient_imbalances": "text",  // Nutrient imbalances that need addressing
          "drought_risks": "text"  // Drought risk based on weather forecast
        },
        "final_actionable_recommendations": [
          "text",  // Concrete step to take today
          "... more if needed"
        ]
      }
    }

    Here is the data to analyze:
    $dataToAnalyze

    Additional context:
    Plot Name: $plotName
    Crop Planted: $cropType
    Soil Type: $soilType
    Crop growth stage: Vegetative

    Weather forecast context:
    $weatherForecast
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
    - The data for the NPK is in ppm, and the moisture is in percentage.

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

  String generateAISummaryPrompt(
      String rawFormattedData, String weatherForecast) {
    return '''
  You are a smart assistant for **SoilTrack**, an agriculture analysis platform. Your role is to summarize field data collected from crop plots. Respond in **valid JSON** using the structure below.

  ⚠️ IMPORTANT:
  - Only output **pure JSON**, no extra text.
  - Strictly follow the keys and structure.
  - Use **simple, clear sentences** that old farmers can understand.
  - List **as many warnings, recommendations, and suggestions as needed** (1–5+).
  - **Do not invent** warnings or suggestions if not shown by the input data.
  - **If no concerning weather is detected, leave weather_suggestions as an empty list** (`[]`).
  - Use the plot name like instead of crop name. Don't use the crop name in the headline please.
  - Make the **headline meaningful**: Focus on the most urgent or important trend detected (e.g., severe moisture loss, nutrient imbalance, weather risk). Avoid just listing plot names.

  🧠 TASKS:
  - Analyze moisture and NPK (nitrogen, phosphorus, potassium) trends for each plot.
  - Detect concerning trends (e.g., sudden moisture loss, nutrient spikes or drops).
  - Provide a short, one-line summary headline.
  - List **all** important warnings (if any).
  - List **all** practical, immediate recommendations.
  - Suggest actions **based only on actual weather data** provided.

  🌦️ WEATHER RULES:
  - Only generate `weather_suggestions` if the weather forecast provided indicates:
    - **Hot**: >32°C
    - **Cold**: <18°C
    - **Heavy Rain**: POP > 70%
    - **Dry**: No rain for 3+ days
  - For each weather suggestion:
    - Provide an object with a **"header"** and a **"suggestion"** field.
    - **Example:** 
      {
        "header": "Heavy Rain Alert",
        "suggestion": "Heavy rain forecasted. Strengthen soil bunds and delay fertilizer application."
      }

  📤 OUTPUT FORMAT:
  {
    "headline": "text",
    "summary": "text",
    "warnings": [ 
      "text", 
      "... more if needed" 
    ],
    "recommendations": [ 
      "text", 
      "... more if needed" 
    ],
    "weather_suggestions": [ 
      {
        "header": "text",
        "suggestion": "text"
      },
      "... more if needed"
    ]
  }

  Here is the data to analyze:
  $rawFormattedData

  Here is the weather forecast:
  $weatherForecast
  ''';
  }

  Future<Map<String, dynamic>> getAiAnalysis(
    String prompt, {
    double temperature = 0.7,
    int maxTokens = 1500,
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
                'You are an agricultural AI assistant specializing in soil health analysis, crop management, and sustainable farming practices. You provide recommendations based on soil data, environmental and weather conditions, and best agricultural practices.'
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

  Future<String> analyzeSoil(BuildContext context, XFile image) async {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    final imageFile = File(image.path);
    final imageBytes = await imageFile.readAsBytes();

    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

    final content = [
      Content.multi([
        TextPart('''
      This is a photo of a soil. Can you identify what type of soil it is? Only provide a useful and concise answer for the explanation.
      If it is not about soil, please say "I am not sure about that. I can only help you with soil and farming-related questions and return no in is_about_soil.
      If you can't also determine the soil type, return no in is_about_soil.
      Respond in JSON format like this:

      {
        "soil_type": "<soil type>",
        "explanation": "<brief explanation>"
        "is_about_soil": "<yes or no>"
      }
      '''),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    try {
      final response = await model.generateContent(content);
      final result = response.text ?? 'No response from Gemini.';
      return result;
    } catch (e) {
      NotifierHelper.logError('Error: $e');
      NotifierHelper.showErrorToast(context, 'Failed to analyze soil image.');
      return 'Error: $e';
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
