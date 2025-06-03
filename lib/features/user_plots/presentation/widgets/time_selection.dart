import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:table_calendar/table_calendar.dart';

class TimeSelectionWidget extends ConsumerWidget {
  const TimeSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilDashboardState = ref.watch(soilDashboardProvider);
    final selectedOption = soilDashboardState.selectedTimeRangeFilterGeneral;
    final List<String> options = ['1D', '1W', '1M', '3M'];

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenWidth * 0.02,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border:
                  soilDashboardState.selectedTimeRangeFilterGeneral == 'Custom'
                      ? Border.all(color: Colors.green, width: 1)
                      : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isSmallScreen ? 14 : 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                SizedBox(width: 5),
                Text(
                  'Custom',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: isSmallScreen ? 18 : 22,
                ),
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

    DateTime? startDate = soilDashboardState.customStartDate;
    DateTime? endDate = soilDashboardState.customEndDate;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 360;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TableCalendar(
                    focusedDay: startDate ?? today,
                    firstDay: DateTime(2025),
                    lastDay: today,
                    selectedDayPredicate: (day) {
                      if (startDate != null && endDate != null) {
                        return (day.isAfter(startDate!) &&
                                day.isBefore(endDate!)) ||
                            day.isAtSameMomentAs(startDate!) ||
                            day.isAtSameMomentAs(endDate!);
                      } else if (startDate != null && endDate == null) {
                        return day.isAtSameMomentAs(startDate!);
                      } else {
                        return false;
                      }
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        if (startDate == null ||
                            (startDate != null && endDate != null)) {
                          startDate = selectedDay;
                          endDate = null;
                        } else if (startDate != null && endDate == null) {
                          if (selectedDay.isAfter(startDate!)) {
                            endDate = selectedDay;
                          } else {
                            startDate = selectedDay;
                            endDate = null;
                          }
                        }
                      });
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      rangeHighlightColor:
                          Theme.of(context).colorScheme.onSecondary,
                      cellAlignment: Alignment.center,
                      tablePadding: const EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledCustomButton(
                    icon: Icons.filter_alt_outlined,
                    buttonText: 'Filter Date',
                    width: screenWidth * 0.8,
                    fontSize: isSmallScreen ? 14 : 16,
                    onPressed: startDate != null
                        ? () {
                            ref
                                .read(soilDashboardProvider.notifier)
                                .updateTimeSelection(
                                  'Custom',
                                  customStartDate: startDate,
                                  customEndDate: endDate ?? startDate,
                                );
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
