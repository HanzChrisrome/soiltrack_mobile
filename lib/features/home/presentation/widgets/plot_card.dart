import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class PlotCard extends ConsumerWidget {
  const PlotCard({
    super.key,
    required this.soilMoistureSensorId,
    required this.sensorName,
    required this.sensorStatus,
    required this.assignedCrop,
    this.nutrientSensors,
    required this.moistureReadings,
  });

  final int soilMoistureSensorId;
  final String sensorName;
  final String sensorStatus;
  final String assignedCrop;
  final List<dynamic>? nutrientSensors;
  final List<dynamic> moistureReadings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moistureSpots = moistureReadings.map((reading) {
      final timeStamp = DateTime.parse(reading['read_time']);

      final firstTimestamp =
          DateTime.parse(moistureReadings.first['read_time']);
      final minutesDifference = timeStamp.difference(firstTimestamp).inMinutes;

      final moistureValue = reading['soil_moisture'];

      return FlSpot(minutesDifference.toDouble(), moistureValue.toDouble());
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextGradient(text: sensorName, fontSize: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  assignedCrop,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 126, 126, 126),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            thickness: 1,
            color: Color.fromARGB(255, 236, 236, 236),
            height: 20,
          ),
          Text(
            'Moisture Level based on the received data',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 250, // Increased height to make space for labels
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 20 == 0) {
                            return Text(
                              value.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 35,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  minX: moistureSpots.isNotEmpty ? moistureSpots.first.x : 0.0,
                  maxX: moistureSpots.isNotEmpty ? moistureSpots.last.x : 1.0,

                  // Calculate minY and maxY with a small buffer
                  minY: moistureSpots.isNotEmpty
                      ? moistureSpots
                              .map((spot) => spot.y)
                              .reduce((a, b) => a < b ? a : b) -
                          10 // Buffer added to minY
                      : 0.0,
                  maxY: moistureSpots.isNotEmpty
                      ? moistureSpots
                              .map((spot) => spot.y)
                              .reduce((a, b) => a > b ? a : b) +
                          0 // Buffer added to maxY
                      : 100.0,

                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: moistureSpots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.onPrimary,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true,
                          color: const Color.fromARGB(255, 12, 117, 9)
                              .withOpacity(0.3)),
                      dashArray: [5, 5],
                      isStrokeCapRound: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text(
                  'View more details about this plot.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 126, 126, 126),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (nutrientSensors == null || nutrientSensors!.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                'No soil nutrients sensor assigned',
                style: TextStyle(
                  color: Color.fromARGB(255, 146, 20, 20),
                  fontSize: 14.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
