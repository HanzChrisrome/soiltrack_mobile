// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/specific_details.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/edit_threshold.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class CropThresholdWidget extends ConsumerStatefulWidget {
  const CropThresholdWidget({super.key, required this.plotDetails});

  final Map<String, dynamic> plotDetails;

  @override
  _CropThresholdWidgetState createState() => _CropThresholdWidgetState();
}

class _CropThresholdWidgetState extends ConsumerState<CropThresholdWidget> {
  final TextEditingController minMoisture = TextEditingController();
  final TextEditingController maxMoisture = TextEditingController();
  final TextEditingController minNitrogen = TextEditingController();
  final TextEditingController maxNitrogen = TextEditingController();
  final TextEditingController minPotassium = TextEditingController();
  final TextEditingController maxPotassium = TextEditingController();
  final TextEditingController minPhosphorus = TextEditingController();
  final TextEditingController maxPhosphorus = TextEditingController();

  @override
  void dispose() {
    minMoisture.dispose();
    maxMoisture.dispose();
    minNitrogen.dispose();
    maxNitrogen.dispose();
    minPotassium.dispose();
    maxPotassium.dispose();
    minPhosphorus.dispose();
    maxPhosphorus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);
    final moistureMin = widget.plotDetails['user_crops']?['moisture_min'] ?? 0;
    final moistureMax = widget.plotDetails['user_crops']?['moisture_max'] ?? 0;
    final nitrogenMin = widget.plotDetails['user_crops']?['nitrogen_min'] ?? 0;
    final nitrogenMax = widget.plotDetails['user_crops']?['nitrogen_max'] ?? 0;
    final potassiumMin =
        widget.plotDetails['user_crops']?['potassium_min'] ?? 0;
    final potassiumMax =
        widget.plotDetails['user_crops']?['potassium_max'] ?? 0;
    final phosphorusMin =
        widget.plotDetails['user_crops']?['phosphorus_min'] ?? 0;
    final phosphorusMax =
        widget.plotDetails['user_crops']?['phosphorus_max'] ?? 0;
    final selectedCrop = widget.plotDetails['user_crops']?['crop_name'] ?? '';

    return DynamicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextRoundedEnclose(
            text: 'Threshold for the Crop: $selectedCrop',
            color: Colors.white,
            textColor: Colors.grey[500]!,
          ),
          const SizedBox(height: 15),
          SpecificDetails(
            icon: Icons.eco_outlined,
            title: 'Moisture Level',
            details: '$moistureMin% - $moistureMax%',
            onPressed: () {
              editThreshold(
                context: context,
                title: 'Edit Moisture Threshold',
                minLabel: moistureMin,
                maxLabel: moistureMax,
                minController: minMoisture,
                maxController: maxMoisture,
                currentMin: moistureMin,
                currentMax: moistureMax,
                thresholdType: 'Moisture',
                soilDashboardNotifier: userPlotNotifier,
                minColumn: 'moisture_min',
                maxColumn: 'moisture_max',
              );
            },
          ),
          const DividerWidget(verticalHeight: 1),
          SpecificDetails(
            icon: Icons.grass,
            title: 'Nitrogen Level',
            details: '$nitrogenMin ppm - $nitrogenMax ppm',
            onPressed: () {
              editThreshold(
                context: context,
                title: 'Edit Nitrogen Threshold',
                minLabel: nitrogenMin,
                maxLabel: nitrogenMax,
                minController: minNitrogen,
                maxController: maxNitrogen,
                currentMin: nitrogenMin,
                currentMax: nitrogenMax,
                thresholdType: 'Nitrogen',
                soilDashboardNotifier: userPlotNotifier,
                minColumn: 'nitrogen_min',
                maxColumn: 'nitrogen_max',
              );
            },
          ),
          const DividerWidget(verticalHeight: 1),
          SpecificDetails(
            icon: Icons.science_outlined,
            title: 'Phosphorus Level',
            details: '$phosphorusMin ppm - $phosphorusMax ppm',
            onPressed: () {
              editThreshold(
                context: context,
                title: 'Edit Phosphorus Threshold',
                minLabel: phosphorusMin,
                maxLabel: phosphorusMax,
                minController: minPhosphorus,
                maxController: maxPhosphorus,
                currentMin: phosphorusMin,
                currentMax: phosphorusMax,
                thresholdType: 'Phosphorus',
                soilDashboardNotifier: userPlotNotifier,
                minColumn: 'phosphorus_min',
                maxColumn: 'phosphorus_max',
              );
            },
          ),
          const DividerWidget(verticalHeight: 1),
          SpecificDetails(
            icon: Icons.local_florist,
            title: 'Potassium Level',
            details: '$potassiumMin ppm - $potassiumMax ppm',
            onPressed: () {
              editThreshold(
                context: context,
                title: 'Edit Potassium Threshold',
                minLabel: potassiumMin,
                maxLabel: potassiumMax,
                minController: minPotassium,
                maxController: maxPotassium,
                currentMin: potassiumMin,
                currentMax: potassiumMax,
                thresholdType: 'Potassium',
                soilDashboardNotifier: userPlotNotifier,
                minColumn: 'potassium_min',
                maxColumn: 'potassium_max',
              );
            },
          ),
        ],
      ),
    );
  }
}
