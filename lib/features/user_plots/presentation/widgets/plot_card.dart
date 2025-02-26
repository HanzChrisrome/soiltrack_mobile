import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';
import 'package:intl/intl.dart' as intl;

class PlotCard extends ConsumerWidget {
  const PlotCard({
    super.key,
    required this.selectedPlotId,
    required this.moistureReadings,
  });

  final int selectedPlotId;
  final List<dynamic> moistureReadings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredReadings = moistureReadings
        .where((reading) => reading['plot_id'] == selectedPlotId)
        .toList();

    if (filteredReadings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Colors.grey[100]!, width: 1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            Text(
              'No readings available for this plot.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      );
    }

    final moistureSpots = List.generate(filteredReadings.length, (index) {
      final moistureValue = filteredReadings[index]['soil_moisture'];
      return FlSpot(index.toDouble(), moistureValue.toDouble());
    });

    double minY =
        moistureSpots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY =
        moistureSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    double padding = (maxY - minY) * 0.1;
    minY -= padding;
    maxY += padding;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        border: Border.all(color: Colors.grey[100]!, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextRoundedEnclose(
            text: 'Moisture level is based on the received data.',
            color: Colors.white,
            textColor: Colors.grey[500]!,
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= filteredReadings.length) {
                          return const Text('');
                        }
                        // Get the timestamp for this index
                        final timeStamp = DateTime.parse(
                            filteredReadings[index]['read_time']);

                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            intl.DateFormat.Hm()
                                .format(timeStamp), // Format as HH:mm
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                minX: 0,
                maxX: moistureSpots.length.toDouble() - 1,
                minY: 0,
                maxY: 100,
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: moistureSpots,
                    preventCurveOverShooting: true,
                    show: true,
                    color: Colors.blue,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                    isStrokeCapRound: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
