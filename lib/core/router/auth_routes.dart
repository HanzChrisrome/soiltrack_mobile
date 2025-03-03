// auth_routes.dart
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:soiltrack_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:soiltrack_mobile/core/utils/page_transition.dart';

final authRoutes = [
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),
    pageBuilder: (context, state) {
      return customPageTransition(context, const LoginScreen());
    },
    routes: [
      GoRoute(
        path: 'register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
        pageBuilder: (context, state) {
          return slideTransitionBuilder(context, const RegisterScreen());
        },
      ),
    ],
  ),
];
