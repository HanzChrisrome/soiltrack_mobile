import 'package:soiltrack_mobile/core/utils/page_transition.dart';
import 'package:soiltrack_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:soiltrack_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_adding.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_assigning.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_screen.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/custom_add.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/setup_screen.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/wifi_scan.dart';
import 'package:soiltrack_mobile/features/home/presentation/home_screen.dart';
import 'package:soiltrack_mobile/features/home/presentation/soil_dashboard.dart';
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
    if (isAuth && (isLoggingIn || isRegistering)) return '/home';

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
          routes: [
            GoRoute(
              path: 'crops',
              name: 'crops',
              builder: (context, state) => const CropsScreen(),
            ),
            GoRoute(
              path: 'add-crops',
              name: 'add-crops',
              builder: (context, state) => const AddingCropsScreen(),
            ),
            GoRoute(
              path: 'assign-crops',
              name: 'assign-crops',
              builder: (context, state) => const AssignCrops(),
            ),
            GoRoute(
              path: 'add-custom-crops',
              name: 'add-custom-crops',
              builder: (context, state) => const AddCustomCrop(),
            ),
            GoRoute(
              path: 'soil-dashboard',
              name: 'soil-dashboard',
              builder: (context, state) => const SoilDashboard(),
            ),
          ],
        ),
        GoRoute(
          path: '/setup',
          name: 'setup',
          builder: (context, state) => const SetupScreen(),
          pageBuilder: (context, state) {
            return customPageTransition(
              context,
              const SetupScreen(),
            );
          },
          routes: [
            GoRoute(
              path: '/wifi-scan',
              name: 'wifi-scan',
              builder: (context, state) => const WifiScanScreen(),
              pageBuilder: (context, state) {
                return customPageTransition(
                  context,
                  const WifiScanScreen(),
                );
              },
            ),
            GoRoute(
              path: '/wifi-setup',
              name: 'wifi-setup',
              builder: (context, state) => const WifiScanScreen(),
              pageBuilder: (context, state) {
                return customPageTransition(
                  context,
                  const WifiScanScreen(),
                );
              },
            )
          ],
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
          pageBuilder: (context, state) {
            return customPageTransition(
              context,
              const LoginScreen(),
            );
          },
          routes: [
            GoRoute(
              path: '/register',
              name: 'register',
              builder: (context, state) => const RegisterScreen(),
              pageBuilder: (context, state) {
                return customPageTransition(
                  context,
                  const RegisterScreen(),
                );
              },
            ),
          ],
        ),
      ];
}
