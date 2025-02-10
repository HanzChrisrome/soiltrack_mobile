// app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'router_notifier.dart';
import 'auth_routes.dart';
import 'setup_routes.dart';
import 'home_routes.dart';
import 'package:soiltrack_mobile/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  return GoRouter(
    refreshListenable: router,
    redirect: router.redirect,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ...authRoutes,
      ...setupRoutes,
      ...homeRoutes,
    ],
  );
});
