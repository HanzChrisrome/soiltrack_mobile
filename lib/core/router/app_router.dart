import 'package:soiltrack_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:soiltrack_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/wifi_scan.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/wifi_screen.dart';
import 'package:soiltrack_mobile/features/home/presentation/home_screen.dart';
import 'package:soiltrack_mobile/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  return GoRouter(
    refreshListenable: router,
    redirect: router.redirect,
    routes: router.routes,
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref ref;
  RouterNotifier(this.ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = ref.read(authProvider);
    final isAuth = authState.isAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login';
    final isRegistering = state.matchedLocation == '/login/register';

    if (!isAuth && !isLoggingIn && !isRegistering) return '/login';
    if (isAuth && (isLoggingIn || isRegistering)) return '/wifi-scan';

    return null;
  }

  List<RouteBase> get routes => [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/wifi-scan',
          name: 'wifi-scan',
          builder: (context, state) => const WifiScanScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const LoginScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          },
          routes: [
            GoRoute(
              path: '/register',
              name: 'register',
              builder: (context, state) => const RegisterScreen(),
            ),
          ],
        ),
      ];
}
