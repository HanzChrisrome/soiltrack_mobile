// app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/router/plot_routes.dart';
import 'package:soiltrack_mobile/core/router/settings_routes.dart';
import 'auth_routes.dart';
import 'setup_routes.dart';
import 'home_routes.dart';
import 'package:soiltrack_mobile/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ...authRoutes,
      ...setupRoutes,
      ...homeRoutes,
      ...plotRoutes,
      ...settingsRoutes,
    ],
  );
});
