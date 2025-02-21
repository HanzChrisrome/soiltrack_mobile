import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class RegisteredPlots extends ConsumerWidget {
  const RegisteredPlots(
      {super.key,
      required this.plotId,
      required this.plotName,
      required this.cropName,
      required this.assignedCategory,
      required this.soilMoistureSensorName,
      required this.soilNutrientSensorName});

  final int plotId;
  final String plotName;
  final String cropName;
  final String assignedCategory;
  final String soilMoistureSensorName;
  final String soilNutrientSensorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilDashboardNotifier = ref.watch(soilDashboardProvider.notifier);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/background/projectBg.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plot Name: ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextGradient(text: plotName, fontSize: 25),
                ],
              ),
              const Spacer(),
              TextRoundedEnclose(
                text: cropName,
                color: Theme.of(context).colorScheme.onPrimary,
                textColor: Colors.white,
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  soilDashboardNotifier.setSelectedPlotId(context, plotId);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
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
                soilMoistureSensorName,
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
                soilNutrientSensorName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
