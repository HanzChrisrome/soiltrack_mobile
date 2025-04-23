// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/custom_accordion.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/history_filter.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class IrrigationLogScreen extends ConsumerStatefulWidget {
  const IrrigationLogScreen({super.key});

  @override
  _IrrigationLogScreenState createState() => _IrrigationLogScreenState();
}

class _IrrigationLogScreenState extends ConsumerState<IrrigationLogScreen> {
  bool isAppBarCollapsed = false;
  void _updateAppBarTitle(double scrollOffset, double expandedHeight) {
    bool shouldCollapse = scrollOffset > expandedHeight - kToolbarHeight;

    if (shouldCollapse != isAppBarCollapsed) {
      setState(() {
        isAppBarCollapsed = shouldCollapse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final soilDashboard = ref.watch(soilDashboardProvider);
    final selectedPlotId = soilDashboard.selectedPlotId;
    final irrigationLogs = soilDashboard.irrigationLogs;

    final startDate = soilDashboard.historyDateStartFilter?.toLocal() ??
        DateTime.now().subtract(const Duration(days: 7));
    final endDate =
        soilDashboard.historyDateEndFilter?.toLocal() ?? DateTime.now();

    final adjustedStartDate =
        DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0, 0, 0);

    final adjustedEndDate = DateTime(
        endDate.year, endDate.month, endDate.day, 23, 59, 59, 999, 999);

    final filteredLogs = irrigationLogs.where((log) {
      final plotMatch = log['plot_id'] == selectedPlotId;
      final timeStarted = DateTime.parse(log['time_started']).toLocal();

      // Check if the log is within the adjusted range
      final inRange = (timeStarted.isAfter(adjustedStartDate) ||
              timeStarted.isAtSameMomentAs(adjustedStartDate)) &&
          (timeStarted.isBefore(adjustedEndDate) ||
              timeStarted.isAtSameMomentAs(adjustedEndDate));

      return plotMatch && inRange;
    }).toList();

    final Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    for (final log in filteredLogs) {
      final date = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(log['time_started']).toLocal());
      groupedByDate.putIfAbsent(date, () => []).add(log);
    }

    final sortedEntries = groupedByDate.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.axis == Axis.vertical) {
                _updateAppBarTitle(
                  scrollNotification.metrics.pixels,
                  200.0,
                );
              }
              return true;
            },
            child: CustomScrollView(
              slivers: [
                _buildSilverAppBar(context),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        HistoryFilterWidget(),
                        const SizedBox(height: 10),
                        if (sortedEntries.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sortedEntries.map((entry) {
                              final formattedDate = DateFormat('MMMM d, yyyy')
                                  .format(DateTime.parse(entry.key));
                              final logs = entry.value;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: CustomAccordion(
                                  titleText:
                                      'Irrigation Log for $formattedDate',
                                  initiallyExpanded: false,
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: logs.map((log) {
                                      final timeStarted =
                                          DateTime.parse(log['time_started'])
                                              .toLocal();
                                      final timeStopped =
                                          DateTime.parse(log['time_stopped'])
                                              .toLocal();

                                      final durationMinutes = timeStopped
                                          .difference(timeStarted)
                                          .inMinutes;
                                      final formattedStart =
                                          DateFormat('hh:mm a')
                                              .format(timeStarted);
                                      final formattedStop =
                                          DateFormat('hh:mm a')
                                              .format(timeStopped);

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '• $formattedStart - $formattedStop',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          Text(
                                            '$durationMinutes min',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: Colors.grey[600]),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        if (sortedEntries.isEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 300,
                            child: Center(
                              child: DynamicContainer(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextGradient(
                                      text: '[ NO IRRIGATION LOG FOUND ]',
                                      fontSize: 17,
                                      textAlign: TextAlign.center,
                                      letterSpacing: -1.3,
                                      heightSpacing: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSilverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      pinned: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        title: isAppBarCollapsed
            ? Container(
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                  'Irrigation Logs',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    letterSpacing: -1.3,
                  ),
                ),
              )
            : null,
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextGradient(
                        text: 'Irrigation Log',
                        fontSize: 45,
                        textAlign: TextAlign.center,
                        letterSpacing: -2.5,
                        heightSpacing: 1.2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
