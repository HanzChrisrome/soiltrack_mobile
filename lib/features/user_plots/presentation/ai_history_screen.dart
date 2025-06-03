// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/ai_toggle.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/history_filter.dart';
import 'package:soiltrack_mobile/provider/shared_preferences.dart';
import 'package:soiltrack_mobile/widgets/collapsible_appbar.dart';
import 'package:soiltrack_mobile/widgets/collapsible_scaffold.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

final languageFilterProvider = StateProvider<String>((ref) => 'en');

class AiHistoryScreen extends ConsumerWidget {
  const AiHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilDashboard = ref.watch(soilDashboardProvider);
    final selectedPlotId = soilDashboard.selectedPlotId;
    final fullAiAnalysisList = soilDashboard.filteredAnalysis;
    final isFetchingHistory = soilDashboard.isFetchingHistoryData;
    final plotId = soilDashboard.selectedPlotId;
    final currentCardToggled = soilDashboard.plotToggles[plotId] ?? 'Daily';
    final selectedLang = LanguagePreferences.getLanguage();

    final startDate = soilDashboard.historyDateStartFilter?.toLocal() ??
        DateTime.now().subtract(const Duration(days: 7));
    final endDate =
        soilDashboard.historyDateEndFilter?.toLocal() ?? DateTime.now();

    final adjustedStartDate =
        DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0, 0, 0);
    final adjustedEndDate = DateTime(
        endDate.year, endDate.month, endDate.day, 23, 59, 59, 999, 999);

    final filteredList = fullAiAnalysisList.where((entry) {
      final analysisDate = DateTime.parse(entry['analysis_date']).toLocal();
      final isInRange = (analysisDate.isAfter(adjustedStartDate) ||
              analysisDate.isAtSameMomentAs(adjustedStartDate)) &&
          (analysisDate.isBefore(adjustedEndDate) ||
              analysisDate.isAtSameMomentAs(adjustedEndDate));
      final isForPlot = entry['plot_id'] == selectedPlotId;
      final isCorrectType = entry['analysis_type'] == currentCardToggled;
      final isCorrectLanguage = entry['language_type'] == selectedLang;

      return isInRange && isForPlot && isCorrectType && isCorrectLanguage;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {},
        child: CollapsibleSliverScaffold(
          expandedHeight: 200,
          backgroundColor: Colors.white,
          headerBuilder: (context, isCollapsed) {
            return CollapsibleSliverAppBar(
              isCollapsed: isCollapsed,
              onBackTap: () {
                context.pop();
              },
              collapsedTitle: 'AI Analytics History',
              title: 'AI Analytics \nHistory',
              backgroundColor: Theme.of(context).colorScheme.primary,
            );
          },
          bodySlivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AiToggle(plotId: plotId),
                  const SizedBox(height: 5),
                  const HistoryFilterWidget(),
                  const SizedBox(height: 10),
                  if (isFetchingHistory) _buildLoadingState(context),
                  if (!isFetchingHistory && filteredList.isNotEmpty)
                    ..._buildAnalysisCards(context, filteredList),
                  if (!isFetchingHistory && filteredList.isEmpty)
                    _buildEmptyState(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 450,
      child: Center(
        child: DynamicContainer(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.horizontalRotatingDots(
                color: Theme.of(context).colorScheme.onPrimary,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnalysisCards(
      BuildContext context, List<Map<String, dynamic>> analysisList) {
    return analysisList.map((analysis) {
      final aiData = analysis['analysis']['AI_Analysis'];
      final date = analysis['analysis_date'];
      final findings = aiData['summary']['findings'];
      final formattedDate =
          DateFormat('MMMM d, yyyy').format(DateTime.parse(date));

      return GestureDetector(
        onTap: () {
          final analysisId = analysis['id'];
          context.pushNamed(
            'ai-analysis-detail',
            pathParameters: {'analysisId': analysisId.toString()},
          );
        },
        child: DynamicContainer(
          backgroundColor: Colors.transparent,
          borderColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analysis for $formattedDate',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                '$findings',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 14,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              DividerWidget(verticalHeight: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tap the card for more details',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 300,
      child: Center(
        child: DynamicContainer(
          width: double.infinity,
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
    );
  }

  Widget _buildLanguageToggle(WidgetRef ref) {
    final selectedLang = LanguagePreferences.getLanguage();
    final primaryColor = Theme.of(ref.context).colorScheme.primary;
    final onPrimaryColor = Theme.of(ref.context).colorScheme.onPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: Text(
            'English',
            style: TextStyle(
              color: selectedLang == 'en' ? onPrimaryColor : primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: selectedLang == 'en',
          selectedColor: onPrimaryColor,
          backgroundColor: primaryColor,
          onSelected: (selected) {
            if (selected)
              ref.read(languageFilterProvider.notifier).state = 'en';
          },
        ),
        const SizedBox(width: 5),
        ChoiceChip(
          label: Text(
            'Tagalog',
            style: TextStyle(
              color: selectedLang == 'tl' ? onPrimaryColor : primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: selectedLang == 'tl',
          selectedColor: onPrimaryColor,
          backgroundColor: primaryColor,
          onSelected: (selected) {
            if (selected)
              ref.read(languageFilterProvider.notifier).state = 'tl';
          },
        ),
      ],
    );
  }
}
