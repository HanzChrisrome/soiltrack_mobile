import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/service/weather_service.dart';

class WeatherState {
  final Map<String, dynamic>? weatherData;
  final List<dynamic>? forecastData;
  final List<Map<String, dynamic>>? suggestionData;
  final bool isLoading;
  final bool hasError;

  WeatherState({
    this.weatherData,
    this.forecastData,
    this.suggestionData,
    this.isLoading = false,
    this.hasError = false,
  });

  WeatherState copyWith({
    Map<String, dynamic>? weatherData,
    List<dynamic>? forecastData,
    final List<Map<String, dynamic>>? suggestionData,
    bool? isLoading,
    bool? hasError,
  }) {
    return WeatherState(
      weatherData: weatherData ?? this.weatherData,
      forecastData: forecastData ?? this.forecastData,
      suggestionData: suggestionData ?? this.suggestionData,
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

  Future<void> fetchWeather(String city) async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await weatherService.getWeatherByCity('Baliuag');
      final forecast = await weatherService.getHourlyForecastByCity('Baliuag');
      final suggestions = weatherService.generateSuggestions(data, forecast);

      state = state.copyWith(
        weatherData: data,
        forecastData: forecast["list"],
        suggestionData: suggestions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }
}

final weatherProvider =
    NotifierProvider<WeatherNotifier, WeatherState>(() => WeatherNotifier());
