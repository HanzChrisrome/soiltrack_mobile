import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupedNutrientBarChart extends StatelessWidget {
  final Map<String, Map<String, double>> groupedData;

  const GroupedNutrientBarChart({super.key, required this.groupedData});

  @override
  Widget build(BuildContext context) {
    final dates = groupedData.keys.toList();
    const nutrientColors = {
      'N': Colors.blue,
      'P': Colors.orange,
      'K': Colors.green,
    };

    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(dates.length, (index) {
            final date = dates[index];
            final nutrients = groupedData[date]!;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: nutrients['N'] ?? 0,
                  width: 10,
                  color: nutrientColors['N'],
                  borderRadius: BorderRadius.zero,
                ),
                BarChartRodData(
                  toY: nutrients['P'] ?? 0,
                  width: 10,
                  color: nutrientColors['P'],
                  borderRadius: BorderRadius.zero,
                ),
                BarChartRodData(
                  toY: nutrients['K'] ?? 0,
                  width: 10,
                  color: nutrientColors['K'],
                  borderRadius: BorderRadius.zero,
                ),
              ],
              barsSpace: 4,
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (double value, _) {
                  final index = value.toInt();
                  if (index < dates.length) {
                    final parsedDate = DateTime.tryParse(dates[index]);
                    if (parsedDate != null) {
                      final formattedDate =
                          DateFormat('MMM d').format(parsedDate); // "May 8"
                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10),
                        ),
                      );
                    }
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }
}
