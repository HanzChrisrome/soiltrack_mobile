import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryFilterWidget extends ConsumerWidget {
  const HistoryFilterWidget({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilDashboardState = ref.watch(soilDashboardProvider);
    final selectedOption = soilDashboardState.selectedHistoryFilter;
    final List<String> options = ['1W', '2W', '3W', '4W'];

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
                          .updateHistoryFilterSelection(option);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
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
                          fontSize: isSmallScreen ? 12 : 14,
                          color: selectedOption == option
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  if (option != options.last)
                    SizedBox(
                      height: 15,
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
        const SizedBox(width: 8),
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
              border: soilDashboardState.selectedHistoryFilter == 'Custom'
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
                const SizedBox(width: 5),
                Text(
                  'Custom',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                const SizedBox(width: 5),
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
    DateTime? selectedDate = soilDashboardState.historyDateStartFilter;

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
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TableCalendar(
                        focusedDay: selectedDate ?? today,
                        firstDay: DateTime(2025),
                        lastDay: today,
                        selectedDayPredicate: (day) =>
                            selectedDate != null &&
                            isSameDay(day, selectedDate),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            selectedDate = selectedDay;
                          });
                        },
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
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
                        onPressed: selectedDate != null
                            ? () {
                                ref
                                    .read(soilDashboardProvider.notifier)
                                    .updateHistoryFilterSelection(
                                      'Custom',
                                      customStartDate: selectedDate,
                                      customEndDate: selectedDate,
                                    );
                                Navigator.pop(context);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
