// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/history_filter.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class AiHistoryScreen extends ConsumerStatefulWidget {
  const AiHistoryScreen({super.key});

  @override
  _AiHistoryScreenState createState() => _AiHistoryScreenState();
}

class _AiHistoryScreenState extends ConsumerState<AiHistoryScreen> {
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
    final startDate =
        ref.watch(soilDashboardProvider).historyDateStartFilter?.toLocal();
    final endDate =
        ref.watch(soilDashboardProvider).historyDateEndFilter?.toLocal();
    final selectedPlotId = ref.watch(soilDashboardProvider).selectedPlotId;
    final fullAiAnalysisList =
        ref.watch(soilDashboardProvider).filteredAnalysis;

    final filteredList = fullAiAnalysisList.where((entry) {
      final analysisDate = DateTime.parse(entry['analysis_date']).toLocal();

      final isInRange =
          (startDate == null || !analysisDate.isBefore(startDate)) &&
              (endDate == null ||
                  analysisDate.isBefore(endDate.add(Duration(days: 1))));

      final isForPlot = entry['plot_id'] == selectedPlotId;
      return isInRange && isForPlot;
    }).toList();

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
                        if (filteredList.isNotEmpty)
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: filteredList.map((analysis) {
                                final aiData =
                                    analysis['analysis']['AI_Analysis'];
                                final date = analysis['analysis_date'];
                                final findings = aiData['summary']['findings'];
                                final formattedDate = DateFormat('MMMM d, yyyy')
                                    .format(DateTime.parse(date));

                                return GestureDetector(
                                  onTap: () {
                                    final analysisId = analysis['id'];
                                    context.pushNamed(
                                      'ai-analysis-detail',
                                      pathParameters: {
                                        'analysisId': analysisId.toString()
                                      },
                                    );
                                  },
                                  child: DynamicContainer(
                                    backgroundColor: Colors.transparent,
                                    borderColor: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Analysis for $formattedDate',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '$findings',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                fontSize: 14,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        DividerWidget(verticalHeight: 1),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Tap the card for more details',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                  ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()),
                        if (filteredList.isEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 300,
                            child: Center(
                              child: DynamicContainer(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextGradient(
                                      text: '[ NO AI ANALYSIS FOUND ]',
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
                  'AI History',
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
                        text: 'AI Analytics \nHistory',
                        fontSize: 45,
                        textAlign: TextAlign.center,
                        letterSpacing: -1.3,
                        heightSpacing: 1,
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
