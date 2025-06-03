import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';

class AiService {
  String generateAIAnalysisPrompt(
    String dataToAnalyze,
    String cropType,
    String soilType,
    String plotName,
    String weatherForecast, {
    String language = 'en',
  }) {
    final dateRegex = RegExp(r'\d{4}-\d{2}-\d{2}');
    final allMatches =
        dateRegex.allMatches(dataToAnalyze).map((m) => m.group(0)!);
    final uniqueDates = allMatches.toSet().toList()..sort();

    final firstDate = uniqueDates.isNotEmpty ? uniqueDates[0] : "2025-04-04";
    final secondDate = uniqueDates.length > 1 ? uniqueDates[1] : "2025-04-05";
    final thirdDate = uniqueDates.length > 2 ? uniqueDates[2] : "2025-04-06";
    final latestDate = uniqueDates.isNotEmpty ? uniqueDates.last : "2025-04-06";

    final langInstruction = language == 'tl'
        ? "Translate all your output into Filipino (Tagalog) please. Make it farmer-friendly, and conversational but still accurate."
        : "";

    final bool cropProvided = cropType.trim().isNotEmpty;
    final additionalContext = cropProvided
        ? '''
    Here is the data to analyze:
    $dataToAnalyze

    Additional context:
    Plot Name: $plotName
    Crop Planted: $cropType
    Soil Type: $soilType
    '''
        : '''
    NOTE: There is *no crop assigned* for this plot.

    Your goal is to:
    - Analyze the soil and environmental data.
    - Identify which crops would be *most suitable* for this plot based on:
      - Soil type
      - Moisture levels
      - Nutrient levels (N, P, K)
      - Weather Forecast

    DO NOT generate an action plan for a specific crop. Instead, give general land preparation and soil conditioning advice that can help prepare the land for the suggested crops.

    Be farmer-friendly, practical, and confident in your tone.

    Here is the data to analyze:
    $dataToAnalyze

    Additional context:
    Plot Name: $plotName
    Soil Type: $soilType
    ''';

    final cropInstruction = cropProvided
        ? "Your goal is to generate a clear, farmer-friendly daily action plan based on the latest data."
        : "There is no crop currently planted. Analyze the soil and recommend crops suitable for the current conditions. Also suggest general land preparation strategies.";

    final taskInstruction = cropProvided
        ? "Focus on **immediate daily tasks** (what should the farmer do **today**)."
        : "DO NOT give crop-specific actions. Focus instead on land preparation and possible crops to plant.";

    return '''
    You are a helpful farm assistant working for a tool called **SoilTrack**. Each day, you help farmers understand what their soil and crop data means and what they need to do **today**.

    $langInstruction

    $cropInstruction

    ⚠️ VERY IMPORTANT:
    - $taskInstruction
    - Provide a **detailed analysis** of findings, predictions, and recommendations.
    - DO NOT recommend external tests, expert advice, or tools.
    - Use "text" for string values and numbers (e.g., 42.5, 7) for numeric ones.
    - Use dates from the data provided (latest date is "$latestDate").
    - All values must be in valid JSON format. Do not leave out any fields. DO NOT include any text outside the JSON.
    - Provide at least 2 sentences of context or analysis for each section (findings, predictions, recommendations).
    - Make the detailed analysis easy to understand for farmers, so avoid using complex terms or jargon.
    - In today's focus, there can be multiple points or text.
    - Provide short-term insights (no weekly patterns).
    - The data for the NPK is in ppm, and the moisture is in percentage.
    - In the headline section, summarize the most important findings in a few words.
    - In the status, provide only if it is **good**, **bad**, **moderate**, or **excellent**.
    - If the drop in moisture or any nutrients, does not exceed 5% or 10ppm, reassure the farmer and compliment the farmer that it is still within the acceptable range and does not need to be worried about it.
    - Before saying an acceptable range for the crop planted, please check first the general recommendations or guideline for the NPK nutrient concentrations for the crop planted in the stated soil type, if there is a crop assigned.
    - If there is a crop assigned, When recommending fertilizers, **only suggest fertilizers for nutrients that are deficient or imbalanced** based on the analysis. For each nutrient (N, P, K), if it is within the acceptable range or not needed, do not recommend fertilizers for it and skip the fertilizer recommendation part.
    - If there is a crop assigned. **If nutrient levels are too high or too low and not within the accepted range, recommend corrective actions, such as irrigation or monitoring for toxicity.** Be sure to reassure the farmer if the levels are still within an acceptable range.

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
            "condition": "text" // Very low, low, Moderately low, Moderately high, High, Very High
          },
          "nutrient_trends": {
            "N": { "$firstDate": ..., "$secondDate": ..., "$thirdDate": ..., "trend": "...", "condition": "text" // Very low, low, Moderately low, Moderately high, High, Very High },
            "P": { "$firstDate": ..., "$secondDate": ..., "$thirdDate": ..., "trend": "...", "condition": "text" // Very low, low, Moderately low, Moderately high, High, Very High },
            "K": { "$firstDate": ..., "$secondDate": ..., "$thirdDate": ..., "trend": "...", "condition": "text" // Very low, low, Moderately low, Moderately high, High, Very High }
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

    $additionalContext

    Weather forecast context:
    $weatherForecast
    ''';
  }

