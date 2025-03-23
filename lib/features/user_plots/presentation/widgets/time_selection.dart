// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';

class TimeSelectionWidget extends ConsumerWidget {
  const TimeSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilDashboardState = ref.watch(soilDashboardProvider);
    final selectedOption = soilDashboardState.selectedTimeRangeFilter;
    final List<String> options = ['1D', '1W', '1M', '3M'];

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: options.map((option) {
              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(soilDashboardProvider.notifier)
                          .updateTimeSelection(
                            option,
                            customEndDate: null,
                            customStartDate: null,
                          );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: selectedOption == option
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedOption == option
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  if (option != options.last)
                    SizedBox(
                      height: 10,
                      child: VerticalDivider(
                        color: Colors.grey[300]!,
                        thickness: 1,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            await _selectDateRange(context, ref);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: soilDashboardState.selectedTimeRangeFilter == 'Custom'
                  ? Border.all(color: Colors.green, width: 1)
                  : null,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Custom'),
                SizedBox(width: 30),
                Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final soilDashboardState = ref.watch(soilDashboardProvider);
    DateTime today = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 500,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Theme.of(context)
                            .colorScheme
                            .onPrimary, // Selected date color
                        onPrimary: Colors.white, // Text color on selected date
                        surface: Colors.blueGrey, // Background color
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors
                              .green, // Color of "OK" and "CANCEL" buttons
                        ),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: null,
                      firstDate: DateTime(2000),
                      lastDate: today,
                      onDateChanged: (newDate) {
                        setState(() {
                          if (startDate == null ||
                              (startDate != null && endDate != null)) {
                            startDate = newDate;
                            endDate = null;
                          } else if (startDate != null &&
                              endDate == null &&
                              newDate.isAfter(startDate!)) {
                            endDate = newDate;
                          } else {
                            startDate = newDate;
                            endDate = null;
                          }
                        });
                      },
                    ),
                  ),
                  FilledCustomButton(
                    icon: Icons.filter_alt_outlined,
                    buttonText: 'Filter Date',
                    onPressed: startDate != null && endDate != null
                        ? () {
                            ref
                                .read(soilDashboardProvider.notifier)
                                .updateTimeSelection(
                                  'Custom',
                                  customStartDate: startDate,
                                  customEndDate: endDate,
                                );
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                  const SizedBox(height: 20),
                  if (soilDashboardState.customStartDate != null &&
                      soilDashboardState.customEndDate != null)
                    Text(
                      "Current Range: ${DateFormat('MMMM d, y').format(soilDashboardState.customStartDate!)} - "
                      "${DateFormat('MMMM d, y').format(soilDashboardState.customEndDate!)}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.blue,
                      ),
                    ),
                  if (startDate != null)
                    Text(
                      "Selected Range: ${startDate != null ? DateFormat('MMMM d, y').format(startDate!) : ''} - "
                      "${endDate != null ? DateFormat('MMMM d, y').format(endDate!) : 'Select End Date'}",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  if (soilDashboardState.customStartDate == null)
                    Text(
                        'Select a start date to enable the "Filter Date" button',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        )),
                ],
              ),
            );
          },
        );
      },
    ).then((selectedRange) {});
  }
}
