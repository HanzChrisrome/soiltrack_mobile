import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/core/service/weather_service.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';

class WeatherState {
  final Map<String, dynamic>? weatherData;
  final List<dynamic>? forecastData;
  final List<Map<String, dynamic>>? suggestionData;
  final String? weatherReport;
  final bool isLoading;
  final bool hasError;

  WeatherState({
    this.weatherData,
    this.forecastData,
    this.suggestionData,
    this.weatherReport,
    this.isLoading = false,
    this.hasError = false,
  });

  WeatherState copyWith({
    Map<String, dynamic>? weatherData,
    List<dynamic>? forecastData,
    final List<Map<String, dynamic>>? suggestionData,
    String? weatherReport,
    bool? isLoading,
    bool? hasError,
  }) {
    return WeatherState(
      weatherData: weatherData ?? this.weatherData,
      forecastData: forecastData ?? this.forecastData,
      suggestionData: suggestionData ?? this.suggestionData,
      weatherReport: weatherReport ?? this.weatherReport,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

class WeatherNotifier extends Notifier<WeatherState> {
  final WeatherService weatherService = WeatherService();

  @override
  WeatherState build() {
    return WeatherState();
  }

  Future<void> fetchWeather() async {
    state = state.copyWith(isLoading: true);
    try {
      final authState = ref.read(authProvider);

      final city = authState.userCity ?? 'Baliuag';
      final province = authState.userProvince ?? 'Bulacan';

      final data = await weatherService.getWeatherByCity(province,
          province: city, countryCode: 'PH');
      final forecast = await weatherService.getHourlyForecastByCity(province,
          province: city, countryCode: 'PH');
      final suggestions = weatherService.generateSuggestions(data, forecast);

      String weatherReport = generateWeatherSummary(forecast);

      state = state.copyWith(
        weatherData: data,
        forecastData: forecast["list"],
        suggestionData: suggestions,
        weatherReport: weatherReport,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  String generateWeatherSummary(Map<String, dynamic> forecast) {
    Map<String, Map<String, dynamic>> dailySummary = {};

    final now = DateTime.now();
    String todayDate = DateFormat('yyyy-MM-dd').format(now);
    List<String> rainTimesToday = [];

    final dateFormatter = DateFormat('EEE, MMM d');
    final timeFormatter = DateFormat('HH:mm');

    for (var entry in forecast["list"]) {
      try {
        String dateTimeStr = entry['dt_txt'];
        DateTime dateTime = DateTime.parse(dateTimeStr);
        String date = dateTimeStr.split(' ')[0];

        double temp = (entry['main']['temp'] as num).toDouble();
        double feelsLike = (entry['main']['feels_like'] as num).toDouble();
        String description = entry['weather'][0]['main'];
        double pop = ((entry['pop'] ?? 0) as num).toDouble() * 100;

        if (date == todayDate && pop > 20) {
          rainTimesToday.add(timeFormatter.format(dateTime));
        }

        if (!dailySummary.containsKey(date)) {
          dailySummary[date] = {
            'maxTemp': temp,
            'maxFeelsLike': feelsLike,
            'description': description,
            'pop': pop,
          };
        } else {
          if (temp > dailySummary[date]!['maxTemp']) {
            dailySummary[date]!['maxTemp'] = temp;
            dailySummary[date]!['maxFeelsLike'] = feelsLike;
            dailySummary[date]!['description'] = description;
          }
          if (pop > dailySummary[date]!['pop']) {
            dailySummary[date]!['pop'] = pop;
          }
        }
      } catch (e) {
        NotifierHelper.logError(e, null, "Error parsing forecast data: $e");
      }
    }

    List<String> summaries = [];

    dailySummary.forEach((date, data) {
      DateTime parsedDate = DateTime.parse(date);
      String prettyDate = dateFormatter.format(parsedDate);

      String rainChance =
          data['pop'] > 20 ? "(${data['pop'].toStringAsFixed(0)}% rain)" : "";

      String summary =
          "$prettyDate: High of ${data['maxTemp'].toStringAsFixed(1)}°C (feels like ${data['maxFeelsLike'].toStringAsFixed(1)}°C), ${data['description'].toLowerCase()} $rainChance";

      if (date == todayDate && rainTimesToday.isNotEmpty) {
        summary += "\n    Expected rain around: ${rainTimesToday.join(', ')}";
      }

      summaries.add(summary);
    });

    return summaries.join("\n");
  }
}

final weatherProvider =
    NotifierProvider<WeatherNotifier, WeatherState>(() => WeatherNotifier());
