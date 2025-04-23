// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/hardware_provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:toastification/toastification.dart';

class AddCustomCrop extends ConsumerStatefulWidget {
  const AddCustomCrop({super.key});

  @override
  _AddCustomCropState createState() => _AddCustomCropState();
}

class _AddCustomCropState extends ConsumerState<AddCustomCrop> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cropNameController = TextEditingController();
  final TextEditingController minMoistureController = TextEditingController();
  final TextEditingController maxMoistureController = TextEditingController();
  final TextEditingController minNitrogenController = TextEditingController();
  final TextEditingController maxNitrogenController = TextEditingController();
  final TextEditingController minPhosphorusController = TextEditingController();
  final TextEditingController maxPhosphorusController = TextEditingController();
  final TextEditingController minPotassiumController = TextEditingController();
  final TextEditingController maxPotassiumController = TextEditingController();

  @override
  void dispose() {
    cropNameController.dispose();
    minMoistureController.dispose();
    maxMoistureController.dispose();
    minNitrogenController.dispose();
    maxNitrogenController.dispose();
    minPhosphorusController.dispose();
    maxPhosphorusController.dispose();
    minPotassiumController.dispose();
    maxPotassiumController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cropProvider.notifier).unselectSensor());
  }

  @override
  Widget build(BuildContext context) {
    final sensorState = ref.watch(sensorsProvider);
    final cropState = ref.watch(cropProvider);
    final cropNotifier = ref.watch(cropProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: 200,
                  collapsedHeight: 100,
                  pinned: false,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Icon(
                            Icons.eco_outlined,
                            size: 50,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const TextGradient(
                            text: 'Add a custom crop',
                            textAlign: TextAlign.center,
                            fontSize: 45,
                            letterSpacing: -2.9,
                            heightSpacing: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            border: Border.all(
                              color: Colors.grey[100]!,
                              width: 2,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFieldWidget(
                                    label: 'Crop Name',
                                    controller: cropNameController),
                                const DividerWidget(verticalHeight: 1),
                                Text(
                                  'Moisture Level',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 14,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldWidget(
                                        label: 'Minimum Level',
                                        controller: minMoistureController,
                                        isNumberOnly: true,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFieldWidget(
                                        label: 'Maximum Level',
                                        controller: maxMoistureController,
                                        isNumberOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const DividerWidget(verticalHeight: 1),
                                Text(
                                  'Nitrogen Level',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 14,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldWidget(
                                        label: 'Minimum Level',
                                        controller: minNitrogenController,
                                        isNumberOnly: true,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFieldWidget(
                                        label: 'Maximum Level',
                                        controller: maxNitrogenController,
                                        isNumberOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const DividerWidget(verticalHeight: 1),
                                Text(
                                  'Phosphorus Level',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 14,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldWidget(
                                        label: 'Minimum Level',
                                        controller: minPhosphorusController,
                                        isNumberOnly: true,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFieldWidget(
                                        label: 'Maximum Level',
                                        controller: maxPhosphorusController,
                                        isNumberOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const DividerWidget(verticalHeight: 1),
                                Text(
                                  'Potassium Level',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 14,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldWidget(
                                        label: 'Minimum Level',
                                        controller: minPotassiumController,
                                        isNumberOnly: true,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFieldWidget(
                                        label: 'Maximum Level',
                                        controller: maxPotassiumController,
                                        isNumberOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledCustomButton(
                          icon: Icons.verified_outlined,
                          buttonText: 'Proceed',
                          onPressed: cropState.isSaving
                              ? null
                              : () {
                                  if (minMoistureController.text.isEmpty ||
                                      maxMoistureController.text.isEmpty ||
                                      minNitrogenController.text.isEmpty ||
                                      maxNitrogenController.text.isEmpty ||
                                      minPhosphorusController.text.isEmpty ||
                                      maxPhosphorusController.text.isEmpty ||
                                      minPotassiumController.text.isEmpty ||
                                      maxPotassiumController.text.isEmpty ||
                                      cropNameController.text.isEmpty) {
                                    ToastService.showToast(
                                        context: context,
                                        message: 'Please fill in all fields',
                                        type: ToastificationType.error);
                                    return;
                                  }

                                  final int minMoisture =
                                      int.parse(minMoistureController.text);
                                  final int maxMoisture =
                                      int.parse(maxMoistureController.text);
                                  final int minNitrogen =
                                      int.parse(minNitrogenController.text);
                                  final int maxNitrogen =
                                      int.parse(maxNitrogenController.text);
                                  final int minPhosphorus =
                                      int.parse(minPhosphorusController.text);
                                  final int maxPhosphorus =
                                      int.parse(maxPhosphorusController.text);
                                  final int minPotassium =
                                      int.parse(minPotassiumController.text);
                                  final int maxPotassium =
                                      int.parse(maxPotassiumController.text);

                                  final selectedSensor =
                                      sensorState.moistureSensors.firstWhere(
                                    (sensor) =>
                                        sensor['soil_moisture_sensor_id'] ==
                                        cropState.selectedSensor,
                                    orElse: () => {},
                                  );

                                  final bool isAssigned =
                                      selectedSensor['is_assigned'] == true;

                                  final String title = isAssigned
                                      ? 'This sensor is currently assigned.'
                                      : 'Save Crop?';
                                  final String description = isAssigned
                                      ? 'Are you sure you want to reassign this sensor?'
                                      : 'Are you sure you want to save the configurations without assigning a sensor?';

                                  showCustomBottomSheet(
                                    context: context,
                                    title: title,
                                    description: description,
                                    icon: Icons.chevron_right,
                                    buttonText: 'Continue',
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      cropNotifier.saveNewCrop(
                                          context,
                                          cropNameController.text,
                                          minMoisture,
                                          maxMoisture,
                                          minNitrogen,
                                          maxNitrogen,
                                          minPhosphorus,
                                          maxPhosphorus,
                                          minPotassium,
                                          maxPotassium);
                                    },
                                  );
                                },
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
