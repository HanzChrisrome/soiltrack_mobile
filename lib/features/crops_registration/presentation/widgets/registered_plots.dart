import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/edit_card.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class RegisteredPlots extends ConsumerWidget {
  const RegisteredPlots(
      {super.key,
      required this.plotName,
      required this.cropName,
      required this.assignedCategory,
      required this.isSoilMoistureSensorAssigned,
      required this.isSoilNutrientSensorAssigned,
      required this.soilMoistureSensorName});

  final String plotName;
  final String cropName;
  final String assignedCategory;
  final bool isSoilMoistureSensorAssigned;
  final bool isSoilNutrientSensorAssigned;
  final String soilMoistureSensorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 236, 236, 236),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plot Name: ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextGradient(text: plotName, fontSize: 25),
                ],
              ),
              const Spacer(),
              TextRoundedEnclose(text: cropName),
            ],
          ),
          const DividerWidget(verticalHeight: 5),
          Text(
            'Category: $assignedCategory',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.start,
          ),
          const DividerWidget(verticalHeight: 5),
          Row(
            children: [
              Icon(
                Icons.sensors_sharp,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 5),
              Text(
                isSoilMoistureSensorAssigned
                    ? soilMoistureSensorName
                    : 'No Soil Moisture Sensor Assigned',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(
                Icons.sensors_sharp,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 5),
              Text(
                isSoilNutrientSensorAssigned
                    ? 'Soil Nutrient Sensor Assigned'
                    : 'No Soil Nutrient Sensor Assigned',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          OutlineCustomButton(
            buttonText: 'Edit Plot',
            iconData: Icons.edit,
            onPressed: () {
              showCustomizableBottomSheet(
                  context: context,
                  height: 600,
                  centerContent: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextGradient(
                        text: 'Edit plot details',
                        fontSize: 30,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 20),
                      EditCard(subText: 'Plot Name:', mainText: plotName),
                      const SizedBox(height: 10),
                      EditCard(subText: 'Crop Assigned:', mainText: cropName),
                      const SizedBox(height: 10),
                      EditCard(
                          subText: 'Soil Moisture Sensor Assigned:',
                          mainText: assignedCategory),
                    ],
                  ),
                  buttonText: 'Continue',
                  onPressed: () {},
                  showActionButton: false,
                  showCancelButton: false);
            },
          ),
        ],
      ),
    );
  }
}
