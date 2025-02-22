import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/specific_details.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class PlotDetailsWidget extends ConsumerWidget {
  const PlotDetailsWidget(
      {super.key,
      required this.assignedSensor,
      required this.assignedNutrientSensor,
      required this.soilType});

  final String assignedSensor;
  final String assignedNutrientSensor;
  final String soilType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextRoundedEnclose(
                  text: 'Plot Details',
                  color: Colors.white,
                  textColor: Colors.grey[500]!),
              const SizedBox(height: 15),
              SpecificDetails(
                icon: Icons.sensors,
                title: 'Moisture Sensor',
                details: assignedSensor,
              ),
              SpecificDetails(
                icon: Icons.sensors,
                title: 'Nutrient Sensor',
                details: assignedNutrientSensor,
              ),
              SpecificDetails(
                icon: Icons.grass,
                title: 'Soil Type',
                details: soilType,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
