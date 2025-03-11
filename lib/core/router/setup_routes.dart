// setup_routes.dart
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/config_setup.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/get_started.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/setup_screen.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/wifi_password.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/wifi_scan.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/screens/wifi_setup.dart';
import 'package:soiltrack_mobile/core/utils/page_transition.dart';

final setupRoutes = [
  GoRoute(
    path: '/get-started',
    name: 'get-started',
    builder: (context, state) => const GetStartedScreen(),
  ),
  GoRoute(
    path: '/setup',
    name: 'setup',
    builder: (context, state) => const SetupScreen(),
    pageBuilder: (context, state) {
      return customPageTransition(context, const SetupScreen());
    },
    routes: [
      GoRoute(
        path: 'wifi-scan',
        name: 'wifi-scan',
        builder: (context, state) => const WifiScanScreen(),
        pageBuilder: (context, state) {
          return customPageTransition(context, const WifiScanScreen());
        },
      ),
      GoRoute(
        path: 'wifi-setup',
        name: 'wifi-setup',
        builder: (context, state) => const WifiSetupScreen(),
        pageBuilder: (context, state) {
          return customPageTransition(context, const WifiSetupScreen());
        },
      ),
      GoRoute(
        path: 'wifi-password',
        name: 'wifi-password',
        builder: (context, state) => const WiFiPasswordScreen(),
      ),
      GoRoute(
        path: 'setup-config',
        name: 'setup-config',
        builder: (context, state) => const ConfigurationScreen(),
      ),
    ],
  ),
];
