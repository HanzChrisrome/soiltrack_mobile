import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/provider/weather_provider.dart';
import 'package:soiltrack_mobile/widgets/custom_accordion.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final authState = ref.watch(authProvider);

    if (weatherState.isLoading || weatherState.weatherData == null) {
      return DynamicContainer(
        backgroundColor: Colors.transparent,
        borderColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        child: Center(
          child: LoadingAnimationWidget.fourRotatingDots(
              color: Theme.of(context).colorScheme.onPrimary, size: 70),
        ),
      );
    }

    String _getWeatherImage(Map<String, dynamic> weatherData) {
      final int id = weatherData["weather"][0]["id"];
      final int currentTime = weatherData["dt"];
      final int sunrise = weatherData["sys"]["sunrise"];
      final int sunset = weatherData["sys"]["sunset"];
      final bool isDayTime = currentTime >= sunrise && currentTime < sunset;

      if (id >= 200 && id < 300) {
        // Thunderstorm
        final hasRain = id >= 201 && id <= 232;
        if (hasRain) {
          return isDayTime
              ? 'assets/weather/thunder/heavy_thunder_rain_day.png'
              : 'assets/weather/thunder/heavy_thunder_rain_night.png';
        } else {
          return isDayTime
              ? 'assets/weather/thunder/heavy_thunder_day.png'
              : 'assets/weather/thunder/heavy_thunder_night.png';
        }
      } else if (id >= 300 && id < 400) {
        // Drizzle (can reuse light rain icons)
        return isDayTime
            ? 'assets/weather/rain/light_rain_day.png'
            : 'assets/weather/rain/light_rain_night.png';
      } else if (id >= 500 && id < 600) {
        // Rain
        if (id >= 500 && id < 502) {
          return isDayTime
              ? 'assets/weather/rain/light_rain_day.png'
              : 'assets/weather/rain/light_rain_night.png';
        } else if (id == 502 || id == 503 || id == 504) {
          return isDayTime
              ? 'assets/weather/rain/heavy_rain_day.png'
              : 'assets/weather/rain/heavy_rain_night.png';
        } else {
          return isDayTime
              ? 'assets/weather/moderate_rain_day.png'
              : 'assets/weather/moderate_rain_night.png';
        }
      } else if (id >= 600 && id < 700) {
        // Snow (if you ever add snow icons later)
        return isDayTime
            ? 'assets/weather/clear/clear.png'
            : 'assets/weather/clear/normal_night.png';
      } else if (id >= 700 && id < 800) {
        // Atmosphere: mist, smoke, haze, etc.
        return isDayTime
            ? 'assets/weather/cloudy/cloudy_day.png'
            : 'assets/weather/cloudy/cloudy_night.png';
      } else if (id == 800) {
        // Clear
        return isDayTime
            ? 'assets/weather/clear/clear.png'
            : 'assets/weather/clear/normal_night.png';
      } else if (id > 800 && id < 805) {
        // Clouds
        switch (id) {
          case 801:
            return isDayTime
                ? 'assets/weather/cloudy/few_clouds_day.png'
                : 'assets/weather/cloudy/few_clouds_night.png';
          case 802:
            return isDayTime
                ? 'assets/weather/cloudy/cloudy_day.png'
                : 'assets/weather/cloudy/cloudy_night.png';
          case 803:
          case 804:
            return isDayTime
                ? 'assets/weather/cloudy/overcast_day.png'
                : 'assets/weather/cloudy/overcast_night.png';
        }
      }

      // Fallback
      return isDayTime
          ? 'assets/weather/clear/clear.png'
          : 'assets/weather/clear/normal_night.png';
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_getWeatherImage(weatherState.weatherData!)),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${authState.userProvince}, ${authState.userCity}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white)),
              Text(
                "${weatherState.weatherData!["main"]["temp"].toInt()}°",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 70,
                    letterSpacing: -2.5,
                    height: 1,
                    color: Colors.white),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${weatherState.weatherData!["weather"][0]["description"][0].toUpperCase()}${weatherState.weatherData!["weather"][0]["description"].substring(1)}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.water_drop_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${weatherState.weatherData!["main"]["humidity"]}%",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.air_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${weatherState.weatherData!["wind"]["speed"]} m/s",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        CustomAccordion(
          backgroundColor: Theme.of(context).colorScheme.surface,
          titleWidget: Row(
            children: [
              const TextGradient(text: 'Suggestions', fontSize: 20),
              const SizedBox(width: 10),
              TextRoundedEnclose(
                  text: 'Based on weather data',
                  color: Colors.white,
                  textColor: Colors.grey[500]!),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              if (weatherState.suggestionData != null &&
                  weatherState.suggestionData!.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weatherState.suggestionData!.length,
                  itemBuilder: (context, index) {
                    final suggestion = weatherState.suggestionData![index];

                    return SizedBox(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion["title"], // Use the dynamic title
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 0.8,
                                  color: const Color.fromARGB(255, 44, 44, 44),
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            suggestion["message"], // Use the dynamic message
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: const Color.fromARGB(255, 97, 97, 97),
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const DividerWidget(verticalHeight: 5),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// String _formatTime(int timestamp) {
//   final DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//   return DateFormat.jm().format(time);
// }
