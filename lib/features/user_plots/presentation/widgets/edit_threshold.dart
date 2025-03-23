import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:toastification/toastification.dart';

void editThreshold({
  required BuildContext context,
  required String title,
  required int minLabel,
  required int maxLabel,
  required TextEditingController minController,
  required TextEditingController maxController,
  required int currentMin,
  required int currentMax,
  required String thresholdType,
  required SoilDashboardNotifier soilDashboardNotifier,
  required String minColumn,
  required String maxColumn,
}) {
  showCustomizableBottomSheet(
    height: 400,
    context: context,
    centerContent: Column(
      children: [
        TextGradient(
          text: title,
          fontSize: 35,
          heightSpacing: 1,
        ),
        const SizedBox(height: 20),
        TextFieldWidget(
          label: '$thresholdType Min $minLabel%',
          controller: minController,
          isNumberOnly: true,
        ),
        TextFieldWidget(
          label: '$thresholdType Max $maxLabel%',
          controller: maxController,
          isNumberOnly: true,
        ),
      ],
    ),
    buttonText: 'Proceed',
    onPressed: () {
      Navigator.of(context).pop();
      int minThreshold = int.tryParse(minController.text) ?? currentMin;
      int maxThreshold = int.tryParse(maxController.text) ?? currentMax;

      if (minThreshold > maxLabel) {
        ToastService.showToast(
          context: context,
          message: 'Min value cannot be greater than max',
          type: ToastificationType.error,
        );
        return;
      }

      if (maxThreshold < minLabel) {
        ToastService.showToast(
          context: context,
          message: 'Max value cannot be less than min',
          type: ToastificationType.error,
        );
        return;
      }

      Map<String, int> updatedValues = {
        minColumn: minThreshold,
        maxColumn: maxThreshold,
      };

      soilDashboardNotifier.saveNewThreshold(
        context,
        thresholdType,
        updatedValues,
      );

      minController.clear();
      maxController.clear();
    },
  );
}
