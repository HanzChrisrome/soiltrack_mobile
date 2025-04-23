// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? "";
  final String baseUrl = "https://api.openweathermap.org/data/2.5";
  final String geoUrl = "http://api.openweathermap.org/geo/1.0";

  // Helper: Get Coordinates
  Future<Map<String, double>> _getCoordinates(String city,
      {String? province, String countryCode = 'PH'}) async {
    final location = province != null
        ? "$city,$province,$countryCode"
        : "$city,$countryCode";
    final url = "$geoUrl/direct?q=$location&limit=1&appid=$apiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return {
          "lat": data[0]['lat'],
          "lon": data[0]['lon'],
        };
      } else {
        throw Exception("Location not found");
      }
    } else {
      print('Error fetching coordinates');
      throw Exception("Failed to load location data");
    }
  }

  Future<Map<String, dynamic>> getWeatherByCity(String city,
      {String? province, String countryCode = 'PH'}) async {
    final coords = await _getCoordinates(city,
        province: province, countryCode: countryCode);
    final url =
        "$baseUrl/weather?lat=${coords['lat']}&lon=${coords['lon']}&appid=$apiKey&units=metric";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error fetching weather data');
      throw Exception("Failed to load weather data");
    }
  }

  Future<Map<String, dynamic>> getHourlyForecastByCity(String city,
      {String? province, String countryCode = 'PH'}) async {
    final coords = await _getCoordinates(city,
        province: province, countryCode: countryCode);
    final url =
        "$baseUrl/forecast?lat=${coords['lat']}&lon=${coords['lon']}&appid=$apiKey&units=metric";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error fetching forecast data');
      throw Exception("Failed to load forecast data");
    }
  }

  // Your existing generateSuggestions method remains the same
  List<Map<String, dynamic>> generateSuggestions(
      Map<String, dynamic> weatherData, Map<String, dynamic> forecastData) {
    final double temp = (weatherData["main"]["temp"] as num).toDouble();
    final int humidity = weatherData["main"]["humidity"] as int;
    final double windSpeed = (weatherData["wind"]["speed"] as num).toDouble();
    final bool isFrost = temp < 5;

    List<dynamic> hourlyForecast = forecastData["list"];

    String peakHeatTime = "";
    double maxTemp = temp;
    for (var forecast in hourlyForecast) {
      final double temp = (forecast["main"]["temp"] as num).toDouble();
      if (temp > maxTemp) {
        maxTemp = temp;
        peakHeatTime = forecast["dt_txt"];
      }
    }

    String peakHeatFormatted = peakHeatTime.isNotEmpty
        ? DateTime.parse(peakHeatTime).hour.toString()
        : "Not Available";

    bool incomingRain = false;
    String rainTime = "";
    DateTime now = DateTime.now();

    for (var hour in hourlyForecast.take(6)) {
      DateTime forecastTime = DateTime.parse(hour["dt_txt"]);

      if (forecastTime.isAfter(now) && hour["weather"][0]["main"] == "Rain") {
        incomingRain = true;
        rainTime = DateFormat.jm().format(forecastTime);
        break;
      }
    }

    List<Map<String, dynamic>> suggestions = [];

    if (incomingRain) {
      suggestions.add({
        "title": "Incoming Rain",
        "message": "Expected at $rainTime by OpenWeatherMap."
      });
      suggestions.add({
        "title": "Rainwater Collection",
        "message": "Place containers to collect rainwater for later use."
      });
    }

    if (temp > 32) {
      suggestions.add({
        "title": "Extreme Heat Alert",
        "message":
            "Peak temperature expected around $peakHeatFormatted. Water crops early morning (5-7 AM) to prevent evaporation."
      });
      suggestions.add({
        "title": "Drought Alert",
        "message":
            "Consider increasing irrigation frequency to prevent soil dryness."
      });
    }

    if (humidity > 80) {
      suggestions.add({
        "title": "High Humidity Alert",
        "message":
            "Irrigation may not be necessary. Check soil moisture levels before watering."
      });
    }

    if (isFrost) {
      suggestions.add({
        "title": "Frost Alert",
        "message":
            "Protect sensitive plants by covering them with a cloth or plastic sheet."
      });
    }

    if (windSpeed > 12) {
      suggestions.add({
        "title": "Strong Winds Detected",
        "message":
            "Avoid spraying pesticides or fertilizers now to prevent drift."
      });
      suggestions.add({
        "title": "Storm Alert",
        "message":
            "Secure loose plants and protect sensitive crops from damage."
      });
    }

    if (suggestions.isEmpty) {
      suggestions.add({
        "title": "Optimal Weather",
        "message": "Best time to irrigate: Early morning or late afternoon."
      });
    }

    return suggestions;
  }
}
