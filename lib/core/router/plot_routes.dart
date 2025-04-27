import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/utils/page_transition.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_adding.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_assigning.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_screen.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/custom_add.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/ai_analytics_screen.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/ai_history_screen.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/irrigation_log.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/polygon_map_screen.dart';

final plotRoutes = [
  GoRoute(
    path: '/select-category',
    name: 'select-category',
    builder: (context, state) => const CropsScreen(),
  ),
  GoRoute(
    path: '/add-crops',
    name: 'add-crops',
    builder: (context, state) => const AddingCropsScreen(),
  ),
  GoRoute(
    path: '/assign-crops',
    name: 'assign-crops',
    builder: (context, state) => const AssignCrops(),
  ),
  GoRoute(
    path: '/add-custom-crops',
    name: 'add-custom-crops',
    builder: (context, state) => const AddCustomCrop(),
  ),
  GoRoute(
    path: '/ai-analytics',
    name: 'ai-analytics',
    builder: (context, state) => AiAnalysisOverview(),
  ),
  GoRoute(
    path: '/ai-analytics/:analysisId',
    name: 'ai-analysis-detail',
    pageBuilder: (context, state) {
      final analysisId = state.pathParameters['analysisId'];
      return customPageTransition(
        context,
        AiAnalysisOverview(analysisId: analysisId),
        transitionType: 'slide',
      );
    },
  ),
  GoRoute(
    path: '/ai-history',
    name: 'ai-history',
    builder: (context, state) => const AiHistoryScreen(),
  ),
  GoRoute(
    path: '/irrigation-logs',
    name: 'irrigation-logs',
    builder: (context, state) => const IrrigationLogScreen(),
  ),
  GoRoute(
    path: '/polygon-maps',
    name: 'polygon-maps',
    builder: (context, state) => const PolygonMapScreen(),
  ),
];
