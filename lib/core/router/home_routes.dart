// home_routes.dart
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/soil_assigning.dart';
import 'package:soiltrack_mobile/features/home/presentation/home_screen.dart';
import 'package:soiltrack_mobile/features/notification/presentation/notification_screen.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/plot_analytics_screen.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/user_plots_screen.dart';

final homeRoutes = [
  GoRoute(
    path: '/home',
    name: 'home',
    builder: (context, state) {
      final initialIndex =
          int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
      return HomeScreen(initialIndex: initialIndex);
    },
    routes: [
      GoRoute(
        path: 'user-plot',
        name: 'user-plot',
        builder: (context, state) => const UserPlotScreen(),
      ),
      GoRoute(
        path: 'plot-analytics',
        name: 'plot-analytics',
        builder: (context, state) => const PlotAnalyticsScreen(),
      ),
      GoRoute(
        path: 'soil-assigning',
        name: 'soil-assigning',
        builder: (context, state) => const SoilAssigningScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/notifications',
    name: 'notifications',
    builder: (context, state) => const NotificationScreen(),
  ),
];
