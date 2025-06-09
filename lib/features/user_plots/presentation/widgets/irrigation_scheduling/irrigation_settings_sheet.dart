import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/crop_threshold.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/irrigation_scheduling/irrigation_type_toggle.dart';
import 'package:soiltrack_mobile/widgets/dynamic_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart'
    show Time, showPicker;
import 'package:soiltrack_mobile/widgets/filled_button.dart';

void showIrrigationSettingsSheet({
  required BuildContext context,
  required int plotId,
  required String initialIrrigationType,
  required Map<String, dynamic> selectedPlot,
  required void Function(String irrigationType, List<String> days,
          TimeOfDay startTime, Duration duration)
      onSaveSchedule,
}) {
  showCustomModalBottomSheet(
    context: context,
    builder: (context, setState) {
      Duration selectedDuration = Duration(minutes: 30);
      String selectedType = initialIrrigationType;
      TimeOfDay? selectedTime;

      Time timeOfDayToTime(TimeOfDay tod) {
        return Time(hour: tod.hour, minute: tod.minute);
      }

      TimeOfDay timeToTimeOfDay(Time t) {
        return TimeOfDay(hour: t.hour, minute: t.minute);
      }

      final List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
      final List<String> fullDays = [
        'Sun',
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat'
      ];
      List<String> selectedDays = [];
      return StatefulBuilder(
        builder: (context, localSetState) {
          void pickTime() {
            Navigator.of(context).push(
              showPicker(
                context: context,
                value: selectedTime != null
                    ? timeOfDayToTime(selectedTime!)
                    : timeOfDayToTime(TimeOfDay.now()),
                onChange: (Time newTime) {
                  localSetState(() {
                    selectedTime = timeToTimeOfDay(newTime);
                  });
                },
                blurredBackground: true,
                is24HrFormat: false,
                cancelStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                okText: 'Set Time',
                okStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          void pickDuration() async {
            final result = await showDurationPicker(
                context: context,
                initialTime: selectedDuration,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ));

            if (result != null) {
              localSetState(() {
                selectedDuration = result;
              });
            }
          }

          return SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IrrigationTypeToggle(
                  plotId: plotId,
                  irrigationType: selectedType,
                  onChanged: (newType) {
                    localSetState(() {
                      selectedType = newType;
                    });
                  },
                ),
                const SizedBox(height: 5),
                if (selectedType == 'Automated Irrigation')
                  CropThresholdWidget(plotDetails: selectedPlot),
                if (selectedType == 'Scheduled Irrigation')
                  Column(
                    children: [
                      Wrap(
                        spacing: 3,
                        children: List.generate(days.length, (index) {
                          final isSelected =
                              selectedDays.contains(fullDays[index]);
                          return FilterChip(
                            label: Text(
                              days[index],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Colors.black,
                              ),
                            ),
                            showCheckmark: false,
                            selected: isSelected,
                            selectedColor:
                                Theme.of(context).colorScheme.onSecondary,
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Colors.grey.shade400,
                              ),
                            ),
                            onSelected: (selected) {
                              localSetState(() {
                                if (selected) {
                                  selectedDays.add(fullDays[index]);
                                } else {
                                  selectedDays.remove(fullDays[index]);
                                }
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: pickTime,
                        child: DynamicContainer(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 15,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Start Time: ${selectedTime?.format(context) ?? "--:--"}',
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.access_time),
                                onPressed: pickTime,
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: pickDuration,
                        child: DynamicContainer(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 15,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Duration: ${selectedDuration.inHours}h ${selectedDuration.inMinutes.remainder(60)}m',
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.timer),
                                onPressed: pickDuration,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledCustomButton(
                        buttonText: 'Set Irrigation type to Scheduled',
                        onPressed: () {
                          if (selectedType == 'Scheduled Irrigation' &&
                              (selectedDays.isEmpty || selectedTime == null)) {
                            NotifierHelper.showErrorToast(
                                context, 'Please select a day and time.');
                            return;
                          }

                          onSaveSchedule(selectedType, selectedDays,
                              selectedTime!, selectedDuration);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}
