import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';
import 'package:intl/intl.dart' as intl;

class PlotChart extends ConsumerWidget {
  const PlotChart({
    super.key,
    required this.selectedPlotId,
    required this.readings,
    required this.readingType,
  });

  final int selectedPlotId;
  final List<dynamic> readings;
  final String readingType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter readings for the selected plot
    final filteredReadings = readings
        .where((reading) => reading['plot_id'] == selectedPlotId)
        .toList();

    if (filteredReadings.isEmpty || filteredReadings.length < 5) {
      return _buildNoDataContainer(context);
    }

    final spots = List.generate(filteredReadings.length, (index) {
      final value = filteredReadings[index]['value'] ?? 0.0; // Fixed key access
      return FlSpot(index.toDouble(), value.toDouble());
    });

    // Determine min and max Y values for the chart
    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      minY -= 1; // Ensure visible range if all values are the same
      maxY += 1;
    } else {
      double padding = (maxY - minY) * 0.1;
      minY -= padding;
      maxY += padding;
    }

    return _buildChartContainer(
      context,
      filteredReadings,
      spots,
      minY,
      maxY,
    );
  }

  /// Container for when there is no data available
  Widget _buildNoDataContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey[100]!, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Text(
            'No ${formatReadingType(readingType)} readings available for this plot.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the chart container dynamically
  Widget _buildChartContainer(
    BuildContext context,
    List<dynamic> reversedReadings,
    List<FlSpot> spots,
    double minY,
    double maxY,
  ) {
    minY = 0;
    maxY = 200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: _getChartColor(readingType).withOpacity(0.2),
        border: Border.all(
            color: _getChartColor(readingType).withOpacity(0.2), width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextRoundedEnclose(
            text:
                '${formatReadingType(readingType)} level is based on the received data.',
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
                        if (index < 0 || index >= reversedReadings.length) {
                          return const Text('');
                        }
                        final timeStamp = DateTime.parse(
                          reversedReadings[index]['read_time'],
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            intl.DateFormat.Hm().format(timeStamp),
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
                maxX: spots.length.toDouble() - 1,
                minY: minY, // Fixed 0
                maxY: maxY, // Fixed 200
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    preventCurveOverShooting: true,
                    show: true,
                    color: _getChartColor(readingType),
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: _getChartColor(readingType).withOpacity(0.2),
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

  /// Returns color based on reading type
  Color _getChartColor(String type) {
    switch (type) {
      case 'readed_nitrogen':
        return Colors.green;
      case 'readed_phosphorus':
        return Colors.orange;
      case 'readed_potassium':
        return const Color.fromARGB(255, 175, 23, 202);
      case 'soil_moisture':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  /// Formats reading type names properly
  String formatReadingType(String type) {
    switch (type.toLowerCase()) {
      case 'readed_nitrogen':
        return 'Nitrogen';
      case 'readed_phosphorus':
        return 'Phosphorus';
      case 'readed_potassium':
        return 'Potassium';
      case 'soil_moisture':
        return 'Moisture';
      default:
        return type;
    }
  }
}