  String generateWeeklyAIAnalysisPrompt(
    String dataToAnalyze,
    String cropType,
    String soilType,
    String plotName,
    String weatherForecast, {
    String language = 'en',
  }) {
    final dateRegex = RegExp(r'\d{4}-\d{2}-\d{2}');
    final allMatches =
        dateRegex.allMatches(dataToAnalyze).map((m) => m.group(0)!);
    final uniqueDates = allMatches.toSet().toList()..sort();

    final recentDates = uniqueDates.length > 7
        ? uniqueDates.sublist(uniqueDates.length - 7)
        : uniqueDates;

    final formattedDateList = recentDates.map((d) => '"$d": ...').join(", ");

    final langInstruction = language == 'tl'
        ? "Translate all your output into Filipino (Tagalog) please. Make it farmer-friendly, and conversational but still accurate."
        : "";

    final isCropEmpty = cropType.trim().isEmpty;

    final recommendedCropsNote = isCropEmpty
        ? ''
        : '''
    - Add a section `"recommended_crops"` with a list of 2–3 crops suitable for current conditions. Each item must contain a `"crop"` and `"reason"`.

    Example:
    "recommended_crops": [
      {
        "crop": "Sweet Potato",
        "reason": "Thrives in sandy loam soil and tolerates moderate potassium levels."
      },
      ...
    ]
    ''';

    final cropInstruction = isCropEmpty
        ? '''
    ⚠️ NOTE:
    - There is currently **no crop planted** in this plot. Your analysis should focus on:
      - Soil health and preparation
      - Moisture trends and irrigation readiness
      - Nutrient balance and future planting suitability
    - Do NOT reference ideal NPK values for crops.
    - Do NOT recommend any fertilizers unless there is a **major imbalance or excess**.
    - DO NOT assume any crop-related stages or needs.
    - Adjust your tone to **anticipate planting** rather than manage an existing crop.
    '''
        : '''
    - Before determining acceptable ranges for nutrients (NPK), refer to general guidelines for **$cropType** on **$soilType**.
    - Focus on helping the farmer maintain balance and take early action based on the actual crop needs.
    ''';

    final displayCropType = isCropEmpty ? "None (Pre-planting)" : cropType;

    return '''
    You are an agricultural analysis assistant for a system called **SoilTrack**. Your task is to analyze the provided weekly soil and crop data and respond strictly in the **exact JSON format** defined below.

    $langInstruction

    Generate a strategic, farmer-friendly **weekly analysis** and **plan of action** in the **exact JSON format** below — no extra explanations or text outside the JSON.

    $cropInstruction

    ⚠️ **CRITICAL GUIDELINES**:
    - Focus only on **weekly actionable tasks** (what should the farmer do over the next 7 days).
    - Do **not** recommend tools, experts, or lab testing.
    - DO NOT mention this prompt or refer to "you are an assistant".
    - Use clear, plain language. Avoid technical jargon unless it's explained simply.
    - Use `"text"` for string fields and real numbers for metrics.
    - DO NOT recommend fertilizers if nutrient levels are already in the acceptable range.
    - Compliment the farmer if values are stable or improving, especially if the variation is minor (e.g., <5% moisture or <10ppm NPK).
    - Provide reassurance if any changes are still within safe thresholds.
    $recommendedCropsNote

    📊 **TREND ANALYSIS**:
    - Label each `"trend"` as: `"increasing"`, `"decreasing"`, `"fluctuating"`, or `"stable"`.
    - Write a short `"description"` that captures how values moved over the week.

    📅 **DATE RANGE FORMAT**:
    - Use the earliest and latest dates from the data.
    - Format: `"April 6 – April 13, 2025"` (use actual extracted dates).
    
    🗓️ **WEEKLY STRUCTURE**:
    Structure tasks to span across the week. Use scheduling when helpful, e.g., `"Apply compost midweek if rain is expected"`.

    {
      "AI_Analysis": {
        "date_range": "text",
        "headline": "text",
        "short_summary": "text",  // A brief summary of the weekly analysis
        "weekly_focus": [
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
            $formattedDateList,
            "trend": "text"
            "condition": "text" // Very low, low, Moderately low, Moderately high, High, Very High
          },
          "nutrient_trends": {
            "N": {
              $formattedDateList,
              "trend": "text"
              "condition": "text" // Very low, low, Moderately low, Moderately high, High, Very High
            },
            "P": {
              $formattedDateList,
              "trend": "text"
              "condition": "text" // Very low, low, Moderately low, Moderately high, High, Very High
            },
            "K": {
              $formattedDateList,
              "trend": "text"
              "condition": "text" // Very low, low, Moderately low, Moderately high, High, Very High
            }
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
    Crop Type: $displayCropType
    Soil Type: $soilType

    Weather forecast context:
    $weatherForecast
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
  - Always **numerically compare** old and new values for moisture and nutrients:
    - If the new value is **higher** than the old value, describe it as an **increase**.
    - If the new value is **lower** than the old value, describe it as a **decrease**.
    - Only consider moisture drops significant if they **exceed 5%** decrease.
    - Only consider nutrient (NPK) drops significant if they **exceed 10 ppm** decrease.
    - If an increase or decrease is **within acceptable limits**, reassure the farmer that it's still within the safe range and compliment them.
    - If nutrients rise but stay within acceptable safe ranges, compliment the farmer.
  - **Only analyze and report on the latest data**:
    - Ignore all data from previous dates when generating warnings, recommendations, headlines, and summaries.
    - Use previous data **only as historical reference** to understand trends for the latest data.
    - Do not mention past dates (e.g., April 26–27) in any warning, summary, or recommendation.
    - Focus purely on today's/latest data conditions and today's measurements.
  - Use the **plot name** when mentioning problems or praises — **never** use the crop name in the headline or summary.
  - Make the **headline meaningful**: Focus on the **most urgent or important trend detected** (e.g., severe moisture loss, nutrient imbalance, or weather risk). **Avoid just listing plot names**.

  🧠 TASKS:
  - Analyze moisture and NPK (nitrogen, phosphorus, potassium) trends for each plot.
  - Detect concerning trends (e.g., sudden moisture loss, nutrient spikes or drops).
  - Provide a short, one-line summary headline.
  - List **all** important warnings (if any).
  - List **all** practical, immediate recommendations.
  - Suggest actions **based only on today's actual weather forecast** provided.
  - Focus on giving advice for **today** only — previous dates are for reference only.

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
    String language = 'en',
  }) async {
    if (language == 'tl') {
      return await getGeminiAnalysis(prompt);
    }

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

  Future<Map<String, dynamic>> getGeminiAnalysis(String prompt) async {
    final String? geminiApiKey = dotenv.env['GEMINI_API_KEY'];
    if (geminiApiKey == null) {
      throw Exception('Gemini API key not found in environment variables.');
    }

    final response = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$geminiApiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 1500,
        }
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final text = json['candidates'][0]['content']['parts'][0]['text'];
      return {
        "choices": [
          {
            "message": {"content": text}
          }
        ]
      };
    } else {
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      throw Exception('Failed to fetch Gemini AI analysis');
    }
  }
}
