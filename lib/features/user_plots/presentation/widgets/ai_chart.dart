import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';
import 'package:intl/intl.dart' as intl;

class AiChart extends ConsumerWidget {
  const AiChart({
    super.key,
    required this.data,
    required this.label,
  });

  final Map<String, dynamic> data;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, double> readings = {
      for (var entry in data.entries)
        if (entry.key != 'trend') entry.key: (entry.value as num).toDouble()
    };

    final sortedKeys = readings.keys.toList()
      ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    final List<FlSpot> spots = [];
    for (final dateStr in sortedKeys) {
      final date = DateTime.parse(dateStr);
      final timestamp = date.millisecondsSinceEpoch.toDouble();
      spots.add(FlSpot(timestamp, readings[dateStr]!));
    }

    NotifierHelper.logMessage('Spots: $spots');

    String trend = 'stable';
    Color color = Colors.grey;

    if (readings.length >= 2) {
      final firstValue = readings[sortedKeys.first]!;
      final lastValue = readings[sortedKeys.last]!;

      if (lastValue > firstValue) {
        trend = 'Increasing';
        color = Colors.green;
      } else if (lastValue < firstValue) {
        trend = 'Decreasing';
        color = Colors.red;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.grey[200]!, width: 1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minX: spots.first.x,
                maxX: spots.last.x,
                minY: 0,
                maxY: 200,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    preventCurveOverShooting: true,
                    color: color,
                    isStrokeCapRound: true,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (readings.length >= 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Compared: ',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontSize: 12,
                          ),
                    ),
                    TextSpan(
                      text: intl.DateFormat('MMM d')
                          .format(DateTime.parse(sortedKeys.first)),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const TextSpan(text: ' → '),
                    TextSpan(
                      text: intl.DateFormat('MMM d')
                          .format(DateTime.parse(sortedKeys.last)),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextRoundedEnclose(
                text: trend,
                color: color.withOpacity(0.2),
                textColor: color,
              ),
            ],
          ),
      ],
    );
  }
}
