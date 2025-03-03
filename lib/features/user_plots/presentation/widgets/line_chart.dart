import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class NutrientProgressChart extends ConsumerWidget {
  const NutrientProgressChart({
    super.key,
    required this.nitrogenData,
    required this.phosphorusData,
    required this.potassiumData,
    required this.moistureData,
  });

  final List<Map<String, dynamic>> nitrogenData;
  final List<Map<String, dynamic>> phosphorusData;
  final List<Map<String, dynamic>> potassiumData;
  final List<Map<String, dynamic>> moistureData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilDashboardNotifier = ref.watch(soilDashboardProvider.notifier);

    // Extract the latest timestamp from the most recent data entry
    String lastUpdated = _getLatestTimestamp();

    int nitrogenValue = nitrogenData.isNotEmpty
        ? (nitrogenData.last['value'] as num).toInt()
        : 0;
    int phosphorusValue = phosphorusData.isNotEmpty
        ? (phosphorusData.last['value'] as num).toInt()
        : 0;
    int potassiumValue = potassiumData.isNotEmpty
        ? (potassiumData.last['value'] as num).toInt()
        : 0;

    // Ensure moisture does not exceed 100%
    int moistureValue = moistureData.isNotEmpty
        ? (moistureData.last['value'] as num).toInt().clamp(0, 100)
        : 0;

    const int nutrientMaxValue = 200;
    const int moistureMaxValue = 100; // Cap moisture at 100%

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextRoundedEnclose(
                text: 'Readings as of $lastUpdated',
                color: Colors.white,
                textColor: Colors.grey[500]!,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  soilDashboardNotifier.fetchUserPlotData();
                },
                child: const Icon(
                  Icons.refresh,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Moisture Progress Bar (Capped at 100%)
          _buildProgressBar(
              "Moisture", moistureValue, moistureMaxValue, Colors.blue),

          // Nutrient Progress Bars (Only show if at least one is nonzero)
          if (nitrogenValue != 0 || phosphorusValue != 0 || potassiumValue != 0)
            Column(
              children: [
                _buildProgressBar(
                    "Nitrogen", nitrogenValue, nutrientMaxValue, Colors.green),
                _buildProgressBar("Phosphorus", phosphorusValue,
                    nutrientMaxValue, Colors.orange),
                _buildProgressBar("Potassium", potassiumValue, nutrientMaxValue,
                    Colors.purple),
              ],
            ),
        ],
      ),
    );
  }

  String _getLatestTimestamp() {
    List<dynamic> timestamps = [
      if (nitrogenData.isNotEmpty) nitrogenData.last['read_time'],
      if (phosphorusData.isNotEmpty) phosphorusData.last['read_time'],
      if (potassiumData.isNotEmpty) potassiumData.last['read_time'],
      if (moistureData.isNotEmpty) moistureData.last['read_time'],
    ];

    if (timestamps.isEmpty) return "No data available";

    DateTime? latestTimestamp;
    for (var timestamp in timestamps) {
      DateTime? parsedDate = _parseTimestamp(timestamp);
      if (parsedDate != null &&
          (latestTimestamp == null || parsedDate.isAfter(latestTimestamp))) {
        latestTimestamp = parsedDate;
      }
    }

    if (latestTimestamp == null) return "Invalid date";

    return DateFormat('MMM dd, yyyy hh:mm a').format(latestTimestamp);
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    try {
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Widget _buildProgressBar(String label, int value, int maxValue, Color color) {
    double progress = (value / maxValue).clamp(0.0, 1.0);

    LinearGradient gradient = LinearGradient(
      colors: [
        color.withOpacity(0.7),
        color.withOpacity(1.0),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label: ',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text("$value%",
                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 10,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return gradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
