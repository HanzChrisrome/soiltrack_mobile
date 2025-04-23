// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/sensor_tile.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/hardware_provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class UnassignedSensor extends ConsumerWidget {
  const UnassignedSensor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicContainer(
      width: double.infinity,
      backgroundColor: Colors.red.withOpacity(0.2),
      borderColor: Colors.red.withOpacity(0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
