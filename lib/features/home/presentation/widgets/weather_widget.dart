import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/provider/weather_provider.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/weather/normal_night.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Baliuag, Bulacan',
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
      ],
    );
  }
}

// String _formatTime(int timestamp) {
//   final DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//   return DateFormat.jm().format(time);
// }
