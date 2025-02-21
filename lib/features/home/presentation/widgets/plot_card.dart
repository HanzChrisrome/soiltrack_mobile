import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class PlotCard extends ConsumerWidget {
  const PlotCard({
    super.key,
    required this.soilMoistureSensorId,
    required this.sensorName,
    required this.sensorStatus,
    required this.assignedCrop,
    required this.moistureReadings,
  });

  final int soilMoistureSensorId;
  final String sensorName;
  final String sensorStatus;
  final String assignedCrop;
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextRoundedEnclose(
              text: 'Moisute level is based on the received data.',
              color: Colors.white,
              textColor: Colors.grey[500]!),
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
                        showTitles: false,
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
        ],
      ),
    );
  }
}
