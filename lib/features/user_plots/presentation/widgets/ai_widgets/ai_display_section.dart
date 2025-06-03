import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/ai_generated.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/ai_ready_card.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/ai_unready_card.dart';

class AiDisplaySection extends ConsumerWidget {
  final int plotId;
  final bool hasSufficientDailyData;
  final bool hasSufficientWeeklyData;
  final Map<dynamic, dynamic> aiAnalysisWeekly;
  final Map<dynamic, dynamic> aiAnalysisDaily;
  final VoidCallback? onGenerateTap;
  final VoidCallback? onViewAnalysis;

  const AiDisplaySection({
    Key? key,
    required this.plotId,
    required this.hasSufficientDailyData,
    required this.hasSufficientWeeklyData,
    required this.aiAnalysisWeekly,
    required this.aiAnalysisDaily,
    this.onGenerateTap,
    this.onViewAnalysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentToggle =
        ref.watch(soilDashboardProvider).plotToggles[plotId] ?? 'Daily';

    if (currentToggle == 'Weekly') {
      if (aiAnalysisWeekly.isEmpty) {
        return AiUnreadyCard(
          currentToggle: currentToggle,
        );
      } else {
        return AiGeneratedCard(
          onTap: onViewAnalysis ?? () {},
          currentToggle: currentToggle,
        );
      }
    } else if (currentToggle == 'Daily') {
      if (aiAnalysisDaily.isEmpty) {
        return AiUnreadyCard(currentToggle: currentToggle);
      } else {
        return AiGeneratedCard(
          onTap: onViewAnalysis ?? () {},
          currentToggle: currentToggle,
        );
      }
    }

    return const SizedBox.shrink();
  }
}
