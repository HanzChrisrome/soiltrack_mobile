import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
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

  // Step 1: Define your custom color mapping function
  Color _getColorByLabel(String label) {
    switch (label.trim().toLowerCase()) {
      case 'soil moisture':
        return Colors.blue;
      case 'nitrogen':
        return Colors.amber;
      case 'phosphorus':
        return Colors.deepPurple;
      case 'potassium':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, double> readings = {
      for (var entry in data.entries)
        if (entry.value is num) entry.key: (entry.value as num).toDouble()
    };

    String? trendLabel;

    if (data['trend'] is Map<String, dynamic>) {
      final trendData = data['trend'] as Map<String, dynamic>;
      trendLabel = trendData['label'] as String?;
    }

    bool useCalculatedTrend = trendLabel == null || trendLabel.trim().isEmpty;

    final sortedKeys = readings.keys.toList()
      ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    final List<FlSpot> spots = [];
    for (final dateStr in sortedKeys) {
      final date = DateTime.parse(dateStr);
      final timestamp = date.millisecondsSinceEpoch.toDouble();
      spots.add(FlSpot(timestamp, readings[dateStr]!));
    }

    // Step 2: Set base chart color based on label
    Color chartColor = _getColorByLabel(label);

    // Step 3: Determine trend (but do NOT override chartColor)
    String trend = 'Stable';
    Color trendColor = Colors.grey;

    if (useCalculatedTrend && readings.length >= 2) {
      final firstValue = readings[sortedKeys.first]!;
      final lastValue = readings[sortedKeys.last]!;

      if (lastValue > firstValue) {
        trend = 'Increasing';
        trendColor = Colors.green;
      } else if (lastValue < firstValue) {
        trend = 'Decreasing';
        trendColor = Colors.red;
      }
    } else {
      switch (trendLabel?.toLowerCase()) {
        case 'increasing':
          trend = 'Increasing';
          trendColor = Colors.green;
          break;
        case 'decreasing':
          trend = 'Decreasing';
          trendColor = Colors.red;
          break;
        case 'fluctuating':
          trend = 'Fluctuating';
          trendColor = Colors.orange;
          break;
        case 'stable':
        default:
          trend = 'Stable';
          trendColor = Colors.grey;
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
                    color: chartColor,
                    isStrokeCapRound: true,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: chartColor.withOpacity(0.1),
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
                color: trendColor.withOpacity(0.2),
                textColor: trendColor,
              ),
            ],
          ),
      ],
    );
  }
}
