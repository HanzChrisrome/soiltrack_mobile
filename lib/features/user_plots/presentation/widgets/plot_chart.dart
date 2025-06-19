import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
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
    final selectedTimeRangeGeneral =
        ref.watch(soilDashboardProvider).selectedTimeRangeFilterGeneral;
    final selectedRange =
        ref.watch(soilDashboardProvider).selectedTimeRangeFilter;

    final filteredReadings = readings.where((reading) {
      final plotMatches = reading['plot_id'] == selectedPlotId;

      if (selectedRange == '1D' && selectedTimeRangeGeneral == '1D') {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay =
            DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        final readTime = DateTime.parse(reading['read_time']);

        return plotMatches &&
            !readTime.isBefore(startOfDay) &&
            !readTime.isAfter(endOfDay);
      }

      return plotMatches;
    }).toList();

    if (filteredReadings.isEmpty) {
      return _buildNoDataContainer(context);
    }

    filteredReadings.sort((a, b) => DateTime.parse(b['read_time'])
        .compareTo(DateTime.parse(a['read_time'])));

    final latestReadings = filteredReadings.take(18).toList();

    latestReadings.sort((a, b) => DateTime.parse(a['read_time'])
        .compareTo(DateTime.parse(b['read_time'])));

    final spots = latestReadings.map((reading) {
      final time = DateTime.parse(reading['read_time'])
          .millisecondsSinceEpoch
          .toDouble();
      final value = (reading['value'] ?? 0).toDouble();
      return FlSpot(time, value);
    }).toList();

    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    } else {
      double padding = (maxY - minY) * 0.1;
      minY -= padding;
      maxY += padding;
    }

    return _buildChartContainer(
      context,
      latestReadings,
      spots,
      minY,
      maxY,
      selectedRange,
      selectedTimeRangeGeneral,
    );
  }

  /// Builds the chart container dynamically
  Widget _buildChartContainer(
    BuildContext context,
    List<dynamic> reversedReadings,
    List<FlSpot> spots,
    double minY,
    double maxY,
    String selectedRange,
    String selectedTimeRangeGeneral,
  ) {
    minY = 0;
    maxY = 200;
    double? firstReading;
    double? latestReading;

    if (spots.isNotEmpty) {
      firstReading = spots.first.y;
      latestReading = spots.last.y;
    }

    double? percentageChange;
    if (firstReading != null && latestReading != null && firstReading != 0) {
      percentageChange = ((latestReading - firstReading) / firstReading) * 100;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextGradient(text: formatReadingType(readingType), fontSize: 20),
            const SizedBox(width: 15),
            if (percentageChange != null)
              TextRoundedEnclose(
                text:
                    '${percentageChange > 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}% ${_getRangeLabel(selectedTimeRangeGeneral)}',
                color: percentageChange > 0
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                textColor: percentageChange > 0 ? Colors.green : Colors.red,
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.grey[200]!, width: 1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
                          interval: selectedRange == '1D'
                              ? 2 * 60 * 60 * 1000
                              : selectedRange == '1W'
                                  ? 24 * 60 * 60 * 1000
                                  : null,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            DateTime actualTime =
                                DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt(),
                                        isUtc: true)
                                    .toLocal();

                            String formattedDate;
                            if (selectedRange == '1D') {
                              formattedDate =
                                  intl.DateFormat('HH:mm').format(actualTime);
                            } else if (selectedRange == '1W') {
                              formattedDate =
                                  intl.DateFormat('MMM d').format(actualTime);
                            } else if (selectedRange == '1M') {
                              formattedDate =
                                  intl.DateFormat('MMM d').format(actualTime);
                            } else if (selectedRange == '3M') {
                              formattedDate =
                                  intl.DateFormat('MMM').format(actualTime);
                            } else {
                              formattedDate =
                                  intl.DateFormat('MMM d').format(actualTime);
                            }

                            bool isActualDataPoint =
                                spots.any((spot) => spot.x == value);

                            Set<String> displayedLabels = {};
                            if (selectedRange == '1D') {
                              return Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  formattedDate,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 8),
                                ),
                              );
                            } else {
                              if (isActualDataPoint &&
                                  !displayedLabels.contains(formattedDate)) {
                                displayedLabels.add(formattedDate);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 8),
                                  ),
                                );
                              }
                            }

                            return const SizedBox.shrink();
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
                    minX: spots.first.x,
                    maxX: spots.last.x,
                    minY: minY,
                    maxY: maxY,
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
        ),
      ],
    );
  }

  Widget _buildNoDataContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey[100]!, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        'No ${formatReadingType(readingType)} readings available for this plot.',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 12.0,
        ),
      ),
    );
  }

  /// Returns color based on reading type
  Color _getChartColor(String type) {
    switch (type) {
      case 'readed_nitrogen':
        return Colors.yellow;
      case 'readed_phosphorus':
        return Colors.pink;
      case 'readed_potassium':
        return Colors.purple;
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

  String _getRangeLabel(String range) {
    switch (range) {
      case '1D':
        return 'Today';
      case '1W':
        return 'This Week';
      case '1M':
        return 'This Month';
      case '3M':
        return 'Last 3 Months';
      default:
        return 'Selected Period';
    }
  }
}
