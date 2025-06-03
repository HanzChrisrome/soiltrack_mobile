// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/specific_details.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
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

    return widget.plotDetails['user_crops'] == null
        ? const SizedBox.shrink()
        : DynamicContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextRoundedEnclose(
                  text: 'Moisture Threshold for the Crop: $selectedCrop',
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
              ],
            ),
          );
  }
}
